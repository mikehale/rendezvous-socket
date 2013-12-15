require "rendezvous/socket/version"
require "rendezvous/socket/custom_socket"

module Rendezvous
  module Socket

    def self.new(server)
      RendezvousSocket.new(server)
    end

    class RendezvousSocket
      attr_reader :rendezvous_server

      def initialize(rendezvous_server)
        @rendezvous_server = rendezvous_server
        super()
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
  end
end
