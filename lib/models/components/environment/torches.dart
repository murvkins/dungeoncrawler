import 'package:dungeoncrawler/game/dungeoncrawl_game.dart';
import 'package:dungeoncrawler/models/components/environment/lighting.dart';
import 'package:flame/components.dart';

class Torch extends SpriteAnimationComponent with HasGameReference<DungeonCrawl> {
  final LightingConfig lightingConfig;

  Torch({
    required SpriteAnimation animation,
    required Vector2 position,
    required int priority,
    required this.lightingConfig,
  }) : super(
         animation: animation,
         position: position,
         size: Vector2.all(48),
         anchor: Anchor.center,
         priority: priority,
       );

  @override
  void update(double dt) {
    super.update(dt);
    lightingConfig.update(dt);
  }

  final Map<TorchType, SpriteAnimation> torchAnimations = {};

  // @override
  // void onMount() {
  //   super.onMount();
  //   // priority = priority;
  //   //priority = (position.y / 16.0).floor();
  // }
}

enum TorchType {
  brazier([
    {'x': 0, 'y': 0},
    {'x': 0, 'y': 1},
    {'x': 0, 'y': 2},
    {'x': 0, 'y': 3},
    {'x': 0, 'y': 4},
    {'x': 0, 'y': 5},
  ]),
  small_torch([
    {'x': 1, 'y': 0},
    {'x': 1, 'y': 1},
    {'x': 1, 'y': 2},
    {'x': 1, 'y': 3},
    {'x': 1, 'y': 4},
    {'x': 1, 'y': 5},
  ]),
  medium_torch([
    {'x': 2, 'y': 0},
    {'x': 2, 'y': 1},
    {'x': 2, 'y': 2},
    {'x': 2, 'y': 3},
    {'x': 2, 'y': 4},
    {'x': 2, 'y': 5},
  ]),
  ;

  final List<Map<String, double>> frames;
  const TorchType(this.frames);
}
