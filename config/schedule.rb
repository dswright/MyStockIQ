
env :PATH, ENV['PATH']
set :output, "log/cron_log.log"

  every 1.day, at: "2:30 pm" do
    rake "scraper:fetch_stocks"
  end

  every 1.day, at: "2:35 pm" do
    rake "scraper:fetch_stocks_pe"
  end

  every 1.day, at: "2:40 pm" do
    rake "scraper:fetch_recent_prices"
  end

#whenever --update-crontab --set environment='development'

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
