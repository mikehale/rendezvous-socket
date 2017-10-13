require 'timeout'
require 'socket'

module Rendezvous

  module Errors
    class Error < StandardError; end
    class Authentication < Error; end
    class Connection < Error; end
    class Timeout < Error; end
    class ActivityTimeout < Timeout; end
    class ConnectionTimeout < Timeout; end
  end

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
      tcp_socket = ::Socket.new(AF_INET, SOCK_STREAM, 0).tap do |s|
        s.setsockopt(SOL_SOCKET, SO_REUSEADDR, true)
        s.setsockopt(SOL_SOCKET, SO_REUSEPORT, true) if defined?(SO_REUSEPORT)
        s.bind(::Socket.sockaddr_in(bind_port, bind_addr))
        s.listen(5)
      end

      # ssl_context = OpenSSL::SSL::SSLContext.new
      # ssl_context.ssl_version = :TLSv1
      # ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      # OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context).tap do |s|
      #   s.sync_close = true
      # end

      tcp_socket
    end

    def socket
      Timeout::timeout(CONNECTION_TIMEOUT) {
        wait_for_accept_or_connect
      }
    end

    def send_syn!
      socket = new_socket
      Timeout::timeout(0.3) {
        sockaddr = ::Socket.sockaddr_in(dest_port, dest_addr)
        socket.connect(sockaddr)
      }
    rescue Timeout::Error
    ensure
      if socket && !socket.closed?
        socket.close
      end
    end

    def wait_for_accept_or_connect
      begin
        accept_socket = new_socket
        a_client_socket, a_addrinfo = accept_socket.accept_nonblock

        connect_socket = new_socket
        connect_sockaddr = ::Socket.sockaddr_in(dest_port, dest_addr)
        connect_socket.connect_nonblock(connect_sockaddr)

        ios = [accept_socket, connect_socket]
      rescue IO::WaitReadable
        if selected = IO.select(ios, ios, nil, CONNECTION_TIMEOUT)
          case selected
          when accept_socket
            [a_client_socket, a_addrinfo, :accept]
          when connect_socket
            [connect_socket, Addrinfo.new(sockaddr), :connect]
          end
        else
          raise Rendezvous::Errors::ActivityTimeout
        end
      end
    end
  end
end
