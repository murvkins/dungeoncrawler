import 'dart:math';

import 'package:dungeoncrawler/game/dungeoncrawl_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ExitIndicator extends StatefulWidget {
  const ExitIndicator({super.key, required this.game});
  final DungeonCrawl game;
  
  @override
  State<ExitIndicator> createState() => _ExitIndicatorState();
}

class _ExitIndicatorState extends State<ExitIndicator>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double angle = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {      
      final game = widget.game;
      final state = game.dungeonBloc.state;
      final player = game.player;
      final floor = state.dungeon.floors.lastOrNull;
      final Vector2? exitPosition = floor?.exitPosition;      
      print(exitPosition);
      if (player == null || floor == null || exitPosition == null) return;

      if (mounted) {        
        setState(() {
          // print('${exitPosition.x} : ${exitPosition.y} vs ${player.position.x} : ${player.position.y}');
          final playerPos = player.position;
          final direction = exitPosition - playerPos;          
          angle = atan2(direction.x, -direction.y);          
          // print(angle);
        });
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Image.asset(
        'assets/images/indicator.png',
        scale: 0.8,
      ),
    );
  }
}
