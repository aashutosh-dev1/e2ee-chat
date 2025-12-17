import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/app/locator.dart';
import 'package:pin_drop_chat/core/constants.dart';
import 'package:pin_drop_chat/features/cubits/room_cubit/room_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomsCubit extends Cubit<RoomsState> {
  RoomsCubit() : super(const RoomsState(recentRoomIds: [])) {
    load();
  }

  final SharedPreferences _prefs = sl.get<SharedPreferences>();

  void load() {
    final raw = _prefs.getString(AppKeys.recentRooms) ?? '';
    final rooms = raw.isEmpty
        ? <String>[]
        : raw.split(',').where((e) => e.isNotEmpty).toList();
    emit(RoomsState(recentRoomIds: rooms));
  }

  Future<void> addRecent(String roomId) async {
    final current = [...state.recentRoomIds];
    current.remove(roomId);
    current.insert(0, roomId);
    final capped = current.take(10).toList();

    await _prefs.setString(AppKeys.recentRooms, capped.join(','));
    emit(RoomsState(recentRoomIds: capped));
  }
}
