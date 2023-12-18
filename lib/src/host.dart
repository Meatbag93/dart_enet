import "dart:ffi";
import "package:ffi/ffi.dart";
import "./exceptions.dart";
import "./enet.dart";
import "./bindings.dart";
import "./packet.dart";
import "./address.dart";
import "./peer.dart";
import "./event.dart";

/// An ENet host for communicating with [Peer]s.
final class Host implements Finalizable {
  static final _finalizer =
      NativeFinalizer(bindings.addresses.enet_host_destroy.cast());

  /// the address at which other peers may connect to this host. If null, then no peers may connect to the host, So it's a client-only host. Default null.
  final Address? address;

  /// the maximum number of peers that should be allocated for [this] host.
  final int peerCount;

  /// the maximum number of channels allowed; if 0, than it's the same as the max allowed channels.
  final int channelLimit;

  /// downstream bandwidth of the host in bytes/second; if 0, ENet will assume unlimited bandwidth. Default 0
  final int incomingBandwidth;

  /// upstream bandwidth of the host in bytes/second; if 0, ENet will assume unlimited bandwidth. Default 0
  final int outgoingBandwidth;
  late final Pointer<ENetHost> _host;
  Host(
      {this.address,
      required this.channelLimit,
      required this.peerCount,
      this.incomingBandwidth = 0,
      this.outgoingBandwidth = 0}) {
    _host = bindings.enet_host_create(
        (address != null ? address!.pointer : nullptr),
        peerCount,
        channelLimit,
        incomingBandwidth,
        outgoingBandwidth);
    if (_host == nullptr) {
      throw StateError("Host couldn't be created.");
    }
    _finalizer.attach(this, _host.cast(), detach: this);
  }

  /// Initiates a connection to a foreign host.
  ///
  /// The peer returned will have not completed the connection until a connect event is received for the returned peer.
  Peer connect(Address address, int channelCount, {int data = 0}) {
    Pointer<ENetPeer> cPeer =
        bindings.enet_host_connect(_host, address.pointer, channelCount, data);
    if (cPeer == nullptr) {
      throw StateError("Couldn't connect.");
    }
    return Peer(this, cPeer);
  }

  /// returns the first queued event on [this] host and shuttles packets between the host and its peers. If no event is queued when this method is called, null is returned.
  ///
  /// Must be called continuously, as frequently as possible, as this method is responsible for sending and receiving packets.
  EnetEvent? service() {
    Pointer<ENetEvent> cEvent = malloc<ENetEvent>();
    int err = bindings.enet_host_service(_host, cEvent, 0);
    try {
      if (err == 0) return null;
      throwIfEnetError(err);
      return EnetEvent.fromENetEvent(this, cEvent.ref);
    } finally {
      malloc.free(cEvent);
    }
  }

  /// Sends any queued packets on [this] hosts to its designated peers.
  void flush() {
    bindings.enet_host_flush(_host);
  }

  /// Queues [packet] to be sent to all peers associated with [this] host.
  void broadcast(int channelID, Packet packet) {
    packet.makeAsSent();
    bindings.enet_host_broadcast(_host, channelID, packet.pointer);
  }
}
