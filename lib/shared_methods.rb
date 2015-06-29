module SharedMethods

	def likes_count
		self.likes.where(like_type: "like").count
	end

	def dislikes_count
		self.likes.where(like_type: "dislike").count
	end

  def has_replies?
  	count = Stream.where(targetable_id: self.id, targetable_type: self.class.name).count
  	if count > 0
  		return true
  	else 
  		return false
  	end
  end

  def add_tags(ticker_symbol=nil)
    words = self.content.split
    tags = Array.new

    unless ticker_symbol == nil
      #Append target stock name to beginning of text content
      words.unshift("$#{ticker_symbol}")
    end

    tagged_words = words.collect do |word|
      if word[0] == "$"
        #remove first character
        word.slice!(0)
        #Checks word and word minus last character to remove possible punctuation
        if Stock.exists?(ticker_symbol: word)
          tag = Stock.find_by(ticker_symbol: word)
          tags << tag
          word = "<a href = \"/stocks/#{word}/\"> $#{word} </a>"

        elsif Stock.exists?(ticker_symbol: word[0..word.length-2])
          tag = Stock.find_by(ticker_symbol: word[0..word.length-2])
          tags << tag
          word = "<a href = \"/stocks/#{word[0..word.length-2]}/\"> $#{word} </a>"
        else
          word.prepend("$")
        end

      elsif word[0] == "@"
        #remove first character
        word.slice!(0)
        #Checks word and word minus last character to remove possible punctuation
        if User.exists?(username: word)
          tag = User.find_by(username: word)
          tags << tag
          word = "<a href = \"/users/#{word}/\"> @#{word} </a>"
        elsif User.exists?(username: word[0..word.length-2])
          tag = User.find_by(username: word[0..word.length-2])
          tags << tag
          word = "<a href = \"/users/#{word[0..word.length-2]}/\"> @#{word} </a>"
        else
          word.prepend("@")
        end

      else 
        #must return word for the collect method to keep the word in the array
        word = word
      end
    end

     self.create_tag!( content: tagged_words.join(" ") )

     return tags
  end   



end