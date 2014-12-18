#require 'unicorn/oob_gc'
#use Unicorn::OobGC, 10 # Only GC once every GC_FREQUENCY requests

# --- Start of unicorn worker killer code ---

#if ENV['RAILS_ENV'] == 'development' 
 # require 'unicorn/worker_killer'

 # max_request_min =  500

  # Max requests per worker
 # use Unicorn::WorkerKiller::MaxRequests, max_request_min, max_request_max


  #oom_min (70) * (1024**2) in this branch lets add something nice here. another change.
#lower down.

 # use Unicorn::WorkerKiller::Oom, oom_min, oom_max, 1, true
  #use Unicorn::WorkerKiller::Oom(memory_limit_min=oom_min, memory_limit_max=oom_max, check_cycle = 5, verbose = true)
#end

# --- End of unicorn worker killer code ---



# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
