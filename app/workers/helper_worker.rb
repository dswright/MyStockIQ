#this is a file to write random functions for one time modifications.

class GooglenewsWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform
    Newsarticle.all.each do |article|
      if article.popularity == nil
        article.build_popularity(score:0).save
      end
    end
  end
end