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

  def response_maker(msgs)
    html = ""
    if msgs
      msgs.each do |msg|
        html += html + "<li>" + msg + "</li>";
      end
    end
    return html
  end

end
