module Rendezvous
  def punch_nat(lport, rhost, rport)
    socket = CustomSocket.new

    # set ttl low enough so it crosses our nat but won't reach remote peer.
    socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [2].pack("L"))
    socket.bind(lport)

    Timeout::timeout(0.3) do
      puts "punching hole through our NAT"
      socket.connect(rhost, rport)
    end

  rescue Timeout::Error, Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, Errno::EHOSTUNREACH => e
    puts "msg=#{e.message} class=#{e.class}"
    socket.close
  end

  # lport=0 causes OS to select a random high port
  def get_peer_endpoint(rendezvous_server, lport=0)
    socket = CustomSocket.new
    socket.bind(lport)
    socket.connect(*rendezvous_server.split(":"))

    rhost, rport = socket.gets.chomp.split(":")
    [socket.local_port, rhost, rport.to_i]
  end

  extend self
end
