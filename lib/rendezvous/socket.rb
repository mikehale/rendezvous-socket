require "rendezvous/socket/version"
require "rendezvous/socket/custom_socket"
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
        super()
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
          response = Excon.get(rendezvous_server, reuseaddr: true)
          rhost, rport = response.body.split(":")
          [response.local_port, rhost, rport.to_i]
        }
      end

      def peer_socket(lport, rhost, rport)
        log(step: :connect, lport: lport, rhost: rhost, rport: rport) {
          punch_nat_nonblock(lport, rhost, rport)

          peer = CustomSocket.new
          peer.bind(lport)
          peer if peer.connect(rhost, rport)

          # acc = CustomSocket.new
          # acc.bind(lport)
          # acc.listen(5)
          # acc_conn,_ = acc.accept
          # acc_conn
        }
      end

      def peer_socket2(lport, rhost, rport)
        start = Time.now

        conn = CustomSocket.new
        conn.bind(lport)

        acc = CustomSocket.new
        acc.bind(lport)
        acc.listen(5)
        acc_conn = nil

        begin
          acc_conn,_ = acc.accept_nonblock
        rescue IO::WaitReadable, Errno::EINTR
          begin
            conn.connect_nonblock(rhost, rport)
          rescue IO::WaitWritable
          end

          p [(Time.now - start).to_f, :before_select]
          read_ready, write_ready, _ = IO.select([acc], [conn])
          p [(Time.now - start).to_f, :after_select]

          if read_ready.size > 0
            p [(Time.now - start).to_f, :using_acc]
            acc_conn,_ = acc.accept_nonblock
          end

          if write_ready.size > 0
            p [(Time.now - start).to_f, :using_conn]
            begin
              conn.connect_nonblock(rhost, rport)
            rescue Errno::EISCONN # already connected
            end
          end

        end

        acc_conn || conn
      end

      def open
        peer_socket(*get_peer_endpoint)
      end
    end
  end
end
