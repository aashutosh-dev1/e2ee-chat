import 'package:flutter/material.dart';
import 'package:pin_drop_chat/features/screen/chat_room_page.dart';
import 'package:pin_drop_chat/features/screen/create_room_page.dart';
import 'package:pin_drop_chat/features/screen/home_page.dart';
import 'package:pin_drop_chat/features/screen/join_room_page.dart';
import 'package:pin_drop_chat/features/screen/username_page.dart';
import 'package:pin_drop_chat/model/chat_room_args.dart';

class AppRoutes {
  static const username = '/';
  static const home = '/home';
  static const createRoom = '/create-room';
  static const joinRoom = '/join-room';
  static const chatRoom = '/chat-room';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case username:
        return MaterialPageRoute(builder: (_) => const UsernamePage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case createRoom:
        return MaterialPageRoute(builder: (_) => const CreateRoomPage());
      case joinRoom:
        return MaterialPageRoute(builder: (_) => const JoinRoomPage());

      case chatRoom:
        final args = settings.arguments as ChatRoomArgs;
        return MaterialPageRoute(
          builder: (_) => ChatRoomPage(args: args),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
