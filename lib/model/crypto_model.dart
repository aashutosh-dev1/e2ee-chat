class CryptoPayload {
  final String cipherB64;
  final String ivB64;
  final int version;
  CryptoPayload({required this.cipherB64, required this.ivB64, required this.version});

}