
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/app/locator.dart';
import 'package:pin_drop_chat/features/cubits/create_room_cubit/create_room_state.dart';
import 'package:pin_drop_chat/features/repositories/room_repository.dart';

class CreateRoomCubit extends Cubit<CreateRoomState> {
  CreateRoomCubit() : super(const CreateRoomInitial());

  final RoomRepository _roomRepo = sl.get<RoomRepository>();

  Future<void> create({
    required String roomName,
    required String username,
  }) async {
    emit(const CreateRoomLoading());
    try {
      final result = await _roomRepo.createRoom(
        name: roomName.trim(),
        username: username.trim(),
      );
      emit(CreateRoomSuccess(result));
    } catch (e) {
      emit(CreateRoomError(e.toString()));
    }
  }
}
