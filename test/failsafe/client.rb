require 'rubygems'
require 'lib/vincent/server'

Vincent::Server.start do |s|
  x = s.call("test_server",{ :test => :server })
  puts "i made a call and I got #{x.inspect}"
  x = s.cast("test_server",{ :exit => "now" })
  EM.next_tick { EM.stop }
end

