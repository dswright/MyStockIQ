module StreamsHelper



  def tweet_link(prediction)
    url = "https://twitter.com/intent/tweet?"

    tweet = {
      via: "stock_iq"
    }

    tweet[:text] = html_escape("#{prediction.stock.ticker_symbol} stock will go up to #{number_to_currency(prediction.prediction_end_price)} in #{time_ago_in_words(prediction.prediction_end_time)}").gsub(/\s+/,"%20")
    #tweet[:text] = URI.endcode("#{prediction.stock.ticker_symbol} stock will go up to #{number_to_currency(prediction.prediction_end_price)} in time_ago_in_words(prediction.prediction_end_time) ##{tweet[:hash_tag]}")
    extension = tweet.map { |k, v| "#{k}=#{v}" }.join("&")

    return url + extension
  end

end
