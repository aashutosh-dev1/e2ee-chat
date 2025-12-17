import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:pin_drop_chat/model/crypto_model.dart';



class CryptoService {
  final _algo = AesGcm.with256bits();

  Future<SecretKey> deriveKey({
    required String pin,
    required Uint8List salt,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 120000,
      bits: 256,
    );

    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
  }

  Future<CryptoPayload> encrypt({
    required SecretKey key,
    required String plaintext,
  }) async {
    final nonce = _algo.newNonce();
    final secretBox = await _algo.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );

    return CryptoPayload(
      cipherB64: base64Encode(secretBox.concatenation()),
      ivB64: base64Encode(nonce),
      version: 1,
    );
  }

  Future<String> decrypt({
    required SecretKey key,
    required String cipherB64,
    required String ivB64,
  }) async {
    final nonce = base64Decode(ivB64);
    final combined = base64Decode(cipherB64);

    final secretBox = SecretBox.fromConcatenation(
      combined,
      nonceLength: nonce.length,
      macLength: 16,
    );

    final clear = await _algo.decrypt(secretBox, secretKey: key);
    return utf8.decode(clear);
  }
}
