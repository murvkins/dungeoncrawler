import 'dart:async';

import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/dungeoncrawl_game.dart';
import 'package:dungeoncrawler/models/components/characters/enemies/enemy_states.dart';
import 'package:dungeoncrawler/models/components/characters/enemies/enemy_stats.dart';
import 'package:dungeoncrawler/models/components/characters/spritefactory.dart';
import 'package:dungeoncrawler/models/components/environment/floor_tiles.dart';
import 'package:dungeoncrawler/game/turnmanager.dart';
import 'package:dungeoncrawler/models/enums/priority.dart';
import 'package:flame/components.dart';

class Enemy extends SpriteAnimationGroupComponent<EnemyStateFacing>
    with HasGameReference<DungeonCrawl> {
  final EnemyStats stats;
  final DungeonState renderedState;

  Enemy({
    required this.renderedState,
    required this.stats,
    required Vector2 position,
  }) : super(
         position: position,
       );

  static const double moveSpeed = 6.0;
  static const double wakuUpRange = 80.0;
  static const double aggroRange = 64;

  double movePercent = 0.0;
  Vector2 targetPosition = Vector2.zero();
  bool isMoving = false;
  bool hasDealtDamage = false;

  Vector2 velocity = Vector2.zero();

  EnemyState enemyState = EnemyState.sleeping;
  EnemyFacing enemyFacing = EnemyFacing.down;
  late EnemyAction queuedAction;
  late EnemyFacing queuedFacing;

  @override
  Future<void> onLoad() async {
    enemyState = EnemyState.sleeping;
    enemyFacing = enemy_facings[rng.nextInt(4)];
    queuedAction = EnemyAction.none;
    queuedFacing = EnemyFacing.down;

    animations = await SpriteFactory.createEnemyAnimations(game.images);

    current = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);

    final ticker = animationTickers?[current];
    ticker?.paused = true;

    size = Vector2.all(64.0);
    anchor = Anchor(0.375, 0.5);
    targetPosition = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    priority = (RenderPriority.enemy.value + position.y).toInt();

    if (enemyState == EnemyState.wakingup) return;
    if (enemyState == EnemyState.sleeping) {
      checkWakeUp();
      return;
    }

    if (enemyState == EnemyState.dead) {
      onDeath();
      return;
    }

    if (enemyState == EnemyState.hurt) {
      final ticker = animationTickers?[current];
      if (ticker != null && ticker.done()) {
        enemyState = EnemyState.idle;
        updateVisualState();
      }
      return;
    }

    if (!game.camera.canSee(this)) {
      if (enemyState != EnemyState.sleeping) {
        goToSleep();
      }
      return;
    }

    if (enemyState == EnemyState.attack) {
      if (enemyFacing == EnemyFacing.left || enemyFacing == EnemyFacing.right) {
        priority += 5;
      }
      final ticker = animationTickers?[current];
      if (ticker != null && ticker.currentIndex == 3 && !hasDealtDamage) {
        game.turnManager.resetRestCounter();
        hasDealtDamage = true;
        game.dungeonBloc.add(TakeDamage(amount: stats.attack));
      }
      if (ticker != null && ticker.done()) {
        hasDealtDamage = false;
        enemyState = EnemyState.idle;
        updateVisualState();
      }
      return;
    }

    if (enemyState == EnemyState.walk && isMoving) {
      movePercent += moveSpeed * dt;

      if (movePercent >= 1.0) {
        position.setFrom(targetPosition);
        movePercent = 0.0;
        isMoving = false;
        enemyState = EnemyState.idle;
        current = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);
      } else {
        final Vector2 startPos = targetPosition - (getFacingVector(this) * 16);
        position.setFrom(startPos + (targetPosition - startPos) * movePercent);
      }
    }
  }

  bool snapIfDistant(Vector2 playerPosition, Vector2 target) {    
    final double distance = (position - playerPosition).length;
    if (distance >= 130.0) {
      position.setFrom(target);
      movePercent = 0.0;
      isMoving = false;
      enemyState = EnemyState.idle;
      updateVisualState();
      return true;
    }
    return false;
  }

  void snapToTarget() {
    if (isMoving) {
      position.setFrom(targetPosition);
      movePercent = 0.0;
      isMoving = false;
      enemyState = EnemyState.idle;
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

  void checkWakeUp() {
    final player = game.player;
    if (player == null) return;

    double distance = position.distanceTo(player.position);
    if (distance < wakuUpRange) {
      wakeUp();
    }
  }

  void wakeUp() {
    enemyState = EnemyState.wakingup;
    playAnimationOnce(EnemyState.idle);
    game.world.children.whereType<TurnManager>().firstOrNull?.updateEnemyList();
  }

  void goToSleep() {
    isMoving = false;
    position = targetPosition;
    enemyState = EnemyState.sleeping;
    current = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);
    final ticker = animationTickers?[current];
    ticker?.reset();
    ticker?.paused = true;
  }

  void onDeath() {
    enemyState = EnemyState.dead;
    updateVisualState();
    game.world.children.whereType<TurnManager>().firstOrNull?.updateEnemyList();
  }

  void takeDamage(int damage) {
    stats.hp -= damage;
    if (stats.hp <= 0) {
      enemyState = EnemyState.dead;
      game.dungeonBloc.add(GainXP(amount: stats.xpreward));
    } else {
      enemyState = EnemyState.hurt;
    }
    updateVisualState();
    animationTickers?[current]?.reset();
  }

  void playAnimationOnce(EnemyState resultstate) {
    current = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);
    final ticker = animationTickers?[current];

    if (ticker != null) {
      ticker.reset();
      ticker.paused = false;
    }

    ticker?.onComplete = () {
      enemyState = resultstate;
      updateVisualState();
    };
  }

  void updateVisualState() {
    final newKey = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);
    if (current != newKey) {
      current = newKey;
      animationTickers?[current]?.reset();
    }
  }

  Vector2 getFacingVector(Enemy e) {
    switch (e.enemyFacing) {
      case EnemyFacing.down:
        return Vector2(0, 1);
      case EnemyFacing.up:
        return Vector2(0, -1);
      case EnemyFacing.left:
        return Vector2(-1, 0);
      case EnemyFacing.right:
        return Vector2(1, 0);
    }
  }
}
