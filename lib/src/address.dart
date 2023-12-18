import "dart:ffi";
import "package:ffi/ffi.dart";
import "./enet.dart";
import "./exceptions.dart";
import "./bindings.dart";

/// Represents an internet address
final class Address implements Finalizable {
  static const int _maxHostName = 257;
  static final _finalizer = NativeFinalizer(calloc.nativeFree);
  late final Pointer<ENetAddress> _address;

  /// @nodoc
  Address.fromStruct(ENetAddress struct) {
    _address = calloc<ENetAddress>();
    _finalizer.attach(this, _address.cast(), detach: this);
    _address.ref = struct;
  }
  Address(String host, int port) {
    _address = calloc<ENetAddress>();
    _finalizer.attach(this, _address.cast(), detach: this);
    this.host = host;
    this.port = port;
  }

  /// The hostname [this] refers to.
  ///
  /// This value can be "*", which means any
  String get host {
    if (_address.ref.host == ENET_HOST_ANY) {
      return "*";
    }
    Pointer<Char> host = calloc<Char>(_maxHostName);
    try {
      int err = bindings.enet_address_get_host_ip(_address, host, _maxHostName);
      throwIfEnetError(err);
      return host.cast<Utf8>().toDartString();
    } finally {
      calloc.free(host);
    }
  }

  set host(String value) {
    if (value.isEmpty || value == "*") {
      _address.ref.host = ENET_HOST_ANY;
      return;
    }
    Pointer<Utf8> cValue = value.toNativeUtf8();
    int err = bindings.enet_address_set_host(_address, cValue.cast<Char>());
    calloc.free(cValue);
    throwIfEnetError(err);
  }

  /// The port that [this] uses. Can be between 0 and 65535
  int get port => _address.ref.port;
  set port(int value) => _address.ref.port = value;

  /// @nodoc
  // for internal use only. If you were wondering what this is for, don't use it.
  Pointer<ENetAddress> get pointer => _address;
}
