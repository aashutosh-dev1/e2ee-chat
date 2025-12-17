import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/app/locator.dart';
import 'package:pin_drop_chat/features/cubits/chat_cubit/chat_state.dart';
import 'package:pin_drop_chat/features/repositories/message_repository.dart';
import 'package:pin_drop_chat/features/repositories/room_repository.dart';
import 'package:pin_drop_chat/features/services/crypto_service.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.roomId,
    required this.roomName,
    required this.username,
    required this.joinedAt,
    required this.pin,
  }) : super(const ChatLoading());

  final String roomId;
  final String roomName;
  final String username;
  final DateTime joinedAt;
  final String pin;

  final RoomRepository _roomRepo = sl.get<RoomRepository>();
  final MessageRepository _messageRepo = sl.get<MessageRepository>();
  final CryptoService _crypto = sl.get<CryptoService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _msgSub;
  StreamSubscription? _membersSub;

  late final SecretKey _key;

  Future<void> start() async {
    try {
      final salt = await _roomRepo.fetchRoomSalt(roomId);
      _key = await _crypto.deriveKey(pin: pin, salt: salt);

      final uid = _auth.currentUser!.uid;

      _membersSub = _roomRepo.membersStream(roomId).listen((members) {
        final current = state;
        if (current is ChatReady) {
          emit(ChatReady(
            roomId: roomId,
            roomName: roomName,
            username: username,
            messages: current.messages,
            members: members.map((m) => MemberVM(username: m['username'] as String)).toList(),
          ));
        }
      });

      _msgSub = _messageRepo.messagesSinceJoin(roomId: roomId, joinedAt: joinedAt).listen((snap) async {
        final out = <ChatMessageVM>[];

        for (final d in snap.docs) {
          final data = d.data();
          final senderId = (data['senderId'] as String?) ?? '';
          final senderName = (data['senderName'] as String?) ?? 'Unknown';
          final cipherB64 = (data['cipherB64'] as String?) ?? '';
          final ivB64 = (data['ivB64'] as String?) ?? '';

          try {
            final text = await _crypto.decrypt(key: _key, cipherB64: cipherB64, ivB64: ivB64);
            out.add(ChatMessageVM(
              senderName: senderName,
              text: text,
              isMine: senderId == uid,
              isDecryptionFailed: false,
            ));
          } catch (_) {
            out.add(ChatMessageVM(
              senderName: senderName,
              text: 'Unable to decrypt message (wrong PIN?)',
              isMine: senderId == uid,
              isDecryptionFailed: true,
            ));
          }
        }

        final members = (state is ChatReady) ? (state as ChatReady).members : <MemberVM>[];
        emit(ChatReady(
          roomId: roomId,
          roomName: roomName,
          username: username,
          messages: out,
          members: members,
        ));
      });

      emit(ChatReady(
        roomId: roomId,
        roomName: roomName,
        username: username,
        messages: const [],
        members: const [],
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> send(String text) async {
    final uid = _auth.currentUser!.uid;
    final payload = await _crypto.encrypt(key: _key, plaintext: text);

    await _messageRepo.sendEncryptedMessage(
      roomId: roomId,
      senderId: uid,
      senderName: username,
      cipherB64: payload.cipherB64,
      ivB64: payload.ivB64,
      version: payload.version,
    );
  }

  @override
  Future<void> close() async {
    await _msgSub?.cancel();
    await _membersSub?.cancel();
    return super.close();
  }
}