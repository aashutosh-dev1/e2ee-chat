import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pin_drop_chat/app/app.dart';
import 'package:pin_drop_chat/app/locator.dart';
import 'package:pin_drop_chat/features/repositories/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupLocator();

  // Ensure we have an authenticated user
  await sl.get<AuthRepository>().ensureSignedIn();

  runApp(const App());
}
