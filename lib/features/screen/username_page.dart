import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_drop_chat/app/routes/routes.dart';
import 'package:pin_drop_chat/core/widgets/fun_widgets.dart';
import 'package:pin_drop_chat/features/cubits/username_cubit/username_cubit.dart';
import 'package:pin_drop_chat/features/cubits/username_cubit/username_state.dart';
import 'package:pin_drop_chat/features/extensions/context_x.dart';
import 'package:pin_drop_chat/features/extensions/string_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});
  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsernameCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Username Setup')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const FunHeader(
                    title: "Pick your name",
                    subtitle: "This name shows up in group rooms.",
                    icon: Icons.auto_awesome_rounded,
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Username",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: "e.g., aashu_dev",
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<UsernameCubit, UsernameState>(
                          builder: (_, s) => Text(
                            s.username.isEmpty
                                ? "Tip: Keep it short & friendly 😄"
                                : "Saved as: ${s.username}",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GradientButton(
                    label: "Continue",
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () async {
                      final name = _controller.text.trim();
                      if (name.isTrimEmpty) {
                        context.snack("Please enter a username");
                        return;
                      }
                      await context.read<UsernameCubit>().save(name);
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
