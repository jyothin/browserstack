KEY_AVAILABLE = "available"
KEY_ID = "id"
KEY_KA_AT_TIMESTAMP = "keep_alive_at_timestamp"
KEY_IS_BLOCKED = "is_blocked"
KEY_BLOCKED_AT_TIMESTAMP = "blocked_at_timestamp"
KEY_IS_DEAD = "is_dead"

module Workers
  
  UNBLOCK_TIMEOUT = 60
  DEAD_TIMEOUT = 300
  
  $redis = Redis.new
  
  class UnblockKeyWorker
    include Sidekiq::Worker
    
    def perform(id)
      if id != nil && $redis.exists(id.to_s)
        key = JSON.parse($redis.get(id.to_s))
        if key[KEY_BLOCKED_AT_TIMESTAMP] != nil
          if Time.new(key[KEY_BLOCKED_AT_TIMESTAMP]) + UNBLOCK_TIMEOUT <= Time.now
            puts "#{id}: UnblockKeyWorker: timeout"
            key[KEY_IS_BLOCKED] = false
            key[KEY_BLOCKED_AT_TIMESTAMP] = nil
            $redis.set(id.to_s, key.to_json)
            available = JSON.parse($redis.get(KEY_AVAILABLE))
            available.push(id)
            $redis.set(KEY_AVAILABLE, available)
          else
            puts "#{id}: UnblockKeyWorker: No timeout"
          end
        else
          puts "#{id}: UnblockKeyWorker: blocked_at_timestamp is nil"
        end
      else
        puts "#{id}: UnblockKeyWorker: key does not exist"
      end
    end
  end
  
  class DeadKeyWorker
    include Sidekiq::Worker
    
    def perform(id)
      if id != nil && $redis.exists(id.to_s)
        key = JSON.parse($redis.get(id.to_s))
        if Time.new(key[KEY_KA_AT_TIMESTAMP]) + DEAD_TIMEOUT <= Time.now
          puts "#{id}: DeadKeyWorker: timeout!"
          key[KEY_IS_DEAD] = true
          $redis.set(id.to_s, key.to_json)
          $redis.del(id.to_s)
        else
          puts "#{id}: DeadKeyWorker: No timeout"
        end
      else
        puts "#{id}: DeadKeyWorker: key does not exist"
      end
    end
  end
end
