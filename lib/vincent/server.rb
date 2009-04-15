require 'lib/vincent/base'
require 'neverblock'

module Vincent
  class Server
    extend Core

    def self.start(&block)
      error = nil
      EM.run { 
        Signal.trap('INT')  { stop }
        Signal.trap('TERM') { stop }

        Fiber.new {
          Vincent::Routes.bind
          EM.add_periodic_timer(60) { Vincent::Routes.check }
          begin
            block.call(Vincent::Server) if block
          rescue Object => e
            error = e
            EM.stop
          end
        }.resume
      }
      raise error if error
    end

    def self.stop
      EM.next_tick { AMQP.stop { EM.stop } }
    end
  end
end

