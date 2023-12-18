/// States for a [Peer].
abstract final class PeerState {
  static const int disconnected = 0;
  static const int connecting = 1;
  static const int acknowledgingConnect = 2;
  static const int connectionPending = 3;
  static const int connectionSucceeded = 4;
  static const int connected = 5;
  static const int disconnectLater = 6;
  static const int disconnecting = 7;
  static const int acknowledgingDisconnect = 8;
  static const int zombie = 9;
}
