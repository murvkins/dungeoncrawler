part of 'dungeon_bloc.dart';

sealed class DungeonEvent extends Equatable {
  const DungeonEvent();

  @override
  List<Object> get props => [];
}

final class GenerateNewMap extends DungeonEvent {
}

final class AddFloor extends DungeonEvent {
}

final class GainXP extends DungeonEvent {
  const GainXP({required this.amount});

  final int amount;

  @override
  List<Object> get props => [amount];
}

final class TakeDamage extends DungeonEvent {
  const TakeDamage({required this.amount});

  final int amount;

  @override
  List<Object> get props => [amount];
}

final class Heal extends DungeonEvent {
  const Heal({required this.amount});

  final int amount;

  @override
  List<Object> get props => [amount];
}

final class ResetGame extends DungeonEvent {}