require 'lib/vincent'
require 'fiber'
require 'socket'
require 'neverblock'

### TODO

### symbolize keys
### confirm works with droids 
### headers
### cache
### autodelete queues?

module Vincent
  class RejectMessage < RuntimeError ; end
  class MissingCallHandler < RuntimeError ; end
  class MissingCastHandler < RuntimeError ; end

  module Core
    def call(key, args = {})
      args['reply_to'] = "reply_to.#{rand 99_999_999}"
      fiber = Fiber.current 
      subscribe(args['reply_to']) do |result|
        fiber.resume(result)
      end
      cast(key, args)
      reply = Fiber.yield
      raise unpack(reply["exception"]) if reply["exception"]
      return unpack(reply["results"]) if reply["results"]
      return reply
    end

    def listen4(key, options = {}, &block)
      q = options[:queue]
      q ||= "q.#{key}.#{Socket.gethostname}" 

      bind(q, key)
      Fiber.new do
        subscribe(q) do |args|
          block.call(Vincent::Base.new(args, args))
        end
      end.resume
    end

    def bind(q, key)
      MQ.queue(q).bind(exchange, :key => key)
    end

    def unsubscribe(q)
      MQ.queue(q).unsubscribe
    end

    def subscribe(q, &block)
      MQ.queue(q).subscribe(:ack => true) do |info, data|
        next if AMQP.closing?

        args = decode(data)

        if args['kill_by'] and args['kill_by'] < Time.now.to_i
          info.ack
          return
        end
        begin
          results = block.call(args)
        rescue RejectMessage
          info.reject
          next
        rescue Exception => e
          puts "got exception #{e} - packing it for return"
          ## just display the exception if there's not reply_to
          results = { :exception => pack(e) } 
        end
        results = { :results => pack(results) } unless results.is_a?(Hash)
        MQ.queue(args['reply_to']).publish(encode(results)) if args['reply_to']
        info.ack
      end
      nil
    end

    def pack(obj)
        [Marshal.dump(obj)].pack("m")
    end

    def unpack(s)
        Marshal.load(s.unpack("m")[0])
    end
  end

  class Binding
    attr_accessor :key, :klass, :q, :subscribed, :active 
    def initialize(key, klass, q, active)
      @key = key
      @klass = klass
      @q = q
      @subscribed = false
      @active = active
    end

    def needs_to_subscribe?
      handler = klass.new({}, {})
      subscribed == false and handler.send(active) == true
    end

    def needs_to_unsubscribe?
      handler = klass.new({}, {})
      subscribed == true and handler.send(active) == false
    end
  end

  module Routes
    def bind_to(key, options = {})
      key = key.to_s

      case options[:route_to]
      when :one
        q = "q.#{key}" 
      when :host
        q = "q.#{key}.#{Socket.gethostname}" 
      when :all
        q = "q.#{key}.#{Socket.gethostname}.#{Process.pid}" 
      else
        raise "route_to => :one, :all or :host" 
      end

      active = options[:active]
      active ||= :active

      Routes.bindings[key] = Binding.new(key, self, q, active)
    end

    def self.check
      bindings.each do |key, b|
        if b.needs_to_subscribe?
          Server.subscribe(b.q) do |params|
            handler = b.klass.new(params, params)
            handler.handle
          end
          b.subscribed = true
        elsif b.needs_to_unsubscribe?
          Server.unsubscribe(b.q)
          b.subscribed = true
        end
      end
    end

    def self.bind
      bindings.each do |key, b|
        Server.bind(b.q, b.key)
      end
      check
    end

    def self.bindings
      @bindings ||= {}
    end
  end

  class Base < Vincent::Client
    extend Routes

    attr_accessor :headers, :params

    def initialize(headers, params)
      @headers = headers
      @params = params
    end

    def [](index)
      params[index]
    end

    def active
      true
    end

    def reject
      raise RejectMessage
    end

    def handle
      Fiber.new do
        if params['reply_to']
          handle_call
        else
          handle_cast
        end
      end .resume
    end

    def handle_call
      raise MissingCallHandler
    end

    def handle_cast
      raise MissingCastHandler
    end
  end
end

