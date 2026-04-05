import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/dungeoncrawl_game.dart';
import 'package:dungeoncrawler/models/components/overlays/exitindicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HudOverlay extends StatelessWidget {
  final DungeonCrawl game;
  const HudOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DungeonBloc, DungeonState>(
      builder: (context, state) {
        final stats = state.stats;

        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white12,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProgressBar(
                            'HP:   ${stats.hp} / ${stats.maxhp}',
                            Colors.red.shade700,
                            stats.hpPercent,
                          ),
                          const SizedBox(height: 5),
                          ProgressBar(
                            'Level  ${stats.level}:   ${stats.xp} / ${stats.xprequired}',
                            Colors.blue.shade700,
                            stats.xpPercent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 12),
                  child: ExitIndicator(game: game),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsGeometry.only(top: 2, right: 4.0),
              child: Text(
                'Floor:  ${game.dungeonBloc.state.dungeon.floors.length}',
                style: TextStyle(
                  color: Colors.grey.shade100,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget ProgressBar(String labelValue, Color color, double value) {
  return Container(
    width: 200,
    height: 30,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400, width: 1.5),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Stack(
      // alignment: Alignment.center,
      children: [
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.black54,
          color: color,
          minHeight: 30,
          borderRadius: BorderRadius.circular(3),
        ),
        SizedBox(
          width: 200,
          child: Text(
            labelValue,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade100,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              // shadows: [
              //   Shadow(
              //     blurRadius: 2,
              //     color: Colors.black,
              //   ),
              // ],
            ),
          ),
        ),
      ],
    ),
  );
}
