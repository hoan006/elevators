require 'resque'
Resque.redis = 'localhost:6379'

require 'resque_scheduler'
require 'resque_scheduler/server'
Resque.schedule = YAML.load_file(Rails.root + 'config/resque_scheduler.yml')

Resque.logger = Logger.new(STDOUT)

Resque.after_fork do |job|
  Resque.redis.client.reconnect
end