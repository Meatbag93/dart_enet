/// Bitwise flags for packets.
abstract final class PacketFlags {
  /// packet must be received by the target peer and resend attempts should be made until the packet is delivered
  static const int reliable = (1 << 0);

  /// packet will not be sequenced with other packets. Not supported for reliable packets.
  static const int unsequenced = (1 << 1);

  /// packet will be fragmented using unreliable (instead of reliable) sends if it exceeds the MTU.
  static const int unreliableFragment = (1 << 3);
}
