'''
Key Server problem:
Write a server which can generate random api keys, assign them for usage and 
release them after sometime.

Following endpoints should be available on the server to interact with it.
See notes before each endpoint.

Apart from these endpoints, following rules should be enforced:
See rule at endpoint E3

No endpoint call should result in an iteration of whole set of keys i.e. 
no endpoint request should be O(n). They should either be O(lg n) or O(1).
'''

# Redis is single threaded hence it will queue up operations
# Use List type in Redis for storing the list of available Keys
# Use Map type in Redis for storing the keys

require 'sinatra'
require 'redis'
require 'json'
require 'securerandom'
require 'sidekiq'
require_relative 'workers'

KEY_SIZE = 32

$redis = Redis.new
$redis.set(KEY_AVAILABLE, Array.new())

#E1. There should be one endpoint to generate keys.
post '/' do
  extend Workers
  id = SecureRandom.hex(KEY_SIZE)
  key = Hash.new()
  key[KEY_ID] = id
  key[KEY_KA_AT_TIMESTAMP] = Time.now
  key[KEY_IS_BLOCKED] = false
  key[KEY_BLOCKED_AT_TIMESTAMP] = nil
  key[KEY_IS_DEAD] = false
  $redis.set(id.to_s, key.to_json)
  available = JSON.parse($redis.get(KEY_AVAILABLE))
  available.push(id)
  $redis.set(KEY_AVAILABLE, available)
  Workers::DeadKeyWorker.perform_in(Workers::DEAD_TIMEOUT, id)
  [201]
end

#E2. There should be an endpoint to get an available key. 
#    On hitting this endpoint server should serve a random key which is not already being used.
#    This key should be blocked and should not be served again by E2, till it is in this state
#    If no eligible key is available then it should serve 404.
get '/' do
  extend Workers
  available = JSON.parse($redis.get(KEY_AVAILABLE))
  while id = available.shift
    $redis.set(KEY_AVAILABLE, available)
    next if id == nil || !$redis.exists(id.to_s)
    key = JSON.parse($redis.get(id.to_s))
    if !key[KEY_IS_DEAD]
      key[KEY_IS_BLOCKED] = true
      key[KEY_BLOCKED_AT_TIMESTAMP] = Time.now
      $redis.set(id.to_s, key.to_json)
      Workers::UnblockKeyWorker.perform_in(Workers::UNBLOCK_TIMEOUT, id)
      return [200, id]
    end
  end
  return [404]
end

#E3. There should be an endpoint to unblock a key. 
#    Unblocked keys can be served via E2 again.
#R1. All blocked keys should get released automatically within 60 secs if E3 is 
#    not called.
get '/:id' do
  id = params["id"]
  return [404] if id == nil || !$redis.exists(id.to_s)
  key = JSON.parse($redis.get(id.to_s))
  key[KEY_IS_BLOCKED] = false
  key[KEY_BLOCKED_AT_TIMESTAMP] = nil
  $redis.set(id.to_s, key.to_json)
  available = JSON.parse($redis.get(KEY_AVAILABLE))
  available.push(id)
  $redis.set(KEY_AVAILABLE, available)
  [200]
end

#E4. There should be an endpoint to delete a key. 
#    Deleted keys should be purged.
delete '/:id' do
  id = params["id"]
  return [400] if id == nil || !$redis.exists(id.to_s)
  key = JSON.parse($redis.get(id.to_s))
  key[KEY_IS_DEAD] = true
  $redis.set(id.to_s, key.to_json)
  $redis.del(id.to_s)
  return [200]
end

#E5. All keys are to be kept alive by clients calling this endpoint every 5 
#    minutes.
#    If a particular key has not received a keep alive in last five minutes then
#    it should be deleted and never used again.
put '/:id' do
  extend Workers
  id = params["id"]
  return [404] if id == nil || !$redis.exists(id.to_s)
  key = JSON.parse($redis.get(id.to_s))
  key[KEY_KA_AT_TIMESTAMP] = Time.now
  $redis.set(id.to_s, key.to_json)
  Workers::DeadKeyWorker.perform_in(Workers::DEAD_TIMEOUT, id)
  return [200]
end