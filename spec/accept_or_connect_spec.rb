require 'spec_helper'

describe Rendezvous::AcceptOrConnect do
  it "creates a bi-directional connection" do
    lport1 = free_port
    lport2 = free_port
    host = '127.0.0.1'

    endpoint1 = described_class.new(lport1, host, lport2, host)
    endpoint2 = described_class.new(lport2, host, lport1, host)

    threads = []

    Thread.abort_on_exception = true
    from_s2 = nil
    from_s1 = nil
    threads << Thread.new {
      s1, _addrinfo, _type = endpoint1.socket
      s1.puts "from socket1"
      from_s2 = s1.gets
      s1.close
    }
    threads << Thread.new {
      s2, _addrinfo, _type = endpoint2.socket
      s2.puts "from socket2"
      from_s1 = s2.gets
      s2.close
    }

    threads.map(&:join)

    expect(from_s1).to eq("from socket1\n")
    expect(from_s2).to eq("from socket2\n")
  end

  def free_port
    s = Socket.new(:INET, :STREAM, 0)
    s.bind(::Socket.sockaddr_in(0, "127.0.0.1"))
    s.local_address.ip_port
  ensure
    s.close
  end
end
