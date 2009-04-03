require 'lib/vincent/base'

module Vincent
  class Server
    extend Core

    def self.start(&block)
      EM.run { 
        Signal.trap('INT')  { stop }
        Signal.trap('TERM') { stop }

        begin
        Fiber.new {
          Vincent::Routes.bind
          EM.add_periodic_timer(60) { Vincent::Routes.check }
          block.call(Vincent::Server) if block
        }.resume
        rescue Exception => e
          puts "got execpiton e{#{e}}."
          raise e
        end
      }
    end

    def self.stop
      AMQP.stop { EM.stop }
    end
  end
end

