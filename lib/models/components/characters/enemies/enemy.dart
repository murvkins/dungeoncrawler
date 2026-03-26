import 'dart:async';

import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/game.dart';
import 'package:dungeoncrawler/models/components/characters/enemies/enemy_states.dart';
import 'package:dungeoncrawler/models/components/environment/floor_tiles.dart';
import 'package:dungeoncrawler/models/enums/priority.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Enemy extends SpriteAnimationGroupComponent<EnemyStateFacing> with HasGameReference<DungeonCrawl> {
  final DungeonState renderedState;

  Enemy({
    required this.renderedState,
    required Vector2 position,
  }) : super(
         position: position,
       );

  static const double moveSpeed = 12.0;
  static const double wakuUpRange = 80.0;
  static const double aggroRange = 64;

  double movePercent = 0.0;
  Vector2 targetPosition = Vector2.zero();
  bool isMoving = false;
  // bool hasAwoke = false;

  Vector2 velocity = Vector2.zero();

  late EnemyState enemyState;
  late EnemyFacing enemyFacing;

  @override
  Future<void> onLoad() async {
    final idleimage = await game.images.load('Skeleton1_Idle_with_shadow.png');
    final walkimage = await game.images.load('Skeleton1_Walk_with_shadow.png');
    final attackimage = await game.images.load('Skeleton1_Attack_with_shadow.png');
    final hurtimage = await game.images.load('Skeleton1_Hurt_with_shadow.png');
    final deathimage = await game.images.load('Skeleton1_Death_with_shadow.png');

    final idleSpriteSheet = SpriteSheet(image: idleimage, srcSize: Vector2.all(64.0), spacing: 0);
    final walkSpriteSheet = SpriteSheet(image: walkimage, srcSize: Vector2.all(64.0), spacing: 0);
    final attackSpriteSheet = SpriteSheet(image: attackimage, srcSize: Vector2.all(64.0), spacing: 0);
    final hurtSpriteSheet = SpriteSheet(image: hurtimage, srcSize: Vector2.all(64.0), spacing: 0);
    final deathSpriteSheet = SpriteSheet(image: deathimage, srcSize: Vector2.all(64.0), spacing: 0);

    animations = {
      EnemyStateFacing.idledown: idleSpriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 4),
      EnemyStateFacing.idleup: idleSpriteSheet.createAnimation(row: 1, stepTime: 0.1, to: 4),
      EnemyStateFacing.idleleft: idleSpriteSheet.createAnimation(row: 2, stepTime: 0.1, to: 4),
      EnemyStateFacing.idleright: idleSpriteSheet.createAnimation(row: 3, stepTime: 0.1, to: 4),

      EnemyStateFacing.walkdown: walkSpriteSheet.createAnimation(row: 0, stepTime: 0.05, to: 6),
      EnemyStateFacing.walkup: walkSpriteSheet.createAnimation(row: 1, stepTime: 0.05, to: 6),
      EnemyStateFacing.walkleft: walkSpriteSheet.createAnimation(row: 2, stepTime: 0.05, to: 6),
      EnemyStateFacing.walkright: walkSpriteSheet.createAnimation(row: 3, stepTime: 0.05, to: 6),

      EnemyStateFacing.attackdown: attackSpriteSheet.createAnimation(row: 0, stepTime: 0.07, to: 9, loop: false),
      EnemyStateFacing.attackup: attackSpriteSheet.createAnimation(row: 1, stepTime: 0.07, to: 9, loop: false),
      EnemyStateFacing.attackleft: attackSpriteSheet.createAnimation(row: 2, stepTime: 0.07, to: 9, loop: false),
      EnemyStateFacing.attackright: attackSpriteSheet.createAnimation(row: 3, stepTime: 0.07, to: 9, loop: false),

      EnemyStateFacing.hurtdown: hurtSpriteSheet.createAnimation(row: 0, stepTime: 0.15, to: 4, loop: false),
      EnemyStateFacing.hurtup: hurtSpriteSheet.createAnimation(row: 1, stepTime: 0.15, to: 4, loop: false),
      EnemyStateFacing.hurtleft: hurtSpriteSheet.createAnimation(row: 2, stepTime: 0.15, to: 4, loop: false),
      EnemyStateFacing.hurtright: hurtSpriteSheet.createAnimation(row: 3, stepTime: 0.15, to: 4, loop: false),

      EnemyStateFacing.deaddown: deathSpriteSheet.createAnimation(row: 0, stepTime: 0.15, to: 6, loop: false),
      EnemyStateFacing.deadup: deathSpriteSheet.createAnimation(row: 1, stepTime: 0.15, to: 6, loop: false),
      EnemyStateFacing.deadleft: deathSpriteSheet.createAnimation(row: 2, stepTime: 0.15, to: 6, loop: false),
      EnemyStateFacing.deadright: deathSpriteSheet.createAnimation(row: 3, stepTime: 0.15, to: 6, loop: false),

      EnemyStateFacing.wakingupdown: SpriteAnimation.spriteList(
        deathSpriteSheet.createAnimation(row: 0, stepTime: 0.15, to: 5).frames.map((f) => f.sprite).toList().reversed.toList(),
        stepTime: 0.15,
        loop: false,
      ),
      EnemyStateFacing.wakingupup: SpriteAnimation.spriteList(
        deathSpriteSheet.createAnimation(row: 1, stepTime: 0.15, to: 5).frames.map((f) => f.sprite).toList().reversed.toList(),
        stepTime: 0.15,
        loop: false,
      ),
      EnemyStateFacing.wakingupleft: SpriteAnimation.spriteList(
        deathSpriteSheet.createAnimation(row: 2, stepTime: 0.15, to: 5).frames.map((f) => f.sprite).toList().reversed.toList(),
        stepTime: 0.15,
        loop: false,
      ),
      EnemyStateFacing.wakingupright: SpriteAnimation.spriteList(
        deathSpriteSheet.createAnimation(row: 3, stepTime: 0.15, to: 5).frames.map((f) => f.sprite).toList().reversed.toList(),
        stepTime: 0.15,
        loop: false,
      ),

      EnemyStateFacing.sleepingdown: SpriteAnimation.spriteList([deathSpriteSheet.getSprite(0, 5)], stepTime: 1, loop: false),
      EnemyStateFacing.sleepingup: SpriteAnimation.spriteList([deathSpriteSheet.getSprite(1, 5)], stepTime: 1, loop: false),
      EnemyStateFacing.sleepingleft: SpriteAnimation.spriteList([deathSpriteSheet.getSprite(2, 5)], stepTime: 1, loop: false),
      EnemyStateFacing.sleepingright: SpriteAnimation.spriteList([deathSpriteSheet.getSprite(3, 5)], stepTime: 1, loop: false),
    };

    enemyState = EnemyState.sleeping;
    enemyFacing = enemy_facings[rng.nextInt(4)];
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
    }

    if (!game.camera.canSee(this) && enemyState != EnemyState.sleeping) {
      goToSleep();
      return;
    }

    if (enemyState == EnemyState.attack) {
      priority = priority + 10;
      final ticker = animationTickers?[current];
      if (ticker != null && ticker.done()) {
        enemyState = EnemyState.idle;
        current = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);
      }
      return;
    }

    if (enemyState == EnemyState.walk && isMoving) {
      print('moving');
      final Vector2 startPos = targetPosition - (getFacingVector(this) * 16);
      movePercent += moveSpeed * dt;

      if (movePercent >= 1.0) {
        position.setFrom(targetPosition);
        movePercent = 0.0;
        isMoving = false;
        enemyState = EnemyState.idle;
        current = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);
      } else {
        position.setFrom(startPos + (targetPosition - startPos) * movePercent);
      }
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
  }

  void goToSleep() {
    enemyState = EnemyState.sleeping;
    current = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);
    final ticker = animationTickers?[current];
    ticker?.reset();
    ticker?.paused = true;
  }

  void attack() {
    playAnimationOnce(EnemyState.idle);
  }

  void playAnimationOnce(EnemyState resultstate) {
    // print('playing animation once with result state: $resultstate');
    // print('currentstate: ${current?.enemyState}');
    current = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);
    final ticker = animationTickers?[current];

    if (ticker != null) {
      ticker.reset();
      ticker.paused = false;
    }

    ticker?.onComplete = () {
      // print('switching to idle');
      enemyState = resultstate;
      current = EnemyStateFacing.fromStateFacing(enemyState, enemyFacing);
      // print(current);
    };
  }

  SpriteAnimation createReversingAnimation(SpriteSheet sheet, int row, int framecount, double steptime) {
    final indices = List<int>.generate(framecount, (index) => index);
    indices.addAll(List<int>.generate(framecount - 2, (index) => framecount - 2 - index));

    return SpriteAnimation.spriteList(
      indices.map((e) => sheet.getSprite(row, e)).toList(),
      stepTime: steptime,
      loop: true,
    );
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
