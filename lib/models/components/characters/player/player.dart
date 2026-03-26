import 'dart:async';

import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/game.dart';
import 'package:dungeoncrawler/models/components/characters/enemies/enemy_states.dart';
import 'package:dungeoncrawler/models/components/environment/lighting.dart';
import 'package:dungeoncrawler/models/components/characters/player/player_states.dart';
import 'package:dungeoncrawler/models/components/turnmanager.dart';
import 'package:dungeoncrawler/models/enums/gamestate.dart';
import 'package:dungeoncrawler/models/enums/priority.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationGroupComponent<PlayerStateFacing> with HasGameReference<DungeonCrawl>, KeyboardHandler {
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
  final Set<LogicalKeyboardKey> pressedKeys = {};

  Vector2 velocity = Vector2.zero();

  late PlayerState playerState;
  late PlayerFacing playerFacing;

  @override
  Future<void> onLoad() async {
    final idleimage = await game.images.load('Swordsman_lvl1_Idle_with_shadow.png');
    final walkimage = await game.images.load('Swordsman_lvl1_Walk_with_shadow.png');
    final attackimage = await game.images.load('Swordsman_lvl1_attack_with_shadow.png');
    final hurtimage = await game.images.load('Swordsman_lvl1_Hurt_with_shadow.png');
    final deathimage = await game.images.load('Swordsman_lvl1_Death_with_shadow.png');

    final idleSpriteSheet = SpriteSheet(image: idleimage, srcSize: Vector2.all(64.0), spacing: 0);
    final walkSpriteSheet = SpriteSheet(image: walkimage, srcSize: Vector2.all(64.0), spacing: 0);
    final attackSpriteSheet = SpriteSheet(image: attackimage, srcSize: Vector2.all(64.0), spacing: 0);
    final hurtSpriteSheet = SpriteSheet(image: hurtimage, srcSize: Vector2.all(64.0), spacing: 0);
    final deathSpriteSheet = SpriteSheet(image: deathimage, srcSize: Vector2.all(64.0), spacing: 0);

    final double walkspeed = 0.08;

    animations = {
      PlayerStateFacing.idledown: createReversingAnimation(idleSpriteSheet, 0, 11, 0.15),
      PlayerStateFacing.idleleft: createReversingAnimation(idleSpriteSheet, 1, 11, 0.15),
      PlayerStateFacing.idleright: createReversingAnimation(idleSpriteSheet, 2, 11, 0.15),
      PlayerStateFacing.idleup: createReversingAnimation(idleSpriteSheet, 3, 3, 0.15),

      PlayerStateFacing.walkdown: walkSpriteSheet.createAnimation(row: 0, stepTime: walkspeed, to: 6),
      PlayerStateFacing.walkleft: walkSpriteSheet.createAnimation(row: 1, stepTime: walkspeed, to: 6),
      PlayerStateFacing.walkright: walkSpriteSheet.createAnimation(row: 2, stepTime: walkspeed, to: 6),
      PlayerStateFacing.walkup: walkSpriteSheet.createAnimation(row: 3, stepTime: walkspeed, to: 6),

      PlayerStateFacing.attackdown: attackSpriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 8, loop: false),
      PlayerStateFacing.attackleft: attackSpriteSheet.createAnimation(row: 1, stepTime: 0.1, to: 8, loop: false),
      PlayerStateFacing.attackright: attackSpriteSheet.createAnimation(row: 2, stepTime: 0.1, to: 8, loop: false),
      PlayerStateFacing.attackup: attackSpriteSheet.createAnimation(row: 3, stepTime: 0.1, to: 8, loop: false),

      PlayerStateFacing.hurtdown: hurtSpriteSheet.createAnimation(row: 0, stepTime: 0.15, to: 5, loop: false),
      PlayerStateFacing.hurtleft: hurtSpriteSheet.createAnimation(row: 1, stepTime: 0.15, to: 5, loop: false),
      PlayerStateFacing.hurtright: hurtSpriteSheet.createAnimation(row: 2, stepTime: 0.15, to: 5, loop: false),
      PlayerStateFacing.hurtup: hurtSpriteSheet.createAnimation(row: 3, stepTime: 0.15, to: 5, loop: false),

      PlayerStateFacing.deaddown: deathSpriteSheet.createAnimation(row: 0, stepTime: 0.15, to: 7, loop: false),
      PlayerStateFacing.deadleft: deathSpriteSheet.createAnimation(row: 1, stepTime: 0.15, to: 7, loop: false),
      PlayerStateFacing.deadright: deathSpriteSheet.createAnimation(row: 2, stepTime: 0.15, to: 7, loop: false),
      PlayerStateFacing.deadup: deathSpriteSheet.createAnimation(row: 3, stepTime: 0.15, to: 7, loop: false),
    };

    current = PlayerStateFacing.idledown;
    playerState = PlayerState.idle;
    playerFacing = PlayerFacing.down;

    size = Vector2.all(64.0);
    anchor = Anchor(0.375, 0.5);
    targetPosition = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    lightingConfig.update(dt);

    Vector2 playerFacingVector;
    priority = (RenderPriority.player.value + position.y).toInt();

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
    pressedKeys.addAll(keysPressed);
    return true;
  }

  void _checkInput() {
    final turnmanager = game.world.children.whereType<TurnManager>().first;
    if (turnmanager.state != GameState.playerTurn) return;
    if (isMoving) return;

    Vector2 direction = Vector2.zero();

    if (pressedKeys.contains(LogicalKeyboardKey.space)) {
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
        priority = RenderPriority.player.value + 10;
        updateVisualState();
        game.world.children.whereType<TurnManager>().first.enemyDeciding(position);
        return;
      }

      if (isColliding(potentialTarget)) {
        //should i really trigger enemies if the player collides with something? turning off for now
        
        playerState = PlayerState.idle;
        priority = RenderPriority.player.value;
        updateVisualState();
        //game.world.children.whereType<TurnManager>().first.state = GameState.playerAction;
        return;
      }

      targetPosition = potentialTarget;
      isMoving = true;
      playerState = PlayerState.walk;
      updateVisualState();
      game.world.children.whereType<TurnManager>().first.enemyDeciding(targetPosition);
    }
  }

  bool isColliding(Vector2 pos) {
    final floor = renderedState.dungeon.floors.last;
    final int gx = (pos.x / 16).floor();
    final int gy = (pos.y / 16).floor();

    if (floor.walls.grid[gx][gy] != null) return true;

    for (int ox = gx - 4; ox <= gx; ox++) {
      for (int oy = gy - 5; oy <= gy; oy++) {
        if (ox < 0 || oy < 0 || ox >= floor.width || oy >= floor.height) continue;

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

  void updateVisualState() {
    final newKey = PlayerStateFacing.fromStateFacing(playerState, playerFacing);
    if (current != newKey) {
      current = newKey;
    }
  }

  SpriteAnimation createReversingAnimation(SpriteSheet sheet, int row, int framecount, double steptime) {
    final indices = List<int>.generate(framecount, (index) => index);
    indices.insertAll(0, List<int>.generate(10, (index) => 0));
    indices.addAll(List<int>.generate(10, (index) => framecount - 1));
    indices.addAll(List<int>.generate(framecount - 2, (index) => framecount - 2 - index));

    return SpriteAnimation.spriteList(
      indices.map((e) => sheet.getSprite(row, e)).toList(),
      stepTime: steptime,
      loop: true,
    );
  }
}
