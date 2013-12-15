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

TODO: Write usage instructions here

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

## Inspiration

* http://www.brynosaurus.com/pub/net/p2pnat/
* https://github.com/dceballos/tcpnatr
* http://stackoverflow.com/a/14388707
