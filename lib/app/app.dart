import 'package:flutter/material.dart';
import 'package:pin_drop_chat/app/routes/routes.dart';

import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pindrop Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.username,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
