// import 'dart:async';

// import 'package:bonfire/bonfire.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class BonfirePlayer extends SimplePlayer with BlockMovementCollision, Lighting, KeyboardEventListener, PathFinding {
//   BonfirePlayer({
//     required super.position,
//     required SpriteSheet idleSpriteSheet,
//     required SpriteSheet walkSpriteSheet,
//     required SpriteSheet attackSpriteSheet,
//   }) : super(
//          size: Vector2.all(64),
//          speed: 16,
//          life: 10,
//          animation: SimpleDirectionAnimation(
//            idleRight: Future.value(createReversingAnimation(idleSpriteSheet, 2, 11, 0.15)),
//            idleLeft: Future.value(createReversingAnimation(idleSpriteSheet, 1, 11, 0.15)),
//            idleUp: Future.value(createReversingAnimation(idleSpriteSheet, 3, 3, 0.15)),
//            idleDown: Future.value(createReversingAnimation(idleSpriteSheet, 0, 11, 0.15)),
//            runDown: Future.value(walkSpriteSheet.createAnimation(row: 0, stepTime: 0.05, to: 5)),
//            runLeft: Future.value(walkSpriteSheet.createAnimation(row: 1, stepTime: 0.05, to: 5)),
//            runRight: Future.value(walkSpriteSheet.createAnimation(row: 2, stepTime: 0.05, to: 5)),
//            runUp: Future.value(walkSpriteSheet.createAnimation(row: 3, stepTime: 0.05, to: 5)),
//          ),
//        ) {
//     setupLighting(
//       LightingConfig(
//         radius: 150.0,
//         blurBorder: 30,
//         color: Colors.transparent,
//       ),
//     );
//     setupPathFinding(pathLineColor: Colors.lightBlueAccent.withValues(alpha: 0.5), pathLineStrokeWidth: 4);
//   }

//   bool isMoving = false;
//   final Set<LogicalKeyboardKey> _pressedKeys = {};

//   @override
//   Future<void> onLoad() async {
//     add(RectangleHitbox(size: Vector2.all(16), position: Vector2(24, 32), anchor: Anchor.topLeft));
//     return super.onLoad();
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     // print(isMoving);
//     if (isMoving) return;
//     _checkInput();
//   }

//   @override
//   void moveRight({double? speed}) => animation?.play(SimpleAnimationEnum.runRight);
//   @override
//   void moveLeft({double? speed}) => animation?.play(SimpleAnimationEnum.runLeft);
//   @override
//   void moveUp({double? speed}) => animation?.play(SimpleAnimationEnum.runUp);
//   @override
//   void moveDown({double? speed}) => animation?.play(SimpleAnimationEnum.runDown);

//   @override
//   void moveFromAngle(double angle, {double? speed}) {}

//   @override
//   bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
//     _pressedKeys.clear();
//     _pressedKeys.addAll(keysPressed);
//     return super.onKeyboard(event, keysPressed);
//   }

//   void _checkInput() {
//     // print(isMoving);
//     if (isMoving) return;

//     Direction? dir;

//     if (_pressedKeys.contains(LogicalKeyboardKey.keyA)) {
//       dir = Direction.left;
//     } else if (_pressedKeys.contains(LogicalKeyboardKey.keyD)) {
//       dir = Direction.right;
//     } else if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) {
//       dir = Direction.up;
//     } else if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) {
//       dir = Direction.down;
//     }

//     if (dir != null) {
//       double posx = (position.x / 16.0).roundToDouble() * 16.0 - 8;
//       double posy = (position.y / 16.0).roundToDouble() * 16.0;
//       final Vector2 displacement = _getVectorFromDirection(dir) * 16.0;

//       final target = Vector2(posx + displacement.x, posy + displacement.y);

//       if (_canMoveTo(target)) {
//         _startMove(target, dir);
//       }
//     }
//   }

//   static SpriteAnimation createReversingAnimation(SpriteSheet sheet, int row, int framecount, double steptime) {
//     final indices = List<int>.generate(framecount, (index) => index);
//     indices.insertAll(0, List<int>.generate(10, (index) => 0));
//     indices.addAll(List<int>.generate(10, (index) => framecount - 1));
//     indices.addAll(List<int>.generate(framecount - 2, (index) => framecount - 2 - index));

//     return SpriteAnimation.spriteList(
//       indices.map((e) => sheet.getSprite(row, e)).toList(),
//       stepTime: steptime,
//       loop: true,
//     );
//   }

//   Vector2 _getVectorFromDirection(Direction dir) {
//     switch (dir) {
//       case Direction.left:
//         return Vector2(-1, 0);
//       case Direction.right:
//         return Vector2(1, 0);
//       case Direction.up:
//         return Vector2(0, -1);
//       case Direction.down:
//         return Vector2(0, 1);
//       default:
//         return Vector2.zero();
//     }
//   }

//   void _startMove(Vector2 target, Direction dir) {
//     isMoving = true;
//     _moveInDirection(dir);
//     add(
//       MoveEffect.to(
//         target,
//         EffectController(
//           duration: 0.1,
//           curve: Curves.linear,
//         ),
//         onComplete: () {
//           isMoving = false;
//           final currentKey = _getDirectionKey(dir);
//           if (currentKey != null && _pressedKeys.contains(currentKey)) {
//             final nextTarget = target + (_getVectorFromDirection(dir) * 16.0);

//             if (_canMoveTo(nextTarget)) {
//               _startMove(nextTarget, dir);
//               return;
//             }
//           }

//           stopMove(forceIdle: true);
//           idle();
//         },
//       ),
//     );
//   }

//   LogicalKeyboardKey? _getDirectionKey(Direction dir) {
//     switch (dir) {
//       case Direction.left:
//         return LogicalKeyboardKey.keyA;
//       case Direction.right:
//         return LogicalKeyboardKey.keyD;
//       case Direction.up:
//         return LogicalKeyboardKey.keyW;
//       case Direction.down:
//         return LogicalKeyboardKey.keyS;
//       default:
//         return null;
//     }
//   }

//   void _moveInDirection(Direction dir) {
//     switch (dir) {
//       case Direction.left:
//         moveLeft();
//         break;
//       case Direction.right:
//         moveRight();
//         break;
//       case Direction.up:
//         moveUp();
//         break;
//       case Direction.down:
//         moveDown();
//         break;
//       default:
//         break;
//     }
//   }

//   bool _canMoveTo(Vector2 targetPos) {
//     final test = Rect.fromLTWH(targetPos.x + 24, targetPos.y + 32, 16.0, 16.0);
//     final hitboxes = gameRef.collisions(onlyVisible: true);
//     for (final hitbox in hitboxes) {
//       if (hitbox.parent == this) continue;
//       if (hitbox.toRect().overlaps(test)) {
//         print('cant move');
//         return false;
//       }
//     }
//     return true;
//   }
// }
