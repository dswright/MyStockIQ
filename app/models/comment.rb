class Comment < ActiveRecord::Base
  require 'popularity_past'
  include PopularityPast

	belongs_to :user
	has_one :popularity, as: :popularable, dependent: :destroy
  	has_many :streams, as: :streamable, dependent: :destroy
	has_many :likes, as: :likable
	has_many :replies, as: :repliable

	validates :content, presence: true, length: { maximum: 5000}
	validates :user_id, presence: true, numericality: true
	default_scope -> { order(created_at: :desc) }

	scope :by_user, lambda {|user| where(user_id: user.id)}

	def add_tags(ticker_symbol)
		 
		words = self.content.split

		words.unshift("$#{ticker_symbol}")

		words.each do |word|
			if word[0] == "$"

		 	elsif word[0] == "@"

		 	end
		 end
		 self.content = words.join(" ")
		 self.save
	end

end
