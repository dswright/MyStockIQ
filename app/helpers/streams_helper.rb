module StreamsHelper

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

end
