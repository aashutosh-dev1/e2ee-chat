import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesSinceJoin({
    required String roomId,
    required DateTime joinedAt,
  }) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(joinedAt))
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> sendEncryptedMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String cipherB64,
    required String ivB64,
    required int version,
  }) async {
    await _db.collection('rooms').doc(roomId).collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'cipherB64': cipherB64,
      'ivB64': ivB64,
      'version': version,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
