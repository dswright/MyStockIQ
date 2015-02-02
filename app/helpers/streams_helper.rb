module StreamsHelper

  #used to process the string sent from the form to break down the different target types to be inserted into the streams table.
  def stream_params_process(stream_array)
    processed_stream_array = []
    stream_input_array = stream_array.split(",")
    stream_input_array.each do |stream_item|
      #Must add validation of these parameters against existing stock/user ids to prevent hacking.
      stream_elements = stream_item.split(":")
      processed_stream_array << {target_type: stream_elements[0], target_id: stream_elements[1]}
    end
    return processed_stream_array
  end

  #used to display each stream object in the stream.
  def stream_redirect_processor(landing_page)
    landing_page_elements = landing_page.split(":")
    return "/#{landing_page_elements[0]}/#{landing_page_elements[1]}/"
  end

  def sort_by_popularity(streams)

    #Build an array of comments and prediction id/popularity_score hashes
    popularity_ranking = popularity_array(streams)

    sorted_streams = []
    popularity_ranking.each do |ranking|
      stream = Stream.find(ranking[:id])
      sorted_streams << stream
    end

    return sorted_streams

  end

  def popularity_array(streams)
    popularity_array = []

    streams.each do |stream| 
      target = stream.streamable
      target_rank = { id: stream.id, popularity_score: target.popularity_score }
      popularity_array << target_rank
    end

    #Sort by popularity score ranking
    popularity_array = popularity_array.sort_by {|stream| stream[:popularity_score]}

    return popularity_array
  end

  
end
