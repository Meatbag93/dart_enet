import "dart:async";
import "dart:convert";
import "package:dart_enet/dart_enet.dart";

void main() async {
  const int messageCount = 5;
  final Host host = Host(channelLimit: 1, peerCount: 1);
  final Peer peer = host.connect(Address("127.0.0.1", 1234), 1);
  bool isRunning = true;
  bool isConnected = false;
  EnetEvent? event;
  while (isRunning) {
    event = host.service();
    if (event == null) {
      await Future.delayed(Duration(milliseconds: 10));
      continue;
    }
    if (!isConnected && event is ConnectEvent) {
      print("Connected!");
      isConnected = true;
      Timer.periodic(Duration(seconds: 1), (timer) async {
        peer.send(0, Packet(utf8.encode("Some content, ${timer.tick}")));
        if (timer.tick >= messageCount) {
          timer.cancel();
          peer.disconnectLater(data: 42);
          await Future.delayed(Duration(seconds: 1));
          isRunning = false;
          print("Good bye");
        }
      });
    }
    if (event is ReceiveEvent) {
      print("Server says ${utf8.decode(event.packet.data)}");
    }
  }
  deinitializeEnet();
}
