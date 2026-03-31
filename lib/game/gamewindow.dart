import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/dungeoncrawl_game.dart';
import 'package:dungeoncrawler/models/components/overlays/gameover.dart';
import 'package:dungeoncrawler/models/components/overlays/hud.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameWindow extends StatefulWidget {
  const GameWindow({super.key});

  @override
  State<GameWindow> createState() => _GameWindowState();
}

class _GameWindowState extends State<GameWindow> {
  late final DungeonCrawl game;

  @override
  void initState() {
    super.initState();
    final dungeonbloc = BlocProvider.of<DungeonBloc>(context, listen: false);
    game = DungeonCrawl(dungeonBloc: dungeonbloc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(
        game: game,
        autofocus: true,
        overlayBuilderMap: {
          'HUD': (context, DungeonCrawl game) => HudOverlay(game),
          'GameOver': (context, DungeonCrawl game) => GameOverOverlay(game),
        },
        initialActiveOverlays: const ['HUD'],
        loadingBuilder: (p0) => const Center(
          child: CircularProgressIndicator(),
        ),        
      ),
    );
  }
}