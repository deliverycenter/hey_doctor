# HeyDoctor - doc c'mon man!

![banner](banner.png)

This is a simple stack health check for rails based applications, it mounts a endpoint with the current status of database, application and redis.

## Usage

After installing this gem it will mount a endpoint in `/_ah/health`, this will bring a response like this:

`curl localhost:8000/_ah/health`

```json
{
   "app":{
      "message":"Application is running",
      "success":true
   },
   "database":{
      "message":"Database is connected",
      "success":true
   },
   "redis":{
      "message":"Redis is connected",
      "success":true
   }
}
```

## Installation

* If you have a redis instance in you application add the following initializer to create a `Redis.current`, so it don't need to use global vars, or create a new connection each request:

```ruby
# config/initializers/redis.rb

Redis.current ||= Redis.new(url: ENV['REDIS_URL'])
```

It is very important to use the env `REDIS_URL`, because it will be used to check whether or not to render the redis response.

* Add a env var `RAILS_PORT` with the current application port, it will also work with the env `PORT` for backward compatibility with GAE applications.

* Add this line to your application's Gemfile:

```ruby
gem 'hey_doctor'
```

* And then execute:

```bash
bundle install
```

* After installing the gem, mount the HealthCheck endpoint inside config.ru:

```ruby
# config.ru

# bunch of requires here
require 'hey_doctor'

map '/_ah/health' do
  run HeyDoctor::Rack::HealthCheck.new
end

...
```

* The last step is to mount the engine into your application, so if the application is down the middleware will notice:

```ruby
Rails.application.routes.draw do
  mount HeyDoctor::Engine, at: '/_ah/app_health'

  ...
end
```

## Developing

```bash
docker-compose build && docker-compose up

docker-compose exec web bash

bundle exec rake db:setup

rubocop -A && rspec
```

Minimum coverage is set to 95%.

## Releasing

Change the tag in `lib/hey_doctor/version.rb` each release using [SEMVER](https://semver.org/lang/pt-BR/).

```bash
# before merging the PR build gem in pkg/hey_doctor-TAG.gem (Also changes Gemfile.lock)
bundle exec rake build

# Add the changed files
git add Gemfile.lock lib/hey_doctor/version.rb
git commit -m "Updated gem v0.0.0."

# Create a new git tag
git tag -a v0.0.0 -m "Description here."

bundle exec rake release
# Ask for rubygems credentials and makes the release, push the commit and the tag
```
## Contributing

Fell free to send a PR.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
