import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/app/locator.dart';
import 'package:pin_drop_chat/features/cubits/join_room_cubit/join_room_state.dart';
import 'package:pin_drop_chat/features/repositories/room_repository.dart';

class JoinRoomCubit extends Cubit<JoinRoomState> {
  JoinRoomCubit() : super(const JoinRoomInitial());

  final RoomRepository _roomRepo = sl.get<RoomRepository>();

  Future<void> join({
    required String roomId,
    required String username,
  }) async {
    emit(const JoinRoomLoading());
    try {
      final roomName = await _roomRepo.fetchRoomName(roomId.trim());
      final joinedAt = await _roomRepo.joinRoom(roomId: roomId.trim(), username: username.trim());
      emit(JoinRoomSuccess(roomId: roomId.trim(), roomName: roomName, joinedAt: joinedAt));
    } catch (e) {
      emit(JoinRoomError(e.toString()));
    }
  }
}