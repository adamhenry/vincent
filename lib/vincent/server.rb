require 'vincent/base'

module Vincent

	class Server

		extend Core

    ## hand signal handler here

		def self.start(&block)
			EM.run { 

				Signal.trap('INT') { AMQP.stop{ EM.stop } }
				Signal.trap('TERM'){ AMQP.stop{ EM.stop } }

				Fiber.new {
					Vincent::Routes.bind
					EM.add_periodic_timer(60) { Vincent::Routes.check }
					block.call(Vincent::Server) if block
				}.resume
			}
		end

	end

end

