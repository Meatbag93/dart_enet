import "dart:ffi";
import "./enet.dart";
import "./exceptions.dart";
import "./bindings.dart";
import "./packet.dart";
import "./address.dart";
import "./host.dart";

/// An ENet peer which data packets may be sent or received from.
///
/// This class should not be instantiated directly.
class Peer {
  static const int packetLossScale = ENET_PEER_PACKET_LOSS_SCALE;
  late final Pointer<ENetPeer> _peer;
  final Host
      // ignore: unused_field
      _host; // For garbage collection: to prevent the host related to this peer from being garbage collected.

  /// @nodoc
  Peer(this._host, this._peer);

  /// Queues a packet to be sent.
  void send(int channelID, Packet packet) {
    packet.makeAsSent();
    int err = bindings.enet_peer_send(_peer, channelID, packet.pointer);
    throwIfEnetError(err);
  }

  /// Forcefully disconnects [this].
  ///
  /// The foreign host represented by [this] is not notified of the disconnection and will timeout on its connection to the local host.
  void reset() => bindings.enet_peer_reset(_peer);

  /// Sends a ping request to a peer.
  ///
  /// ping requests factor into the mean round trip time as designated by the [roundTripTime] field. ENet automatically pings all connected peers at regular intervals, however, this function may be called to ensure more frequent ping requests.
  void ping() => bindings.enet_peer_ping(_peer);

  /// Request a disconnection from a peer.
  ///
  /// Optionally, you can pass an integer that will be sent to the peer with the disconnect request. By default, it is 0.
  ///
  /// a disconnect event will be generated once the disconnection is complete.
  void disconnect({int data = 0}) => bindings.enet_peer_disconnect(_peer, data);

  /// Request a disconnection from a peer, but only after all queued outgoing packets are sent.
  ///
  /// Optionally, you can pass an integer that will be sent to the peer with the disconnect request. By default, it is 0.
  ///
  /// a disconnect event will be generated once the disconnection is complete.
  void disconnectLater({int data = 0}) =>
      bindings.enet_peer_disconnect_later(_peer, data);

  /// Force an immediate disconnection from a peer.
  ///
  /// Optionally, you can pass an integer that will be sent to the peer with the disconnect request. By default, it is 0.
  ///
  /// No disconnect event will be generated. The foreign peer is not guaranteed to receive the disconnect notification, and is reset immediately upon return from this function.
  void disconnectNow({int data = 0}) =>
      bindings.enet_peer_disconnect_now(_peer, data);

  /// The state of [this] peer. See [PeerState]
  int get state => _peer.ref.state;

  /// Number of channels allocated for communication with [this] peer
  int get channelCount => _peer.ref.channelCount;

  /// The internet address of [this] peer.
  Address get address => Address.fromStruct(_peer.ref.address);

  /// Downstream bandwidth in bytes/second.
  int get incomingBandwidth => _peer.ref.incomingBandwidth;

  /// Upstream bandwidth in bytes/second.
  int get outgoingBandwidth => _peer.ref.outgoingBandwidth;

  /// mean packet loss of reliable packets as a ratio with respect to the constant [packetLossScale]
  int get packetLoss => _peer.ref.packetLoss;

  /// mean round trip time (RTT), in milliseconds, between sending a reliable packet and receiving its acknowledgement
  int get roundTripTime => _peer.ref.roundTripTime;

  /// rate at which to increase the throttle probability as mean RTT declines
  int get packetThrottleAcceleration => _peer.ref.packetThrottleAcceleration;
  set packetThrottleAcceleration(int value) =>
      bindings.enet_peer_throttle_configure(
          _peer, packetThrottleInterval, value, packetThrottleDeceleration);

  /// rate at which to decrease the throttle probability as mean RTT increases
  int get packetThrottleDeceleration => _peer.ref.packetThrottleDeceleration;
  set packetThrottleDeceleration(int value) =>
      bindings.enet_peer_throttle_configure(
          _peer, packetThrottleInterval, packetThrottleAcceleration, value);

  /// interval, in milliseconds, over which to measure lowest mean RTT;
  int get packetThrottleInterval => _peer.ref.packetThrottleInterval;
  set packetThrottleInterval(int value) =>
      bindings.enet_peer_throttle_configure(
          _peer, value, packetThrottleAcceleration, packetThrottleDeceleration);
  //@override
  @override
  int get hashCode => _peer.address;

  @override
  bool operator ==(Object other) {
    return (other is Peer && other.hashCode == hashCode);
  }
}
