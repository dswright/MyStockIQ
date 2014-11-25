require 'redis'
REDIS = Redis.new(host: "redis://localhost", port: 9250)
 
Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:9250" }
end
 
Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:9250" }
end