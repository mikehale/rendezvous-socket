require './custom_socket'
require 'thread'
semaphore = Mutex.new

PEERS = []

def peer(c)
  [c.peeraddr[3], c.peeraddr[1]].join(":")
end

def handle_client(client)
  puts peer(client)

  #semaphore.synchronize do
    PEERS << client
    
    case PEERS.size
    when 0,1
      #noop
    when 2
      peer_a = PEERS[0]
      peer_b = PEERS[1]
      peer_a.puts peer(peer_b)
      peer_b.puts peer(peer_a)
      peer_a.close
      peer_b.close
      PEERS.clear
    else
      PEERS.clear
    end
  #end
end

s = TCPServer.new('0.0.0.0', 5000)
loop do
  Thread.start(s.accept) do |client|
    handle_client(client)
  end
end
s.close
