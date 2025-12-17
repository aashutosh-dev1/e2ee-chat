import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/app/routes/routes.dart';
import 'package:pin_drop_chat/features/cubits/join_room_cubit/join_room_cubit.dart';
import 'package:pin_drop_chat/features/cubits/join_room_cubit/join_room_state.dart';
import 'package:pin_drop_chat/features/cubits/room_cubit/room_cubit.dart';
import 'package:pin_drop_chat/features/extensions/context_x.dart';
import 'package:pin_drop_chat/features/extensions/string_x.dart';
import 'package:pin_drop_chat/model/chat_room_args.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/locator.dart';
import '../../../../core/constants.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _roomId = TextEditingController();
  final _pin = TextEditingController();

  String _username() => sl.get<SharedPreferences>().getString(AppKeys.username) ?? '';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => JoinRoomCubit()),
        BlocProvider(create: (_) => RoomsCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Join Room')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocConsumer<JoinRoomCubit, JoinRoomState>(
            listener: (context, state) async {
              if (state is JoinRoomSuccess) {
                await context.read<RoomsCubit>().addRecent(state.roomId);
                if (!context.mounted) return;

                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.chatRoom,
                  arguments: ChatRoomArgs(
                    roomId: state.roomId,
                    roomName: state.roomName,
                    pin: _pin.text.trim(),
                    joinedAt: state.joinedAt,
                  ),
                );
              }

              if (state is JoinRoomError) {
                context.snack(state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state is JoinRoomLoading;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Enter Chat Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _roomId,
                    decoration: const InputDecoration(
                      labelText: 'Chat Room ID',
                      hintText: 'e.g., SecureChat-XYZ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pin,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      hintText: 'e.g., 123456',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final username = _username();
                            if (username.isTrimEmpty) {
                              context.snack('Please set username first');
                              Navigator.pushReplacementNamed(context, AppRoutes.username);
                              return;
                            }

                            if (_roomId.text.isTrimEmpty || _pin.text.isTrimEmpty) {
                              context.snack('Room ID and PIN are required');
                              return;
                            }

                            await context.read<JoinRoomCubit>().join(
                                  roomId: _roomId.text.trim(),
                                  username: username,
                                );
                          },
                    child: isLoading ? const CircularProgressIndicator() : const Text('Join Room'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
