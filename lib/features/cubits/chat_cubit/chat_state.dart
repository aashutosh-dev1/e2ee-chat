
import 'package:equatable/equatable.dart';

sealed class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ChatReady extends ChatState {
  const ChatReady({
    required this.roomId,
    required this.roomName,
    required this.username,
    required this.messages,
    required this.members,
  });

  final String roomId;
  final String roomName;
  final String username;
  final List<ChatMessageVM> messages;
  final List<MemberVM> members;

  @override
  List<Object?> get props => [roomId, roomName, username, messages, members];
}

class ChatMessageVM extends Equatable {
  const ChatMessageVM({
    required this.senderName,
    required this.text,
    required this.isMine,
    required this.isDecryptionFailed,
  });

  final String senderName;
  final String text;
  final bool isMine;
  final bool isDecryptionFailed;

  @override
  List<Object?> get props => [senderName, text, isMine, isDecryptionFailed];
}

class MemberVM extends Equatable {
  const MemberVM({required this.username});
  final String username;

  @override
  List<Object?> get props => [username];
}