import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/app/routes/routes.dart';
import 'package:pin_drop_chat/core/widgets/fun_widgets.dart';
import 'package:pin_drop_chat/features/cubits/create_room_cubit/create_room_cubit.dart';
import 'package:pin_drop_chat/features/cubits/create_room_cubit/create_room_state.dart';
import 'package:pin_drop_chat/features/cubits/room_cubit/room_cubit.dart';
import 'package:pin_drop_chat/features/extensions/context_x.dart';
import 'package:pin_drop_chat/features/extensions/string_x.dart';
import 'package:pin_drop_chat/model/chat_room_args.dart';

import '../../../../app/locator.dart';
import '../../../../core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _roomName = TextEditingController();

  String _username() =>
      sl.get<SharedPreferences>().getString(AppKeys.username) ?? '';

  @override
  void dispose() {
    _roomName.dispose();
    super.dispose();
  }

  Future<void> _copy(BuildContext context, String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    context.snack('$label copied ✅');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CreateRoomCubit()),
        BlocProvider(create: (_) => RoomsCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Room')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocConsumer<CreateRoomCubit, CreateRoomState>(
            listener: (context, state) async {
              if (state is CreateRoomSuccess) {
                await context.read<RoomsCubit>().addRecent(state.result.roomId);
              }
            },
            builder: (context, state) {
              final isLoading = state is CreateRoomLoading;
              final isSuccess = state is CreateRoomSuccess;

              return Column(
                children: [
                  const FunHeader(
                    title: "Create a room 🚀",
                    subtitle:
                        "Name it, generate a short code, and share the PIN.",
                    icon: Icons.add_circle_rounded,
                  ),
                  const SizedBox(height: 16),

                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Chat Room Name",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _roomName,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'e.g., Project Fusion',
                            prefixIcon: Icon(Icons.edit_rounded),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Create button
                        GradientButton(
                          label: isLoading ? "Creating..." : "Create Room",
                          icon: Icons.auto_awesome_rounded,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final name = _roomName.text.trim();
                                  final username = _username();

                                  if (username.isTrimEmpty) {
                                    context.snack('Please set username first');
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.username,
                                    );
                                    return;
                                  }

                                  if (name.isTrimEmpty) {
                                    context.snack('Enter room name');
                                    return;
                                  }

                                  await context.read<CreateRoomCubit>().create(
                                    roomName: name,
                                    username: username,
                                  );
                                },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Result card
                  if (isSuccess) ...[
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Share these details 🔐",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Send this outside the app (DM/WhatsApp). PIN is the decryption key.",
                            style: TextStyle(
                              color: Colors.black.withOpacity(.55),
                            ),
                          ),
                          const SizedBox(height: 14),

                          _InfoRow(
                            label: "Room Code",
                            value: (state).result.roomId,
                            onCopy: () => _copy(
                              context,
                              "Room Code",
                              state.result.roomId,
                            ),
                            icon: Icons.tag_rounded,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            label: "PIN",
                            value: state.result.pin,
                            onCopy: () =>
                                _copy(context, "PIN", state.result.pin),
                            icon: Icons.password_rounded,
                          ),

                          const SizedBox(height: 16),

                          OutlinedButton.icon(
                            icon: const Icon(Icons.chat_rounded),
                            label: const Text("Enter Chat Room"),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.chatRoom,
                                arguments: ChatRoomArgs(
                                  roomId: state.result.roomId,
                                  roomName: _roomName.text.trim(),
                                  pin: state.result.pin,
                                  joinedAt: DateTime.now(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (state is CreateRoomError) ...[
                    const SizedBox(height: 12),
                    SoftCard(
                      child: Row(
                        children: [
                          const Icon(Icons.error_rounded, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.message,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),
                  Text(
                    "Room code is short (4 chars) for fast typing ✅",
                    style: TextStyle(
                      color: Colors.black.withOpacity(.45),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.onCopy,
    required this.icon,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(.06)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(.12),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Copy",
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
    );
  }
}
