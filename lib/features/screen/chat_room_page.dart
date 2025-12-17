import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/features/cubits/chat_cubit/chat_cubit.dart';
import 'package:pin_drop_chat/features/cubits/chat_cubit/chat_state.dart';
import 'package:pin_drop_chat/model/chat_room_args.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key, required this.args});
  final ChatRoomArgs args;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openMembers(ChatReady s) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.group_rounded),
                    const SizedBox(width: 10),
                    Text(
                      "Members (${s.members.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: s.members.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.black.withOpacity(.06)),
                    itemBuilder: (_, i) {
                      final m = s.members[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(.12),
                          child: Text(
                            m.username.isNotEmpty
                                ? m.username[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          m.username,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.args;
    final cs = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => ChatCubit(
        roomId: a.roomId,
        roomName: a.roomName,
        username: '',
        joinedAt: a.joinedAt,
        pin: a.pin,
      )..start(),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ChatError) {
            return Scaffold(
              appBar: AppBar(title: Text(a.roomName)),
              body: Center(child: Text(state.message)),
            );
          }

          final s = state as ChatReady;

          _scrollToBottomSoon();

          return Scaffold(
            appBar: AppBar(
              title: Column(
                children: [
                  Text(
                    s.roomName,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Room: ${a.roomId}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(.55),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.lock_rounded),
                  tooltip: "Encrypted with PIN",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Messages are encrypted using the room PIN 🔐",
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.group_rounded),
                  onPressed: () => _openMembers(s),
                ),
              ],
            ),

            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF6F7FB),
                    cs.primary.withOpacity(.05),
                    const Color(0xFFFF4D8D).withOpacity(.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: _ChipBanner(
                      text: "You joined this room.",
                      icon: Icons.celebration_rounded,
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      itemCount: s.messages.length,
                      itemBuilder: (_, i) {
                        final m = s.messages[i];
                        return _MessageBubble(
                          senderName: m.senderName,
                          text: m.text,
                          isMine: m.isMine,
                          isDecryptionFailed: m.isDecryptionFailed,
                        );
                      },
                    ),
                  ),

                  _ComposerBar(
                    controller: _controller,
                    onSend: () async {
                      final txt = _controller.text.trim();
                      if (txt.isEmpty) return;
                      _controller.clear();
                      await context.read<ChatCubit>().send(txt);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChipBanner extends StatelessWidget {
  const _ChipBanner({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: cs.primary.withOpacity(.10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.senderName,
    required this.text,
    required this.isMine,
    required this.isDecryptionFailed,
  });

  final String senderName;
  final String text;
  final bool isMine;
  final bool isDecryptionFailed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bubble = isMine
        ? LinearGradient(
            colors: [
              cs.primary,
              const Color(0xFF7C4DFF),
              const Color(0xFFFF4D8D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    final bgColor = isMine ? null : Colors.white;
    final textColor = isMine ? Colors.white : Colors.black87;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: bgColor,
          gradient: bubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 18),
          ),
          border: isMine
              ? null
              : Border.all(color: Colors.black.withOpacity(.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 8),
              color: (isMine ? cs.primary : Colors.black).withOpacity(.08),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMine ? .end : .start,
          children: [
            Row(
              mainAxisSize: .min,
              children: [
                if (!isMine) ...[
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: cs.primary.withOpacity(.12),
                    child: Text(
                      senderName.isNotEmpty ? senderName[0].toUpperCase() : "?",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  isMine ? "You" : senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isMine
                        ? Colors.white.withOpacity(.9)
                        : Colors.black.withOpacity(.55),
                  ),
                ),
                if (isDecryptionFailed) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: isMine ? Colors.white : Colors.orange,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontStyle: isDecryptionFailed
                    ? FontStyle.italic
                    : FontStyle.normal,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(.06)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withOpacity(.06),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Type your message...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () async => onSend(),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary,
                        const Color(0xFF7C4DFF),
                        const Color(0xFFFF4D8D),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                        color: cs.primary.withOpacity(.20),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
