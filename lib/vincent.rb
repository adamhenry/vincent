
require 'mq'
require 'uri'
require 'json'

module Vincent

	def self.method_missing(method,data = {})
		key = method.to_s.gsub(/_/,".")
		Vincent::Client.cast(key,data)
	end

	module Core
    def exchange
       @exchange ||= MQ.topic
    end

		def cast(key,args = {})
			args['kill_by'] = Time.now.to_i + args['ttl'] if args['ttl'].to_i > 0
			exchange.publish(encode(args), :routing_key => key)
			nil
		end

		def encode(data)
			data.to_json
		end

		def decode(data)
			begin
				JSON.parse(data)
			rescue 
				puts "could not parse #{data}" #handel this better
				{}
			end
		end
	end

	class Client
		extend Core
	end
end

# Thread.new { EM.run { } }

config = URI.parse(ENV['AMQP_URI'] || 'amqp://guest:guest@localhost/')
AMQP.settings.merge!(
  :host  => config.host,
  :user  => config.user,
  :pass  => config.password,
  :vhost => config.path
)

