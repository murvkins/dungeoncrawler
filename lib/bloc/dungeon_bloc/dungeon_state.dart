part of 'dungeon_bloc.dart';

final class DungeonState extends Equatable {
  const DungeonState({
    required this.dungeon,
  });

  final Dungeon dungeon;

  DungeonState copyWith({
    Dungeon? dungeon,
  }) {
    return DungeonState(
      dungeon: dungeon ?? this.dungeon,
    );
  }

  @override  
  List<Object> get props => [dungeon];
}