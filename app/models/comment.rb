class Comment < ActiveRecord::Base
  require 'popularity_past'
  include PopularityPast

	belongs_to :user
	has_one :popularity, as: :popularable, dependent: :destroy
  	has_many :streams, as: :streamable, dependent: :destroy
	has_many :likes, as: :likable
	has_many :replies, as: :repliable
	has_one :tag, as: :tagable, dependent: :destroy

	validates :content, presence: true, length: { maximum: 5000}
	validates :user_id, presence: true, numericality: true
	default_scope -> { order(created_at: :desc) }

	scope :by_user, lambda {|user| where(user_id: user.id)}

	def add_tags(ticker_symbol=nil)
		words = self.content.split
		
		unless ticker_symbol == nil
			words.unshift("$#{ticker_symbol}")
		end

		tagged_words = words.collect do |word|
			if word[0] == "$"
				#remove first character
				word.slice!(0)

				if Stock.exists?(ticker_symbol: word)
					word = "<a href = \"/stocks/#{word}/\"> $#{word} </a>"
				else
					word.prepend("$")
				end

		 	elsif word[0] == "@"
		 		#remove first character
		 		word.slice!(0)
		 		if User.exists?(username: word)
		 			word = "<a href = \"/users/#{word}/\"> @#{word} </a>"
		 		else
		 			word.prepend("@")
		 		end

		 	else 
		 		word = word
		 	end

		 end

		 self.create_tag!( content: tagged_words.join(" ") )

		 return self.tag.content
	end

end
