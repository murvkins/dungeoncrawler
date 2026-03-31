import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/dungeoncrawl_game.dart';
import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  final DungeonCrawl game;
  const GameOverOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.red.shade900,
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'YOU DIED',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {                      
                      game.dungeonBloc.add(GenerateNewMap());
                      game.overlays.remove('GameOver');
                      game.turnManager.resetGame();                 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: const Text(
                        'RESTART',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
