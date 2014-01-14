require "rendezvous/socket/version"
require "rendezvous/socket/custom_socket"
require "rendezvous/socket/accept_or_connect"
require "timeout"
require "excon"

module Rendezvous
  module Socket

    def self.new(server)
      RendezvousSocket.new(server)
    end

    class RendezvousSocket
      attr_reader :rendezvous_server

      def initialize(rendezvous_server)
        @rendezvous_server = rendezvous_server
      end

      def log(args={})
        start = Time.now
        puts args.merge(at: :start)
        result = yield
        elapsed = Time.now - start
        puts args.merge(at: :finish, elapsed: elapsed)
        result
      end

      def punch_nat_nonblock(lport, rhost, rport)
        log(step: :punch_nat) {
          #Thread.new do
            begin
              socket = CustomSocket.new
              # set ttl low enough so it crosses our nat but won't reach remote peer.
              socket.setsockopt(::Socket::IPPROTO_IP, ::Socket::IP_TTL, [2].pack("L"))
              socket.bind(lport)

              Timeout::timeout(0.3) do
                socket.connect(rhost,rport)
              end
            rescue Timeout::Error, Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
              socket.close
            end
        #end
        }
      end

      # lport=0 causes OS to select a random high port
      def get_peer_endpoint(lport=0)
        log(step: :get_peer_endpoint) {
          response = Excon.get("http://" + rendezvous_server, reuseaddr: true)
          rhost, rport = response.body.split(":")
          [response.local_port, response.local_address, rport.to_i, rhost]
        }
      end

      def peer_socket(lport, lhost, rport, rhost)
        log(step: :connect, lport: lport, rport: rport, rhost: rhost) {
          #punch_nat_nonblock(lport, rhost, rport)
          AcceptOrConnect.new(lport, lhost, rport, rhost).socket
        }
      end

      def open
        peer_socket(*get_peer_endpoint)
      end
    end
  end
end
