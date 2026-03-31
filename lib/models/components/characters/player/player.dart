import 'dart:async';

import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/dungeoncrawl_game.dart';
import 'package:dungeoncrawler/models/components/characters/enemies/enemy.dart';
import 'package:dungeoncrawler/models/components/characters/enemies/enemy_states.dart';
import 'package:dungeoncrawler/models/components/characters/spritefactory.dart';
import 'package:dungeoncrawler/models/components/environment/lighting.dart';
import 'package:dungeoncrawler/models/components/characters/player/player_states.dart';
import 'package:dungeoncrawler/game/turnmanager.dart';
import 'package:dungeoncrawler/models/enums/gamestate.dart';
import 'package:dungeoncrawler/models/enums/priority.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationGroupComponent<PlayerStateFacing>
    with HasGameReference<DungeonCrawl>, KeyboardHandler {
  final LightingConfig lightingConfig;
  final DungeonState renderedState;

  Player({
    required this.lightingConfig,
    required this.renderedState,
  });

  static const double moveSpeed = 12;
  double movePercent = 0.0;
  Vector2 targetPosition = Vector2.zero();
  bool isMoving = false;
  bool hasDealtDamage = false;
  final Set<LogicalKeyboardKey> pressedKeys = {};

  Vector2 velocity = Vector2.zero();

  PlayerState playerState = PlayerState.idle;
  PlayerFacing playerFacing = PlayerFacing.down;

  int lasthp = 10;

  @override
  Future<void> onLoad() async {
    playerState = PlayerState.idle;
    playerFacing = PlayerFacing.down;

    animations = await SpriteFactory.createPlayerAnimations(game.images);

    current = PlayerStateFacing.idledown;

    size = Vector2.all(64.0);
    anchor = Anchor(0.375, 0.5);
    targetPosition = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    lightingConfig.update(dt);
    if (playerState == PlayerState.dead) return;
    final currenthp = game.dungeonBloc.state.stats.hp;

    Vector2 playerFacingVector;
    priority = (RenderPriority.player.value + position.y).toInt() + 3;

    switch (playerFacing) {
      case PlayerFacing.down:
        playerFacingVector = Vector2(0, 1);
        break;
      case PlayerFacing.up:
        playerFacingVector = Vector2(0, -1);
        break;
      case PlayerFacing.left:
        playerFacingVector = Vector2(-1, 0);
        break;
      case PlayerFacing.right:
        playerFacingVector = Vector2(1, 0);
        break;
    }

    if (currenthp <= 0 && playerState != PlayerState.dead) {
      playerState = PlayerState.dead;
      updateVisualState();
      return;
    }

    if (currenthp < lasthp && playerState != PlayerState.hurt) {
      playerState = PlayerState.hurt;
      updateVisualState();
      lasthp = currenthp;
    }

    if (playerState == PlayerState.hurt) {
      final ticker = animationTickers?[current];
      if (ticker != null && ticker.done()) {
        playerState = PlayerState.idle;
        updateVisualState();
      }
      return;
    }

    if (playerState == PlayerState.attack) {
      final ticker = animationTickers?[current];
      if (ticker != null && ticker.currentIndex == 3 && !hasDealtDamage) {
        game.turnManager.resetRestCounter();
        hasDealtDamage = true;
        final target = position + (playerFacingVector * 16.0);
        final enemy = game.world.children.whereType<Enemy>().firstWhere(
          (e) => e.position == target && e.enemyState != EnemyState.dead,
          orElse: () => null as dynamic,
        );
        enemy.takeDamage(game.dungeonBloc.state.stats.attack);
      }
      if (ticker != null && !ticker.done()) {
        return;
      }
      if (ticker != null && ticker.done()) {
        hasDealtDamage = false;
        playerState = PlayerState.idle;
        updateVisualState();
      }
      return;
    }

    if (isMoving) {
      Vector2 startPos = targetPosition - (playerFacingVector * 16);
      movePercent += moveSpeed * dt;

      if (movePercent >= 1.0) {
        position.setFrom(targetPosition);
        movePercent = 0.0;
        isMoving = false;
        if (pressedKeys.isEmpty) {
          playerState = PlayerState.idle;
          updateVisualState();
        }
      } else {
        position.setFrom(startPos + (targetPosition - startPos) * movePercent);
      }
    } else {
      if (pressedKeys.isEmpty) {
        playerState = PlayerState.idle;
        updateVisualState();
      }
      _checkInput();
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    pressedKeys.clear();
    if (playerState == PlayerState.dead) true;
    pressedKeys.addAll(keysPressed);
    return true;
  }

  void _checkInput() {
    if (playerState == PlayerState.dead) return;
    final turnmanager = game.world.children.whereType<TurnManager>().first;
    // print(turnmanager.state);
    if (turnmanager.state != GameState.playerTurn) return;
    // final ticker = animationTickers?[current];
    // if (playerState == PlayerState.attack && !ticker!.done()) return;
    if (isMoving) return;

    Vector2 direction = Vector2.zero();

    if (pressedKeys.contains(LogicalKeyboardKey.space)) {
      final turnmanager = game.world.children.whereType<TurnManager>().first;
      turnmanager.enemyDecidedRan = false;
      turnmanager.decidingFinished = false;
      turnmanager.state = GameState.playerAction;
      return;
    }

    if (pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      direction.x = -1;
      playerFacing = PlayerFacing.left;
    } else if (pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      direction.x = 1;
      playerFacing = PlayerFacing.right;
    } else if (pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      direction.y = -1;
      playerFacing = PlayerFacing.up;
    } else if (pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      direction.y = 1;
      playerFacing = PlayerFacing.down;
    }

    if (direction != Vector2.zero()) {
      final potentialTarget = position + (direction * 16);
      if (isEnemyAt(potentialTarget)) {
        playerState = PlayerState.attack;
        updateVisualState();
        return;
      }

      if (isColliding(potentialTarget)) {
        playerState = PlayerState.idle;
        updateVisualState();
        return;
      }

      targetPosition = potentialTarget;
      isMoving = true;
      playerState = PlayerState.walk;
      updateVisualState();
    }
  }

  bool isColliding(Vector2 pos) {
    final floor = renderedState.dungeon.floors.last;
    final int gx = (pos.x / 16).floor();
    final int gy = (pos.y / 16).floor();

    if (floor.walls.grid[gx][gy] != null) return true;

    for (int ox = gx - 4; ox <= gx; ox++) {
      for (int oy = gy - 5; oy <= gy; oy++) {
        if (ox < 0 || oy < 0 || ox >= floor.width || oy >= floor.height) {
          continue;
        }

        final prop = floor.decorations.grid[ox][oy];
        if (prop != null) {
          if (gx < ox + prop.width && gy < oy + prop.height) {
            if (gy == oy && prop.top_row_is_traversible) {
              continue;
            }
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isEnemyAt(Vector2 pos) {
    final floor = renderedState.dungeon.floors.last;

    for (final e in floor.enemies) {
      if (e.enemyState == EnemyState.dead) continue;
      if (e.position.x == pos.x && e.position.y == pos.y) return true;
    }
    return false;
  }

  PlayerFacing? getPressedFacing() {
    if (pressedKeys.contains(LogicalKeyboardKey.keyA)) return PlayerFacing.left;
    if (pressedKeys.contains(LogicalKeyboardKey.keyD))
      return PlayerFacing.right;
    if (pressedKeys.contains(LogicalKeyboardKey.keyW)) return PlayerFacing.up;
    if (pressedKeys.contains(LogicalKeyboardKey.keyS)) return PlayerFacing.down;
    return null;
  }

  void updateVisualState() {
    final newKey = PlayerStateFacing.fromStateFacing(playerState, playerFacing);
    if (current != newKey) {
      current = newKey;
      animationTickers?[current]?.reset();
    }
  }
}
