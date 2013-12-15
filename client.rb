require './custom_socket'

s = RendezvousSocket.new('54.197.255.218:5000').open
s.puts Socket.gethostname
puts s.gets
