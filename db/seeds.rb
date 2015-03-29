# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = User.all
stock = Stock.find_by(ticker_symbol: "AAPL")

#Creates 50 comment posts
20.times do
	users.each do |user|
		content = Faker::Lorem.sentence(5)
		comment = user.comments.create!(content: content)
		comment.streams.create!(streamable_type: comment.class.name, targetable_type: stock.class.name, targetable_id: stock.id)
		comment.streams.create!(streamable_type: comment.class.name, targetable_type: user.class.name, targetable_id: user.id)
		comment.build_popularity(score: 0).save
	end
end

