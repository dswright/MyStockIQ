#this is a file to write random functions for one time modifications.

class HelperWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(article_id)
    article = Newsarticle.find(article_id)
    article.build_popularity(score:0).save
  end
end