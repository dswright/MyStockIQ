
# --- Start of unicorn worker killer code ---

#if ENV['RAILS_ENV'] == 'development' 
  require 'unicorn/worker_killer'

  max_request_min =  500
  max_request_max =  600

  # Max requests per worker
  use Unicorn::WorkerKiller::MaxRequests, max_request_min, max_request_max

  oom_min = (90) * (1024**2)
  oom_max = (100) * (1024**2)

  # Max memory size (RSS) per worker
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max, check_cycle=5, verbose=true
  #use Unicorn::WorkerKiller::Oom(memory_limit_min=oom_min, memory_limit_max=oom_max, check_cycle = 5, verbose = true)
#end

# --- End of unicorn worker killer code ---



# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
