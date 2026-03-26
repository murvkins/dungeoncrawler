part of 'dungeon_bloc.dart';

sealed class DungeonEvent extends Equatable {
  const DungeonEvent();

  @override
  List<Object> get props => [];
}

final class GenerateNewMap extends DungeonEvent {
  // const GenerateNewMap({required this.dungeon});

  // final Dungeon dungeon;

  // @override
  // List<Object> get props => [dungeon];
}

final class AddFloor extends DungeonEvent {
  // const AddFloor({required this.dungeon});

  // final Dungeon dungeon;

  // @override
  // List<Object> get props => [dungeon];
}
