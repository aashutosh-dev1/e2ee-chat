import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_drop_chat/model/create_room_model.dart';

class RoomRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Avoid confusing characters: I, O, 0, 1
  static const String _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _generatePin() {
    final rnd = Random.secure();
    final value = 100000 + rnd.nextInt(900000); // 6 digits
    return value.toString();
  }

  /// Generates a short 4-character room ID like A7K3
  String _generateRoomCode() {
    final rnd = Random.secure();
    return List.generate(4, (_) => _alphabet[rnd.nextInt(_alphabet.length)]).join();
  }

  Uint8List _generateSalt() {
    final rnd = Random.secure();
    return Uint8List.fromList(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  /// Creates room with a short ID (4 chars).
  /// Uses transaction to avoid collisions; retries if code already exists.
  Future<CreateRoomResult> createRoom({
    required String name,
    required String username,
  }) async {
    final uid = _auth.currentUser!.uid;
    final pin = _generatePin();
    final salt = _generateSalt();
    final saltB64 = base64Encode(salt);

    // Retry to avoid collisions (very rare, but possible).
    for (int attempt = 0; attempt < 10; attempt++) {
      final roomCode = _generateRoomCode();
      final roomRef = _db.collection('rooms').doc(roomCode);

      try {
        await _db.runTransaction((tx) async {
          final existing = await tx.get(roomRef);
          if (existing.exists) {
            // Collision -> retry
            throw StateError('ROOM_CODE_TAKEN');
          }

          tx.set(roomRef, {
            'name': name,
            'createdAt': FieldValue.serverTimestamp(),
            'createdBy': uid,
            'saltB64': saltB64, // public (PIN is NOT stored)
          });

          tx.set(roomRef.collection('members').doc(uid), {
            'uid': uid,
            'username': username,
            'joinedAt': FieldValue.serverTimestamp(),
            'lastSeenAt': FieldValue.serverTimestamp(),
          });
        });

        // Success
        return CreateRoomResult(roomId: roomCode, pin: pin);
      } catch (e) {
        if (e is StateError && e.message == 'ROOM_CODE_TAKEN') {
          continue; // retry
        }
        rethrow; // real error
      }
    }

    throw Exception('Failed to generate a unique room code. Please try again.');
  }

  Future<String> fetchRoomName(String roomId) async {
    final snap = await _db.collection('rooms').doc(roomId).get();
    if (!snap.exists) throw Exception('Room not found');
    return (snap.data()!['name'] as String?) ?? 'Chat Room';
  }

  Future<Uint8List> fetchRoomSalt(String roomId) async {
    final snap = await _db.collection('rooms').doc(roomId).get();
    if (!snap.exists) throw Exception('Room not found');
    final saltB64 = (snap.data()!['saltB64'] as String);
    return Uint8List.fromList(base64Decode(saltB64));
  }

  Future<DateTime> joinRoom({
    required String roomId,
    required String username,
  }) async {
    final uid = _auth.currentUser!.uid;
    final memberRef = _db.collection('rooms').doc(roomId).collection('members').doc(uid);

    final existing = await memberRef.get();
    if (existing.exists) {
      final ts = existing.data()!['joinedAt'] as Timestamp;
      return ts.toDate();
    }

    await memberRef.set({
      'uid': uid,
      'username': username,
      'joinedAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    });

    final confirmed = await memberRef.get();
    final ts = confirmed.data()!['joinedAt'] as Timestamp;
    return ts.toDate();
  }

  Stream<List<Map<String, dynamic>>> membersStream(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('members')
        .orderBy('joinedAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }
}
