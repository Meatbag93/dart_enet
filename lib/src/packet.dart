import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import './enet.dart';
import './bindings.dart';

/// An ENet data packet that may be sent to or received from a [Peer].
class Packet implements Finalizable {
  static final _finalizer =
      NativeFinalizer(bindings.addresses.enet_packet_destroy.cast());

  final Uint8List data;

  /// see [PacketFlags]
  final int flags;
  late final Pointer<ENetPacket> _packet;

  /// @nodoc
  Packet.fromPointer(Pointer<ENetPacket> packet)
      : _packet = packet,
        data = _extractDataFromPointer(packet),
        flags = packet.ref.flags {
    _finalizer.attach(this, _packet.cast(), detach: this);
  }

  Packet(this.data, {this.flags = 0}) {
    _packet = _createENetPacket();
    _finalizer.attach(this, _packet.cast(), detach: this);
  }

  /// @nodoc
  void makeAsSent() {
    _finalizer.detach(this);
  }

  /// @nodoc
  Pointer<ENetPacket> get pointer => _packet;

  static Uint8List _extractDataFromPointer(Pointer<ENetPacket> packet) {
    return Uint8List.fromList(
        packet.ref.data.cast<Uint8>().asTypedList(packet.ref.dataLength));
  }

  Pointer<ENetPacket> _createENetPacket() {
    final Pointer<Uint8> cData = malloc<Uint8>(data.length);
    cData.asTypedList(data.length).setAll(0, data);
    final packet =
        bindings.enet_packet_create(cData.cast(), data.length, flags);
    malloc.free(cData);

    if (packet == nullptr) {
      throw StateError("Failed to create Packet");
    }

    return packet;
  }
}
