import 'package:equatable/equatable.dart';

class UsernameState extends Equatable {
  const UsernameState({required this.username});
  final String username;

  @override
  List<Object?> get props => [username];
}