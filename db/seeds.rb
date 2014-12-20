# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = User.order(:created_at).take(1)

50.times do 
	users.each { |user| user.streams.create!(stream_type: "comment", stock_id: 1) }
end

streams = Stream.last(50)
content = Faker::Lorem.sentence(5)
streams.each { |stream| stream.comments.create!(content: content, ticker_symbol: "AAPL")}
