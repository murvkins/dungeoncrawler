part of 'dungeon_bloc.dart';

final class DungeonState extends Equatable {
  const DungeonState({
    required this.dungeon,
    required this.stats,
    this.status = DungeonStatus.playing,
  });

  final Dungeon dungeon;
  final PlayerStats stats;
  final DungeonStatus status;

  DungeonState copyWith({
    Dungeon? dungeon,
    PlayerStats? stats,
    DungeonStatus? status,
  }) {
    return DungeonState(
      dungeon: dungeon ?? this.dungeon,
      stats: stats ?? this.stats,
      status: status ?? this.status,
    );
  }

  @override  
  List<Object> get props => [dungeon, stats, status];
}