require "rendezvous/socket/version"
require "rendezvous/socket/accept_or_connect"
require "timeout"
require "excon"

Excon.defaults[:ssl_verify_peer] = false

module Rendezvous
  module Socket

    def self.new(url)
      RendezvousSocket.new(url)
    end

    class RendezvousSocket
      attr_reader :rendezvous_url

      def initialize(rendezvous_url)
        @rendezvous_url = rendezvous_url
      end

      def log(args={})
        start = Time.now
        puts args.merge(at: :start)
        result = yield
        elapsed = Time.now - start
        puts args.merge(at: :finish, elapsed: elapsed)
        result
(abcd[])
      end

      # lport=0 causes OS to select a random high port
      def get_peer_endpoint(lport=0)
        log(step: :get_peer_endpoint) {
          response = Excon.get(rendezvous_url, reuseaddr: true)
          rhost, rport = response.body.split(":")
          [response.local_port, response.local_address, rport.to_i, rhost]
        }
      end

      def peer_socket(lport, lhost, rport, rhost)
        log(step: :connect, lport: lport, rport: rport, rhost: rhost) {
          AcceptOrConnect.new(lport, lhost, rport, rhost).socket
        }
      end

      def open
        peer_socket(*get_peer_endpoint)
      end
    end
  end
end
