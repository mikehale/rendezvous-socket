# Rendezvous Socket

Using the help of a well known rendezvous endpoint establish a peer to
peer connection between clients which may be behind NAT firewalls. In
the event that NAT traversal techniques are not successful fallback to
relaying the connection through the rendezvous server. All connections
are SSL encrypted. Sessions are managed by the server.

TODO:
* Server managed sessions
* SSL
* Clean interface (as similar to socket interface as possible)
* Fallback to relay mode
