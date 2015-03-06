#this is a file to write random functions for one time modifications.

class HelperWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(stream_id)
    stream = Stream.find(stream_id)
    stream.targetable_id = stream.target_id
    stream.targetable_type = stream.target_type
  end
end