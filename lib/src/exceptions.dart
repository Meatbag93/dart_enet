void throwIfEnetError(int err) {
  if (err < 0) {
    throw EnetError(err);
  }
}

/// ENet does not have defined error codes; the error is just a number below 0
class EnetError extends Error {
  final int code;
  EnetError(this.code);
  @override
  String toString() => "Enet error: Error code $code";
}
