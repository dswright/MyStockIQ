
json.type @reply

json.time_ago time_ago_in_words(@reply.created_at)


json.type @stream.streamable_type
json.content @stream.streamable.content
json.time_ago time_ago_in_words(@stream.created_at)

json.replies @stream.streamable.replies do |reply|
  json.content reply.content
  json.time_ago time_ago_in_words(reply.created_at)
  json.user do
    json.username reply.user.username
    json.image reply.user.image.url
  end
end


json.user do
  if @stream.streamable_type == "Predictionend"
    json.username @stream.streamable.prediction.user.username
    json.image @stream.streamable.prediction.user.image.url
  else
    json.username @stream.streamable.user.username
    json.image @stream.streamable.user.image.url
  end
end