import "dart:convert";
import "dart:io";
import "package:dart_enet/dart_enet.dart";

void main() async {
  final Host host =
      Host(address: Address("*", 1234), channelLimit: 1, peerCount: 32);
  EnetEvent? event;
  ProcessSignal.sigint.watch().listen((event) {
    deinitializeEnet();
    print("Good bye.");
    exit(0);
  });

  print("ctrl+c to quit");
  while (true) {
    event = host.service();
    if (event == null) {
      await Future.delayed(Duration(milliseconds: 10));
      continue;
    }
    String addr = event.peer.address.host;
    if (event is ConnectEvent) {
      print("Connect event from $addr");
    } else if (event is DisconnectEvent) {
      print("Disconnect event from $addr, with data ${event.data}");
    } else if (event is ReceiveEvent) {
      String contents = utf8.decode(event.packet.data);
      print("$addr says: $contents");
      event.peer.send(0, Packet(utf8.encode("I got your message: $contents")));
    }
  }
}
