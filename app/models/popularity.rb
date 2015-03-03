class Popularity < ActiveRecord::Base
  #declares a polymorphic association for the streams table. 
  belongs_to :popularable, polymorphic: true
  has_one :popularity, as: :popularable, dependent: :destroy


end
