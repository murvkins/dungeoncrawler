import 'dart:async';

import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/map.dart';
import 'package:dungeoncrawler/models/components/environment/lighting.dart';
import 'package:dungeoncrawler/models/components/characters/player/player.dart';
import 'package:dungeoncrawler/models/components/environment/props.dart';
import 'package:dungeoncrawler/game/turnmanager.dart';
import 'package:dungeoncrawler/models/enums/dungeonstatus.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DungeonCrawl extends FlameGame with HasKeyboardHandlerComponents {
  DungeonCrawl({required this.dungeonBloc});

  final DungeonBloc dungeonBloc;
  Player? player;
  late final TurnManager turnManager;

  @override
  Future<void> onLoad() async {
    world.children.register<Prop>();
    world.children.register<Player>();
    camera.viewfinder.anchor = Anchor.center;

    camera.viewport = FixedResolutionViewport(resolution: Vector2(1280, 720));
    camera.viewfinder.zoom = 3.0;
    camera.viewfinder.position = Vector2.zero();

    // await add(
    //   FpsTextComponent(
    //     position: Vector2(10, 10),
    //     anchor: Anchor.topLeft,
    //   ),
    // );

    await world.add(
      GenerateMap(
        dungeonBloc: dungeonBloc,
        onMapReady: (state) => spawnPlayer(state),
      ),
    );

    turnManager = TurnManager();

    world.add(turnManager);
    dungeonBloc.add(GenerateNewMap());
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    final isKeyDown = event is KeyDownEvent;
    final isEnter = keysPressed.contains(LogicalKeyboardKey.enter);

    if (isKeyDown && isEnter) {
      dungeonBloc.add(GenerateNewMap());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void update(double dt) {    
    super.update(dt);
    print(dungeonBloc.state.status);
    if (dungeonBloc.state.status == DungeonStatus.gameover) {
      if (!overlays.isActive('GameOver')) {
        overlays.add('GameOver');        
      }
    }
  }

  void spawnPlayer(DungeonState state) {
    player?.removeFromParent();

    final firstroom = state.dungeon.floors.last.rooms.first;
    final left = firstroom.x + 2;
    final top = firstroom.y + 4;
    final newplayer =
        Player(
            lightingConfig: LightingConfig(
              radius: 30,
              color: Colors.transparent,
              withPulse: true,
              pulseSpeed: 0.15,
              pulseVariation: 0.04,
              blurBorder: 20,
            ),
            renderedState: state,
          )
          ..position = Vector2(
            left * 16.0,
            top * 16.0,
          );

    world.add(newplayer);
    player = newplayer;
    camera.viewfinder.position = newplayer.position;
    camera.follow(newplayer, snap: true);
  }
}
