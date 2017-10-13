# Rendezvous::Socket

Using the help of a known publically routable [rendezvous-server](https://github.com/mikehale/rendezvous-server) endpoint establish a peer to
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

1. [Deploy the server](https://github.com/mikehale/rendezvous-server#heroku-deploy)
2. On 2 peer machines that wish to establish a direct connection with each other run the client.

  ```bash
  RENDEZVOUS_URL=https://rendezvous-server.herokuapp.com rendezvous-client
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

* SSL
* Server managed sessions
* Clean interface (as similar to socket interface as possible)
* Fallback to relay mode
* Link local connection attempt
* Figure out why linux does not even attempt to send packets somtimes. Connect vs Accept first?

## Inspiration

* http://www.brynosaurus.com/pub/net/p2pnat/
* https://github.com/dceballos/tcpnatr
* http://stackoverflow.com/a/14388707
* http://nutss.gforge.cis.cornell.edu/pub/imc05-tcpnat.pdf
