### Install
* Ruby & Rails version
    * Upgrade to ruby 2.4 (https://gorails.com/setup/osx/10.11-el-capitan)
    * Upgrade to rails 5.0
* Redis (https://redis.io/topics/quickstart)
* Sidekiq (https://github.com/mperham/sidekiq)
* `bundle install`
    * will install sinatra
    * will install redis-rb
    * will install sidekiq

### Run
* Make sure redis server is running on the standard port `<path to redis>/src/redis-server`
* Make sure sidekiq is running `sidekiq -r ./workers.rb`
* `ruby keyserver.rb`

### Tests
* Run `$> bash test.sh` to run the bash tests
* Tests are automated but need a prompt to execute one after the another
