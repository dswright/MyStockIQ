module StocksHelper
	require 'customdate'

  def graph_time(time_str)
    time_str.utc_time_int.graph_time_int
  end
end
