json.content @reply.content
json.time_ago time_ago_in_words(@reply.created_at)
json.user do
  json.username @reply.user.username
  json.image @reply.user.image.url
end