import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/app/locator.dart';
import 'package:pin_drop_chat/core/constants.dart';
import 'package:pin_drop_chat/features/cubits/username_cubit/username_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsernameCubit extends Cubit<UsernameState> {
  UsernameCubit() : super(const UsernameState(username: '')) {
    _load();
  }

  final SharedPreferences _prefs = sl.get<SharedPreferences>();

  void _load() {
    final name = _prefs.getString(AppKeys.username) ?? '';
    emit(UsernameState(username: name));
  }

  Future<void> save(String username) async {
    await _prefs.setString(AppKeys.username, username.trim());
    emit(UsernameState(username: username.trim()));
  }
}