// import 'package:bonfire/bonfire.dart';
// import 'package:dungeoncrawler/models/torches.dart';
// import 'package:flutter/material.dart';

// class TorchDecoration extends GameDecoration {
//   TorchDecoration({required super.position, required TorchType type})
//     : super.withAnimation(
//         animation: Future.value(torchAnimations[type]!.clone()),
//         size: Vector2.all(48),
//         anchor: Anchor.center,
//       ) {
//     setupLighting(
//       LightingConfig(
//         radius: 64,
//         blurBorder: 20,
//         color: Colors.blue.withValues(alpha: 0.1),
//         withPulse: true,
//       ),
//     );
//   }
// }

// Map<TorchType, SpriteAnimation> torchAnimations = {};

// Future<void> loadTorchAnimations(Images images) async {
//   final torchimage = await images.load('torches.png');
//   final torchSpriteSheet = SpriteSheet(image: torchimage, srcSize: Vector2.all(48), spacing: 0);
//   for (var type in TorchType.values) {
//     final List<Vector2> frames = type.frames.map((e) => Vector2(e['x']!, e['y']!)).toList();
//     torchAnimations[type] = SpriteAnimation.spriteList(
//       frames.map((e) => torchSpriteSheet.getSprite(e.y.toInt(), e.x.toInt())).toList(),
//       stepTime: 0.15,
//       loop: true,
//     );
//   }
// }
