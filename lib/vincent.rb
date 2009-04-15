require 'mq'
require 'uri'
require 'json'

module Vincent
  def self.cast(key,data)
    Vincent::Client.cast(key,data)
  end

  def self.call(key,data)
    raise "dont do this"
  end

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
      args.delete('ttl') if args['ttl'].to_i > 0
      mq_publish(encode(args), :routing_key => key)
      nil
    end

    def mq_publish(data, opts)
      exchange.publish(data, opts)
    end

    def encode(data)
      data.to_json
    end

    def decode(data)
      begin
        JSON.parse(data)
      rescue 
        # log error
        {}
      end
    end
  end

  class Client
    extend Core
  end
end

config = URI.parse(ENV['AMQP_URI'] || 'amqp://guest:guest@localhost/')
AMQP.settings.merge!(
  :host  => config.host,
  :user  => config.user,
  :pass  => config.password,
  :vhost => config.path
)

