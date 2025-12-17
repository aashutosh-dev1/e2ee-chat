import 'package:equatable/equatable.dart';

sealed class JoinRoomState extends Equatable {
  const JoinRoomState();
  @override
  List<Object?> get props => [];
}

class JoinRoomInitial extends JoinRoomState {
  const JoinRoomInitial();
}

class JoinRoomLoading extends JoinRoomState {
  const JoinRoomLoading();
}

class JoinRoomSuccess extends JoinRoomState {
  const JoinRoomSuccess({
    required this.roomId,
    required this.roomName,
    required this.joinedAt,
  });

  final String roomId;
  final String roomName;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [roomId, roomName, joinedAt];
}

class JoinRoomError extends JoinRoomState {
  const JoinRoomError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
