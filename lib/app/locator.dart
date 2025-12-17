import 'package:get_it/get_it.dart';
import 'package:pin_drop_chat/features/repositories/auth_repository.dart';
import 'package:pin_drop_chat/features/repositories/message_repository.dart';
import 'package:pin_drop_chat/features/repositories/room_repository.dart';
import 'package:pin_drop_chat/features/services/crypto_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


final sl = GetIt.instance;

Future<void> setupLocator() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Services
  sl.registerLazySingleton<CryptoService>(() => CryptoService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton<RoomRepository>(() => RoomRepository());
  sl.registerLazySingleton<MessageRepository>(() => MessageRepository());
}
