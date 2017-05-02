### Install
* Redis (https://redis.io/topics/quickstart)
* bundle install
    * will install sinatra
    * will install redis-rb
    * will install sidekiq

### Run
* Make sure redis server is running on the standard port `<path to redis>/src/redis-server`
* Make sure sidekiq is running `sidekiq -r keyserver.rb`
* `ruby keyserver.rb`

### Tests
* Run `$> bash test.sh` to run the bash tests
* Tests are automated but need a prompt to execute one after the another
