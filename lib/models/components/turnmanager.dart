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

  void updateEnemyList() {
    enemyList = game.world.children.whereType<Enemy>().toList();
  }

  @override
  FutureOr<void> onLoad() {    
    super.onLoad();
    updateEnemyList();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.dungeonBloc.state.dungeon.floors.isEmpty) return;

    final player = game.player;    

    switch (state) {
      case GameState.playerTurn:
        //wait for player to decide action move/attack
        // if (player!.playerState != PlayerState.idle) {
        //   player.playerState = PlayerState.idle;
        //   player.current = PlayerStateFacing.fromStateFacing(player.playerState, player.playerFacing);
        // }
        return;
      case GameState.playerAction:
        //wait for player action to finish
        if (!player!.isMoving && player.playerState != PlayerState.idle) {
          player.playerState = PlayerState.idle;
          // player.current = PlayerStateFacing.fromStateFacing(player.playerState, player.playerFacing);
        }
        if (!player.isMoving && player.playerState == PlayerState.idle) {
          state = GameState.enemyDeciding;
        }
        break;
      case GameState.enemyDeciding:
        //kill dead enemies
        final activeenemies = enemyList.where((element) => element.enemyState == EnemyState.idle);

        if (activeenemies.isEmpty) {
          state = GameState.playerTurn;
          return;
        }

        for (final e in activeenemies) {
          // print(e.enemyState);
          // if (e.enemyState == EnemyState.sleeping || e.enemyState == EnemyState.dead || e.enemyState == EnemyState.wakingup) continue;
          // if (e.enemyState == EnemyState.idle) {
          final xdis = (e.position.x - player!.position.x);
          final ydis = (e.position.y - player.position.y);
          // print('xdis: $xdis ydis: $ydis');
          if (rng.nextBool()) {
            if (xdis.abs() + ydis.abs() == 16.0) {
              // print('starting attack');
              e.enemyState = EnemyState.attack;
              if (xdis == -16.0) {
                //right
                e.enemyFacing = EnemyFacing.right;
              } else if (xdis == 16.0) {
                //left
                e.enemyFacing = EnemyFacing.left;
              } else if (ydis == -16.0) {
                //down
                e.enemyFacing = EnemyFacing.down;
              } else if (ydis == 16.0) {
                e.enemyFacing = EnemyFacing.up;
              }
              e.current = EnemyStateFacing.fromStateFacing(e.enemyState, e.enemyFacing);
              e.animationTickers?[e.current]?.reset();
            } else {
              if ((player.position - e.position).length <= 64.0) {
                //move to player
                // print('move to player');
                enemyMoveToPlayer(e, (player.position - e.position));
              } else {
                //wander
                // print('wander');
                enemyWander(e);
              }
            }
          }
          // }
        }
        state = GameState.enemyAction;
        break;
      case GameState.enemyAction:
        //execute enemy actions
        bool busy = enemyList.any((e) => e.isMoving || e.enemyState == EnemyState.attack);
        if (!busy) {
          state = GameState.playerTurn;
        }
        break;
      case GameState.gameOver:
        break;
    }
  }

  bool isTileOccupied(Vector2 target, Enemy enemy) {
    for (final e in enemyList) {
      if (e == enemy || e.enemyState == EnemyState.dead) continue;

      if (e.position.distanceTo(target) < 1.0) return true;

      if (e.isMoving && e.targetPosition.distanceTo(target) < 1.0 || game.player!.position == e.targetPosition) {
        return true;
      }
    }
    return false;
  }

  void enemyMoveToPlayer(Enemy e, Vector2 diff) {
    Vector2 step = Vector2.zero();
    if (diff.x.abs() > diff.y.abs()) {
      step.x = diff.x.sign * 16;
    } else {
      step.y = diff.y.sign * 16;
    }
    if (step.x < 0) {
      e.enemyFacing = EnemyFacing.left;
    } else if (step.x > 0) {
      e.enemyFacing = EnemyFacing.right;
    } else if (step.y < 0) {
      e.enemyFacing = EnemyFacing.up;
    } else if (step.y > 0) {
      e.enemyFacing = EnemyFacing.down;
    }
    enemyTryToMove(e);
  }

  void enemyWander(Enemy e) {
    e.enemyFacing = enemy_facings[rng.nextInt(4)];
    enemyTryToMove(e);
  }

  void enemyTryToMove(Enemy e) {
    Vector2 potentialTarget = e.position + (getFacingVector(e) * 16);
    if (!e.isColliding(potentialTarget) && !isTileOccupied(potentialTarget, e)) {
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
