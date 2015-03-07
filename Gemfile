source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails
ruby '2.2.0'
gem 'rails',                '4.2.0.beta4'
gem 'unicorn'
#gem 'unicorn-worker-killer'
gem 'newrelic_rpm'
gem 'oink'
gem 'gon'
gem 'feedjira'
gem 'responders', '~> 2.0'

gem 'rest-client', '~> 1.7.2'

#add bcrypt for the password encryption
gem 'bcrypt',               '3.1.7'

gem 'faker',				'1.4.2'
gem 'will_paginate',           '3.0.7'


# Use SCSS for stylesheets
gem "sass", "~> 3.2.5"

gem 'sass-rails'

gem 'bootstrap-sass',		'3.2.0.0'
# Needed to use paginate
gem 'bootstrap-will_paginate', '0.0.10'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier',             '2.5.3'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails',         '4.0.1'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

gem 'json', '~> 1.8.1'
gem 'rabl' #used to build the ajax api for the graph.

# Use jquery as the JavaScript library
gem 'jquery-rails',         '3.1.2'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks',           '2.3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder',             '2.1.3'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc',                 '0.4.0', group: :doc
gem 'rails-html-sanitizer', '1.0.1'

#for speeding up csv functions.
gem 'fastercsv', '~> 1.5.5'

#for cron jobs.
gem 'whenever', '0.9.4'

gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'

gem 'arel', '6.0.0.beta2'

gem 'pg',             '0.17.1'
gem 'rails_12factor', '0.0.2'
gem 'rack-mini-profiler'

group :development, :test do

	# Use sqlite3 as the database for Active Record
	gem 'byebug',      '3.4.0'
	gem 'web-console', '2.0.0.beta3'

	# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
	gem 'spring',      '1.1.3'

  # Pry is a replacement for IRB with more features
  gem 'pry'

end

group :test do
  gem 'minitest-reporters', '1.0.5'
  gem 'mini_backtrace',     '0.1.3'
  gem 'guard-minitest',     '2.3.1'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

