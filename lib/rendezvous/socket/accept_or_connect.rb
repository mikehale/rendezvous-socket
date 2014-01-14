require 'timeout'
require 'socket'
module Rendezvous

  class AcceptOrConnect
    include ::Socket::Constants

    CONN_REFUSED_DELAY = 0.5
    ADDR_IN_USE_DELAY = 0.5
    CONNECTION_TIMEOUT = 10

    attr_reader :bind_port, :bind_addr, :dest_port, :dest_addr

    def initialize(bind_port, bind_addr, dest_port, dest_addr)
      @bind_port = bind_port
      @bind_addr = bind_addr
      @dest_port = dest_port
      @dest_addr = dest_addr
    end

    def new_socket
      ::Socket.new(AF_INET, SOCK_STREAM, 0).tap do |s|
        s.setsockopt(SOL_SOCKET, SO_REUSEADDR, true)
        s.setsockopt(SOL_SOCKET, SO_REUSEPORT, true) if defined?(SO_REUSEPORT)
        s.bind(::Socket.sockaddr_in(bind_port, bind_addr))
      end
    end

    def socket
      Timeout::timeout(CONNECTION_TIMEOUT) {
        wait_for_accept_or_connect
      }
    end

    def wait_for_accept_or_connect
      a_thread = Thread.new {
        s = new_socket
        s.listen(5)
        client_socket, addrinfo = s.accept
        Thread.current["socket"] = client_socket
        Thread.current["addrinfo"] = addrinfo
        Thread.current.exit
      }
      a_thread.abort_on_exception = true

      c_thread = Thread.new {
        begin
          s = new_socket
          sockaddr = ::Socket.sockaddr_in(dest_port, dest_addr)
          s.connect(sockaddr)
          Thread.current["socket"] = s
          Thread.current["addrinfo"] = Addrinfo.new(sockaddr)
        rescue Errno::ECONNREFUSED
          sleep CONN_REFUSED_DELAY
          retry
        rescue Errno::EADDRINUSE
          sleep ADDR_IN_USE_DELAY
          retry
        end
        Thread.current.exit
      }
      c_thread.abort_on_exception = true

      # wait while both a and c are alive
      while a_thread.alive? && c_thread.alive?
        sleep 0.1
      end

      if a_thread.status == false
        # accept succeded
        Thread.kill(c_thread)
        [a_thread["socket"], a_thread["addrinfo"], :accept]
      elsif c_thread.status == false
        # connect succeded
        Thread.kill(a_thread)
        [c_thread["socket"], c_thread["addrinfo"], :connect]
      end

    end
  end

end
