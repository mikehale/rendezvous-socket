module Rendezvous
  class Client
    def initialize(ip, port, socket, type)
      p [ip, port, socket]
      [socket, nil, type]
    end

    def self.connect(ip, port, local_port)
      socket = CustomSocket.new
      socket.bind(local_port)
      Timeout::timeout(5) {
        socket.connect(ip, port)
        self.new(ip, port, socket, :connect)
      }
    rescue Timeout::Error, Errno::ECONNREFUSED
      false
    end

    def self.accept(ip, port, local_port)
      server = CustomSocket.new
      server.bind(local_port)
      server.listen(5)
      send_syn!(ip, port, local_port)
      begin
        Timeout::timeout(5) {
          session = server.accept
          self.new(ip, port, session, :accept)
        }
      rescue Timeout::Error
        false
      end
    end

    def self.send_syn!(ip, port, local_port)
      socket = CustomSocket.new
      socket.bind(local_port)
      Timeout::timeout(0.3) {
        socket.connect(ip, port)
      }
    rescue Timeout::Error
    rescue # Errno errors
    ensure
      if socket && !socket.closed?
        socket.close
      end
    end
  end
end
