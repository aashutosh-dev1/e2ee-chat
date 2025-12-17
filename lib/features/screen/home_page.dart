import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/app/routes/routes.dart';
import 'package:pin_drop_chat/core/widgets/fun_widgets.dart';
import 'package:pin_drop_chat/features/cubits/room_cubit/room_cubit.dart';
import 'package:pin_drop_chat/features/cubits/room_cubit/room_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoomsCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Pindrop Chat')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const FunHeader(
                title: "Let’s chat 🎉",
                subtitle: "Create a room or jump into one using a 4-char code.",
                icon: Icons.bolt_rounded,
              ),
              const SizedBox(height: 16),

              SoftCard(
                child: Column(
                  children: [
                    GradientButton(
                      label: "Create Chat Room",
                      icon: Icons.add_rounded,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.createRoom),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.login_rounded),
                      label: const Text("Join Chat Room"),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.joinRoom),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Rooms",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: BlocBuilder<RoomsCubit, RoomsState>(
                  builder: (_, s) {
                    if (s.recentRoomIds.isEmpty) {
                      return SoftCard(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.chat_bubble_outline_rounded, size: 44),
                            SizedBox(height: 10),
                            Text(
                              "No rooms yet",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Create one or join with a code 🔥",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: s.recentRoomIds.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final id = s.recentRoomIds[i];
                        return SoftCard(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.tag_rounded),
                            ),
                            title: Text(
                              id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: const Text("Tap Join and enter PIN"),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.joinRoom,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
