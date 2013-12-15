require 'socket'
require 'timeout'

class CustomSocket < Socket
  def initialize
    super(AF_INET, SOCK_STREAM, 0)
    setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    if defined?(SO_REUSEPORT)
      setsockopt(SOL_SOCKET, SO_REUSEPORT, 1)
    end
  end

  def listen(buf)
    $stderr.puts "attempting to listen" if $DEBUG
    super(buf)
  end

  def bind(port = 0)
    ip = Socket.ip_address_list.detect{|a| a.ipv4_private? }.ip_address
    $stderr.puts "attempting to bind to #{ip}:#{port}" if $DEBUG
    addr_local = Socket.pack_sockaddr_in(port, ip)
    super(addr_local)
  end

  def connect(ip, port)
    $stderr.puts "attempting to connect to #{ip}:#{port}" if $DEBUG
    addr_remote = Socket.pack_sockaddr_in(port, ip)
    super(addr_remote)
  end

  def accept
    super[0]
  end

  def addr
    Socket.unpack_sockaddr_in(getsockname)
  end

  def local_port
    addr[0]
  end
end

class RendezvousSocket < CustomSocket
  attr_reader :rendezvous_server

  def initialize(rendezvous_server)
    @rendezvous_server = rendezvous_server
    super
  end

  # lport=0 causes OS to select a random high port
  def get_peer_endpoint(lport=0)
    socket = CustomSocket.new
    socket.bind(lport)
    socket.connect(*rendezvous_server.split(":"))

    rhost, rport = socket.gets.chomp.split(":")
    [socket.local_port, rhost, rport.to_i]
  end

  def peer_socket
    lport, rhost, rport = get_peer_endpoint
    peer = CustomSocket.new
    peer.bind(lport)
    peer if peer.connect(rhost, rport)
  end

  def open
    peer_socket
  end

end

