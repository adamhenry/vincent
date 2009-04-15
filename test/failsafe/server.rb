
require 'lib/vincent/server'

class MyHandler < Vincent::Base
	bind_to "test_server", :route_to => :host

	def handle_cast
		puts "SERVER: Got a cast"
    puts params.inspect
    if params["exit"]
      puts "shutting down..."
      Vincent::Server.stop
    end
  end

	def handle_call
		puts "test"
		[1,2,3]
	end

end

Vincent::Server.start

