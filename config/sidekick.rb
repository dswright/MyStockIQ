require 'redis'
REDIS = Redis.new(host: "redis://localhost", port: 15255)
 
Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:15255" }
end
 
Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:15255" }
end