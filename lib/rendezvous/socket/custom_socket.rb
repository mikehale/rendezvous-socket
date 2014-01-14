require 'socket'

module Rendezvous
  module Socket
    class CustomSocket < ::Socket
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
        ip = ::Socket.ip_address_list.detect{|a| a.ipv4_private? }.ip_address
        $stderr.puts "attempting to bind to #{ip}:#{port}" if $DEBUG
        addr_local = ::Socket.pack_sockaddr_in(port, ip)
        super(addr_local)
      end

      def connect(ip, port)
        $stderr.puts "attempting to connect to #{ip}:#{port}" if $DEBUG
        addr_remote = ::Socket.pack_sockaddr_in(port, ip)
        super(addr_remote)
      end

      def connect_nonblock(ip, port)
        $stderr.puts "attempting to connect_nonblock to #{ip}:#{port}" if $DEBUG
        addr_remote = ::Socket.pack_sockaddr_in(port, ip)
        super(addr_remote)
      end

      def accept
        $stderr.puts "attempting to accept" if $DEBUG
        super[0]
      end

      def accept_nonblock
        $stderr.puts "attempting to accept_nonblock" if $DEBUG
        super[0]
      end

      def addr
        ::Socket.unpack_sockaddr_in(getsockname)
      end

      def local_port
        addr[0]
      end
    end
  end
end
