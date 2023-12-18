import "./enet.dart";
import "./packet.dart";
import "./peer.dart";
import "./host.dart";

/// Base class for representing events.
class EnetEvent {
  /// The [Peer] that generated the event.
  final Peer peer;

  EnetEvent({required this.peer});

  /// @nodoc
  // Factory method to create an event from an ENetEvent.
  static EnetEvent? fromENetEvent(Host host, ENetEvent event) {
    switch (event.type) {
      case ENetEventType.ENET_EVENT_TYPE_CONNECT:
        return ConnectEvent(peer: Peer(host, event.peer));
      case ENetEventType.ENET_EVENT_TYPE_DISCONNECT:
        return DisconnectEvent(peer: Peer(host, event.peer), data: event.data);
      case ENetEventType.ENET_EVENT_TYPE_RECEIVE:
        return ReceiveEvent(
          peer: Peer(host, event.peer),
          channelID: event.channelID,
          packet: Packet.fromPointer(event.packet),
        );
      default:
        return null;
    }
  }
}

/// Represents a connect event.
///
/// a connection request has completed.
///
/// The peer field contains the peer which successfully connected.
class ConnectEvent extends EnetEvent {
  ConnectEvent({required Peer peer}) : super(peer: peer);
}

/// Represents a disconnect event.
///
/// This event is generated on a successful completion of a disconnect initiated by [Peer.disconnect], if a peer has timed out, or if a connection request initialized by [Host.connect] has timed out.
///
/// The [peer] field contains the peer which disconnected.
class DisconnectEvent extends EnetEvent {
  /// user supplied data describing the disconnection, or 0, if none is available.
  final int data;

  DisconnectEvent({required Peer peer, required this.data}) : super(peer: peer);
}

/// Represents a receive event.
///
/// The [peer] field specifies the [Peer] which sent the [packet].
class ReceiveEvent extends EnetEvent {
  /// the channel number upon which the packet was received.
  final int channelID;

  /// the packet that was received
  final Packet packet;

  ReceiveEvent(
      {required Peer peer, required this.channelID, required this.packet})
      : super(peer: peer);
}

/// Factory method