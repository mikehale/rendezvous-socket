require './custom_socket'
require './rendezvous'

rendezvous_server = '54.197.255.218:5000'

puts "awaiting peer endpoint from rendezvous server"
lport, rhost, rport = Rendezvous.get_peer_endpoint(rendezvous_server, 0)
puts "lport: #{lport}"
puts "peer: #{[rhost, rport].join(":")}"

#Rendezvous.punch_nat(lport, rhost, rport)

puts "connect and listen..."

client = CustomSocket.new
client.bind(lport)
if client.connect(rhost, rport)
  p :conn
  client.puts Socket.gethostname
  puts client.gets
else
  p :accept
  server = CustomSocket.new
  server.bind(lport)
  server.listen(5)
  peer = server.accept
  puts "connected to #{rhost}"
end
