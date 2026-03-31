import 'package:dungeoncrawler/models/components/characters/player/player_stats.dart';
import 'package:dungeoncrawler/models/enums/dungeonstatus.dart';
import 'package:equatable/equatable.dart';
import 'package:dungeoncrawler/models/components/environment/dungeon_floors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dungeon_events.dart';
part 'dungeon_state.dart';

class DungeonBloc extends Bloc<DungeonEvent, DungeonState> {
  DungeonBloc()
    : super(
        DungeonState(
          dungeon: Dungeon.empty(),
          stats: PlayerStats.baselevel(),
          status: DungeonStatus.playing,
        ),
      ) {
    on<GenerateNewMap>((event, emit) {
      final Dungeon dungeon = Dungeon.empty().addFloor();
      emit(
        state.copyWith(
          dungeon: dungeon,
          stats: PlayerStats.baselevel(),
          status: DungeonStatus.playing,
        ),
      );
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

    on<GainXP>((event, emit) {
      var stats = state.stats;
      int newxp = stats.xp + event.amount;

      if (newxp >= stats.xprequired) {
        final xpbalance = newxp - stats.xprequired;
        emit(
          state.copyWith(
            stats: stats.copyWith(
              level: stats.level + 1,
              maxhp: stats.maxhp + 5,
              attack: stats.attack + 1,
              xp: xpbalance,
              xprequired: (stats.xprequired * 1.5).toInt(),
            ),
          ),
        );
      } else {
        emit(state.copyWith(stats: stats.copyWith(xp: newxp)));
      }
    });

    on<TakeDamage>((event, emit) {
      var stats = state.stats;
      int newhp = stats.hp - event.amount;

      if (newhp <= 0) {
        emit(
          state.copyWith(
            stats: state.stats.copyWith(hp: 0),
            status: DungeonStatus.gameover,
          ),
        );
      } else {
        emit(
          state.copyWith(
            stats: stats.copyWith(hp: newhp),
          ),
        );
      }
    });

    on<Heal>((event, emit) {
      var stats = state.stats;
      int newhp = stats.hp + event.amount;

      emit(state.copyWith(stats: stats.copyWith(hp: newhp)));
    });

    on<ResetGame>((event, emit) {
      emit(
        DungeonState(
          dungeon: Dungeon.empty(),
          stats: PlayerStats.baselevel(),
          status: DungeonStatus.playing,
        ),
      );
    });
  }
}
