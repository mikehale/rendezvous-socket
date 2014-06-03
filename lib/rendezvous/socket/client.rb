module Rendezvous
  class Client
    def initialize(ip, port, socket)
      p [ip, port, socket]
    end

    def self.connect(ip, port, local_port)
      socket = CustomSocket.new
      socket.bind(local_port)
      Timeout::timeout(2) {
        socket.connect(ip, port)
        self.new(ip, port, socket)
      }
      true
    rescue Timeout::Error, Errno::ECONNREFUSED
      false
    end

    def self.accept(ip, port)
      server = CustomSocket.new
      server.bind
      server.listen(5)
      send_syn!(ip, port, server.local_port)
      Thread.new do
        begin
          Timeout::timeout(5) {
            session = server.accept
            self.new(ip, port, session)
          }
        rescue Timeout::Error
        end
      end
      server.local_port
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
