class Newsarticle < ActiveRecord::Base
  has_many :streams, as: :streamable
  require 'popularity'
  include Popularity

end
