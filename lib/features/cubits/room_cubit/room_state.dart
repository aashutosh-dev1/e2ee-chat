import 'package:equatable/equatable.dart';

class RoomsState extends Equatable {
  const RoomsState({required this.recentRoomIds});
  final List<String> recentRoomIds;

  @override
  List<Object?> get props => [recentRoomIds];
}
