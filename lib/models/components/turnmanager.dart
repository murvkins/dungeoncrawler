import 'dart:async';

import 'package:dungeoncrawler/game/game.dart';
import 'package:dungeoncrawler/models/components/characters/enemies/enemy.dart';
import 'package:dungeoncrawler/models/components/characters/enemies/enemy_states.dart';
import 'package:dungeoncrawler/models/components/characters/player/player_states.dart';
import 'package:dungeoncrawler/models/components/environment/floor_tiles.dart';
import 'package:dungeoncrawler/models/enums/gamestate.dart';
import 'package:flame/components.dart';

class TurnManager extends Component with HasGameReference<DungeonCrawl> {
  GameState state = GameState.playerTurn;

  List<Enemy> enemyList = [];
  bool enemyDecidedRan = false;
  bool decidingFinished = false;

  @override
  void onMount() {
    super.onMount();
    Future.delayed(Duration.zero, () {
      updateEnemyList();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.dungeonBloc.state.dungeon.floors.isEmpty) return;
    if (game.player == null) return;

    final player = game.player;

    final ticker = player!.animationTickers?[player.current];

    // print(state);
    switch (state) {
      case GameState.playerTurn:
        if (player.isMoving ||
            player.playerState == PlayerState.attack ||
            player.playerState == PlayerState.walk) {
          state = GameState.playerAction;
          enemyDecidedRan = false;
          decidingFinished = false;
        }
        return;
      case GameState.playerAction:
        if (!enemyDecidedRan) {
          enemyDecidedRan = true;
          enemyDeciding(player.targetPosition);
        }

        bool isAttacking = player.playerState == PlayerState.attack;
        bool isHurt = player.playerState == PlayerState.hurt;
        print(player.playerState);
        if ((isAttacking || isHurt) && (ticker == null || !ticker.done())) {
          return;
        }

        //if player is done moving, not attacking and no enemies have a hurt animation playing
        if (!player.isMoving && !isAttacking && !isHurt) {
          state = GameState.enemyDeciding;
        }

        return;
      case GameState.enemyDeciding:
        final hurtenemies = enemyList.any(
          (e) =>
              e.enemyState == EnemyState.hurt &&
              !(e.animationTickers?[e.current]?.done() ?? true),
        );

        if (decidingFinished && !hurtenemies) {
          executeEnemyActions(player.targetPosition);
          state = GameState.enemyAction;
        }
        return;
      case GameState.enemyAction:
        final activeenemies = enemyList.any(
          (e) =>
              e.isMoving ||
              e.enemyState == EnemyState.hurt &&
                  (e.animationTickers?[e.current]?.done() ?? true) ||
              e.enemyState == EnemyState.attack,
        );

        bool isAnimationBusy = false;
        if (player.playerState == PlayerState.hurt) {
          isAnimationBusy = !(ticker?.done() ?? true);
        }

        if (!activeenemies && !isAnimationBusy) {
          state = GameState.playerTurn;
        }
        return;
      case GameState.gameOver:
        break;
    }
  }

  void updateEnemyList() {
    enemyList = game.world.children
        .whereType<Enemy>()
        .where(
          (e) =>
              e.enemyState != EnemyState.dead &&
              e.enemyState != EnemyState.sleeping,
        )
        .toList();
  }

  void enemyDeciding(Vector2 playerDestination) {
    enemyList = game.world.children
        .whereType<Enemy>()
        .where(
          (e) =>
              e.enemyState != EnemyState.dead &&
              e.enemyState != EnemyState.sleeping,
        )
        .toList();

    // final activeenemies = enemyList.where(
    //   (element) => element.enemyState != EnemyState.sleeping,
    // );

    if (enemyList.isEmpty) {
      decidingFinished = true;
      state = GameState.playerTurn;
      return;
    }

    for (final e in enemyList) {
      final xdis = (e.position.x - playerDestination.x);
      final ydis = (e.position.y - playerDestination.y);

      final willattack = rng.nextInt(100) > 50;
      final willmove = rng.nextInt(100) > 60;
      final dist = xdis.abs() + ydis.abs();
      e.queuedAction = EnemyAction.none;

      if (willattack && dist == 16.0) {
        e.queuedAction = EnemyAction.attack;
        if (xdis == -16.0) {
          e.queuedFacing = EnemyFacing.right;
        } else if (xdis == 16.0) {
          e.queuedFacing = EnemyFacing.left;
        } else if (ydis == -16.0) {
          e.queuedFacing = EnemyFacing.down;
        } else if (ydis == 16.0) {
          e.queuedFacing = EnemyFacing.up;
        }
      } else if (willmove && dist != 16.0) {
        double actualdistance = (playerDestination - e.position).length;
        if (actualdistance > 16.0 && actualdistance <= 64.0) {
          e.queuedAction = EnemyAction.advance;
        } else {
          e.queuedAction = EnemyAction.wander;
        }
      }
    }

    decidingFinished = true;
  }

  void executeEnemyActions(Vector2 playerDestination) {
    final activeenemies = enemyList.where(
      (element) => element.queuedAction != EnemyAction.none,
    );

    if (activeenemies.isEmpty) {
      state = GameState.playerTurn;
      return;
    }

    for (final e in activeenemies) {
      if (e.queuedAction == EnemyAction.attack) {
        e.enemyState = EnemyState.attack;
        e.enemyFacing = e.queuedFacing;
        e.updateVisualState();
      } else if (e.queuedAction == EnemyAction.advance) {
        enemyMoveToPlayer(e, playerDestination - e.position);
      } else if (e.queuedAction == EnemyAction.wander) {
        enemyWander(e);
      }
      e.queuedAction = EnemyAction.none;
    }
  }

  bool isTileOccupied(Vector2 target, Enemy enemy) {
    for (final e in enemyList) {
      if (e == enemy || e.enemyState == EnemyState.dead) continue;

      if (e.position.distanceTo(target) < 1.0) return true;

      if (e.isMoving && e.targetPosition.distanceTo(target) < 1.0 ||
          game.player!.position == e.targetPosition) {
        return true;
      }
    }
    return false;
  }

  void enemyMoveToPlayer(Enemy e, Vector2 diff) {
    EnemyFacing init;
    EnemyFacing alt;
    if (diff.x.abs() > diff.y.abs()) {
      init = diff.x > 0 ? EnemyFacing.right : EnemyFacing.left;
      alt = diff.y > 0 ? EnemyFacing.down : EnemyFacing.up;
    } else {
      init = diff.y > 0 ? EnemyFacing.down : EnemyFacing.up;
      alt = diff.x > 0 ? EnemyFacing.right : EnemyFacing.left;      
    }
    e.enemyFacing = init;    
    enemyTryToMove(e);
    
    if (e.enemyState == EnemyState.idle) {
      e.enemyFacing = alt;
      enemyTryToMove(e);
    }
  }

  void enemyWander(Enemy e) {
    e.enemyFacing = enemy_facings[rng.nextInt(4)];
    enemyTryToMove(e);
  }

  void enemyTryToMove(Enemy e) {
    Vector2 potentialTarget = e.position + (getFacingVector(e) * 16);
    if (!e.isColliding(potentialTarget) &&
        !isTileOccupied(potentialTarget, e)) {
      e.targetPosition = potentialTarget;
      e.isMoving = true;
      e.enemyState = EnemyState.walk;
      e.current = EnemyStateFacing.fromStateFacing(e.enemyState, e.enemyFacing);
    } else {
      e.enemyState = EnemyState.idle;
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
