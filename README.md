# Rendezvous::Socket

Using the help of a well known rendezvous endpoint establish a peer to
peer connection between clients which may be behind NAT firewalls. In
the event that NAT traversal techniques are not successful fallback to
relaying the connection through the rendezvous server. All connections
are SSL encrypted. Sessions are managed by the server.

## Installation

Add this line to your application's Gemfile:

    gem 'rendezvous-socket'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rendezvous-socket

## Usage

1. On a server with a known IP address run the server.

  ```bash
  git clone https://github.com/mikehale/rendezvous-server.git
  cd rendezvous-server
  gem install foreman
  bundle install
  foreman start
  ```
2. On 2 peer machines that wish to establish a direct connection with each other run the client.

  ```bash
  RENDEZVOUS_SERVER=n.n.n.n:5000 bin/rendezvous-client
  ```

You will know it worked when you see the hostname of each peer in the
output of it's peer.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

* Server managed sessions
* SSL
* Clean interface (as similar to socket interface as possible)
* Fallback to relay mode
* Link local connection attempt

## Inspiration

* http://www.brynosaurus.com/pub/net/p2pnat/
* https://github.com/dceballos/tcpnatr
* http://stackoverflow.com/a/14388707
