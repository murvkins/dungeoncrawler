import 'package:equatable/equatable.dart';
import 'package:dungeoncrawler/models/components/environment/dungeon_floors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dungeon_events.dart';
part 'dungeon_state.dart';

class DungeonBloc extends Bloc<DungeonEvent, DungeonState> {
  DungeonBloc() : super(DungeonState(dungeon: Dungeon.empty())) {
    on<GenerateNewMap>((event, emit) {
      final Dungeon dungeon = Dungeon.empty().addFloor();
      emit(state.copyWith(dungeon: dungeon));
    });

    on<AddFloor>((event, emit) {
      final newFloor = Floor.newFloor();
      final updatedDungeon = Dungeon(
        floors: [
          ...state.dungeon.floors,
          newFloor,
        ],
      );
      emit(state.copyWith(dungeon: updatedDungeon));
    });
  }
}
