import 'package:dungeoncrawler/models/components/characters/enemies/enemy_states.dart';
import 'package:dungeoncrawler/models/components/characters/player/player_states.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class SpriteFactory {
  static Future<Map<PlayerStateFacing, SpriteAnimation>> createPlayerAnimations(
    Images images,
  ) async {
    final idleimage = await images.load('Swordsman_lvl1_Idle_with_shadow.png');
    final walkimage = await images.load('Swordsman_lvl1_Walk_with_shadow.png');
    final attackimage = await images.load(
      'Swordsman_lvl1_attack_with_shadow.png',
    );
    final hurtimage = await images.load('Swordsman_lvl1_Hurt_with_shadow.png');
    final deathimage = await images.load(
      'Swordsman_lvl1_Death_with_shadow.png',
    );

    final idleSpriteSheet = SpriteSheet(
      image: idleimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );
    final walkSpriteSheet = SpriteSheet(
      image: walkimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );
    final attackSpriteSheet = SpriteSheet(
      image: attackimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );
    final hurtSpriteSheet = SpriteSheet(
      image: hurtimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );
    final deathSpriteSheet = SpriteSheet(
      image: deathimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );

    const double idlespeed = 0.15;
    const double walkspeed = 0.08;
    const double attackspeed = 0.05;
    const double hurtspeed = 0.06;
    const double deathspeed = 0.15;

    return {
      PlayerStateFacing.idledown: createReversingAnimation(
        idleSpriteSheet,
        0,
        11,
        idlespeed,
      ),
      PlayerStateFacing.idleleft: createReversingAnimation(
        idleSpriteSheet,
        1,
        11,
        idlespeed,
      ),
      PlayerStateFacing.idleright: createReversingAnimation(
        idleSpriteSheet,
        2,
        11,
        idlespeed,
      ),
      PlayerStateFacing.idleup: createReversingAnimation(
        idleSpriteSheet,
        3,
        3,
        idlespeed,
      ),

      PlayerStateFacing.walkdown: walkSpriteSheet.createAnimation(
        row: 0,
        stepTime: walkspeed,
        to: 6,
      ),
      PlayerStateFacing.walkleft: walkSpriteSheet.createAnimation(
        row: 1,
        stepTime: walkspeed,
        to: 6,
      ),
      PlayerStateFacing.walkright: walkSpriteSheet.createAnimation(
        row: 2,
        stepTime: walkspeed,
        to: 6,
      ),
      PlayerStateFacing.walkup: walkSpriteSheet.createAnimation(
        row: 3,
        stepTime: walkspeed,
        to: 6,
      ),

      PlayerStateFacing.attackdown: attackSpriteSheet.createAnimation(
        row: 0,
        stepTime: attackspeed,
        to: 8,
        loop: false,
      ),
      PlayerStateFacing.attackleft: attackSpriteSheet.createAnimation(
        row: 1,
        stepTime: attackspeed,
        to: 8,
        loop: false,
      ),
      PlayerStateFacing.attackright: attackSpriteSheet.createAnimation(
        row: 2,
        stepTime: attackspeed,
        to: 8,
        loop: false,
      ),
      PlayerStateFacing.attackup: attackSpriteSheet.createAnimation(
        row: 3,
        stepTime: attackspeed,
        to: 8,
        loop: false,
      ),

      PlayerStateFacing.hurtdown: hurtSpriteSheet.createAnimation(
        row: 0,
        stepTime: hurtspeed,
        to: 5,
        loop: false,
      ),
      PlayerStateFacing.hurtleft: hurtSpriteSheet.createAnimation(
        row: 1,
        stepTime: hurtspeed,
        to: 5,
        loop: false,
      ),
      PlayerStateFacing.hurtright: hurtSpriteSheet.createAnimation(
        row: 2,
        stepTime: hurtspeed,
        to: 5,
        loop: false,
      ),
      PlayerStateFacing.hurtup: hurtSpriteSheet.createAnimation(
        row: 3,
        stepTime: hurtspeed,
        to: 5,
        loop: false,
      ),

      PlayerStateFacing.deaddown: deathSpriteSheet.createAnimation(
        row: 0,
        stepTime: deathspeed,
        to: 7,
        loop: false,
      ),
      PlayerStateFacing.deadleft: deathSpriteSheet.createAnimation(
        row: 1,
        stepTime: deathspeed,
        to: 7,
        loop: false,
      ),
      PlayerStateFacing.deadright: deathSpriteSheet.createAnimation(
        row: 2,
        stepTime: deathspeed,
        to: 7,
        loop: false,
      ),
      PlayerStateFacing.deadup: deathSpriteSheet.createAnimation(
        row: 3,
        stepTime: deathspeed,
        to: 7,
        loop: false,
      ),
    };
  }
  
  static Future<Map<EnemyStateFacing, SpriteAnimation>> createEnemyAnimations(
    Images images,
  ) async {
    final idleimage = await images.load('Skeleton1_Idle_with_shadow.png');
    final walkimage = await images.load('Skeleton1_Walk_with_shadow.png');
    final attackimage = await images.load('Skeleton1_Attack_with_shadow.png');
    final hurtimage = await images.load('Skeleton1_Hurt_with_shadow.png');
    final deathimage = await images.load('Skeleton1_Death_with_shadow.png');

    final idleSpriteSheet = SpriteSheet(
      image: idleimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );
    final walkSpriteSheet = SpriteSheet(
      image: walkimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );
    final attackSpriteSheet = SpriteSheet(
      image: attackimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );
    final hurtSpriteSheet = SpriteSheet(
      image: hurtimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );
    final deathSpriteSheet = SpriteSheet(
      image: deathimage,
      srcSize: Vector2.all(64.0),
      spacing: 0,
    );

    const double idlespeed = 0.1;
    const double walkspeed = 0.08;
    const double attackspeed = 0.05;
    const double hurtspeed = 0.06;
    const double wakespeed = 0.15;
    const double deathspeed = 0.15;

    return {
      EnemyStateFacing.idledown: idleSpriteSheet.createAnimation(
        row: 0,
        stepTime: idlespeed,
        to: 4,
      ),
      EnemyStateFacing.idleup: idleSpriteSheet.createAnimation(
        row: 1,
        stepTime: idlespeed,
        to: 4,
      ),
      EnemyStateFacing.idleleft: idleSpriteSheet.createAnimation(
        row: 2,
        stepTime: idlespeed,
        to: 4,
      ),
      EnemyStateFacing.idleright: idleSpriteSheet.createAnimation(
        row: 3,
        stepTime: idlespeed,
        to: 4,
      ),

      EnemyStateFacing.walkdown: walkSpriteSheet.createAnimation(
        row: 0,
        stepTime: walkspeed,
        to: 6,
      ),
      EnemyStateFacing.walkup: walkSpriteSheet.createAnimation(
        row: 1,
        stepTime: walkspeed,
        to: 6,
      ),
      EnemyStateFacing.walkleft: walkSpriteSheet.createAnimation(
        row: 2,
        stepTime: walkspeed,
        to: 6,
      ),
      EnemyStateFacing.walkright: walkSpriteSheet.createAnimation(
        row: 3,
        stepTime: walkspeed,
        to: 6,
      ),

      EnemyStateFacing.attackdown: attackSpriteSheet.createAnimation(
        row: 0,
        stepTime: attackspeed,
        to: 9,
        loop: false,
      ),
      EnemyStateFacing.attackup: attackSpriteSheet.createAnimation(
        row: 1,
        stepTime: attackspeed,
        to: 9,
        loop: false,
      ),
      EnemyStateFacing.attackleft: attackSpriteSheet.createAnimation(
        row: 2,
        stepTime: attackspeed,
        to: 9,
        loop: false,
      ),
      EnemyStateFacing.attackright: attackSpriteSheet.createAnimation(
        row: 3,
        stepTime: attackspeed,
        to: 9,
        loop: false,
      ),

      EnemyStateFacing.hurtdown: hurtSpriteSheet.createAnimation(
        row: 0,
        stepTime: hurtspeed,
        to: 4,
        loop: false,
      ),
      EnemyStateFacing.hurtup: hurtSpriteSheet.createAnimation(
        row: 1,
        stepTime: hurtspeed,
        to: 4,
        loop: false,
      ),
      EnemyStateFacing.hurtleft: hurtSpriteSheet.createAnimation(
        row: 2,
        stepTime: hurtspeed,
        to: 4,
        loop: false,
      ),
      EnemyStateFacing.hurtright: hurtSpriteSheet.createAnimation(
        row: 3,
        stepTime: hurtspeed,
        to: 4,
        loop: false,
      ),

      EnemyStateFacing.deaddown: deathSpriteSheet.createAnimation(
        row: 0,
        stepTime: deathspeed,
        to: 6,
        loop: false,
      ),
      EnemyStateFacing.deadup: deathSpriteSheet.createAnimation(
        row: 1,
        stepTime: deathspeed,
        to: 6,
        loop: false,
      ),
      EnemyStateFacing.deadleft: deathSpriteSheet.createAnimation(
        row: 2,
        stepTime: deathspeed,
        to: 6,
        loop: false,
      ),
      EnemyStateFacing.deadright: deathSpriteSheet.createAnimation(
        row: 3,
        stepTime: deathspeed,
        to: 6,
        loop: false,
      ),

      EnemyStateFacing.wakingupdown: SpriteAnimation.spriteList(
        deathSpriteSheet
            .createAnimation(row: 0, stepTime: wakespeed, to: 5)
            .frames
            .map((f) => f.sprite)
            .toList()
            .reversed
            .toList(),
        stepTime: wakespeed,
        loop: false,
      ),
      EnemyStateFacing.wakingupup: SpriteAnimation.spriteList(
        deathSpriteSheet
            .createAnimation(row: 1, stepTime: wakespeed, to: 5)
            .frames
            .map((f) => f.sprite)
            .toList()
            .reversed
            .toList(),
        stepTime: wakespeed,
        loop: false,
      ),
      EnemyStateFacing.wakingupleft: SpriteAnimation.spriteList(
        deathSpriteSheet
            .createAnimation(row: 2, stepTime: wakespeed, to: 5)
            .frames
            .map((f) => f.sprite)
            .toList()
            .reversed
            .toList(),
        stepTime: wakespeed,
        loop: false,
      ),
      EnemyStateFacing.wakingupright: SpriteAnimation.spriteList(
        deathSpriteSheet
            .createAnimation(row: 3, stepTime: wakespeed, to: 5)
            .frames
            .map((f) => f.sprite)
            .toList()
            .reversed
            .toList(),
        stepTime: wakespeed,
        loop: false,
      ),

      EnemyStateFacing.sleepingdown: SpriteAnimation.spriteList(
        [deathSpriteSheet.getSprite(0, 5)],
        stepTime: 1,
        loop: false,
      ),
      EnemyStateFacing.sleepingup: SpriteAnimation.spriteList(
        [deathSpriteSheet.getSprite(1, 5)],
        stepTime: 1,
        loop: false,
      ),
      EnemyStateFacing.sleepingleft: SpriteAnimation.spriteList(
        [deathSpriteSheet.getSprite(2, 5)],
        stepTime: 1,
        loop: false,
      ),
      EnemyStateFacing.sleepingright: SpriteAnimation.spriteList(
        [deathSpriteSheet.getSprite(3, 5)],
        stepTime: 1,
        loop: false,
      ),
    };
  }

  
}

SpriteAnimation createReversingAnimation(
  SpriteSheet sheet,
  int row,
  int framecount,
  double steptime,
) {
  final indices = List<int>.generate(framecount, (index) => index);
  indices.insertAll(0, List<int>.generate(10, (index) => 0));
  indices.addAll(List<int>.generate(10, (index) => framecount - 1));
  indices.addAll(
    List<int>.generate(framecount - 2, (index) => framecount - 2 - index),
  );

  return SpriteAnimation.spriteList(
    indices.map((e) => sheet.getSprite(row, e)).toList(),
    stepTime: steptime,
    loop: true,
  );
}
