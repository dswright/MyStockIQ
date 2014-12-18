#require 'unicorn/oob_gc'
#use Unicorn::OobGC, 10 # Only GC once every GC_FREQUENCY requests

# --- Start of unicorn worker killer code ---

#if ENV['RAILS_ENV'] == 'development' 
 # require 'unicorn/worker_killer'

#end

# --- End of unicorn worker killer code ---



# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
