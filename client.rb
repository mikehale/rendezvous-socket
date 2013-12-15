require './custom_socket'

s = RendezvousSocket.new(ENV['RENDEZVOUS_SERVER']).open
s.puts Socket.gethostname
puts s.gets
