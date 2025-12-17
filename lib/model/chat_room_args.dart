class ChatRoomArgs {
  ChatRoomArgs({
    required this.roomId,
    required this.roomName,
    required this.pin,
    required this.joinedAt,
  });

  final String roomId;
  final String roomName;
  final String pin;
  final DateTime joinedAt;
}
