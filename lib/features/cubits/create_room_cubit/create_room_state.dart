import 'package:equatable/equatable.dart';
import 'package:pin_drop_chat/model/create_room_model.dart';

sealed class CreateRoomState extends Equatable {
  const CreateRoomState();
  @override
  List<Object?> get props => [];
}

class CreateRoomInitial extends CreateRoomState {
  const CreateRoomInitial();
}

class CreateRoomLoading extends CreateRoomState {
  const CreateRoomLoading();
}

class CreateRoomSuccess extends CreateRoomState {
  const CreateRoomSuccess(this.result);
  final CreateRoomResult result;

  @override
  List<Object?> get props => [result.roomId, result.pin];
}

class CreateRoomError extends CreateRoomState {
  const CreateRoomError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
