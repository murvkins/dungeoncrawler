import 'package:dungeoncrawler/game/game.dart';
import 'package:dungeoncrawler/models/components/environment/torches.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

class DarknessLayer extends Component with HasCollisionDetection, HasGameReference<DungeonCrawl> {
  Ray2? ray;
  Ray2? reflections;
  bool isOriginCasted = false;
  Paint paint = Paint();

  static const numberOfRays = 2000;
  final List<Ray2> rays = [];
  final List<RaycastResult<ShapeHitbox>> results = [];

  @override
  void render(Canvas canvas) {
    final floor = game.dungeonBloc.state.dungeon.floors.last;
    final Rect rect = Rect.fromLTWH(0, 0, floor.width * 16.0, floor.height * 16.0);
    canvas.saveLayer(rect, Paint());

    canvas.drawRect(rect, Paint()..color = const Color(0xF0000000));

    final lightPaint = Paint()..blendMode = BlendMode.dstOut;

    final torches = game.world.children.whereType<Torch>();

    for (final torch in torches) {
      if (shouldRenderTorchLight(torch)) {
        final config = torch.lightingConfig;
        double currentradius = config.radius + (config.radius * config.valuePulse);

        lightPaint.maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          config.blurBorder * 0.57735 + 0.5,
        );

        final pos = torch.position;

        canvas.drawCircle(
          Offset(pos.x, pos.y),
          currentradius,
          lightPaint,
        );
      }
    }

    if (game.player != null) {
      final drawX = game.camera.viewfinder.position.x + 8;
      final drawY = game.camera.viewfinder.position.y + 8;
      final config = game.player?.lightingConfig;
      double currentradius = config!.radius + (config.radius * config.valuePulse);

      lightPaint.maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        config.blurBorder * 0.57735 + 0.5,
      );

      canvas.drawCircle(Offset(drawX, drawY), currentradius, lightPaint);
    }
    canvas.restore();
    super.render(canvas);
  }

  bool shouldRenderTorchLight(Torch torch) {
    Vector2 tp = torch.position;
    const double buffer = 40;
    Rect size = game.camera.viewport.virtualSize.toRect();
    Vector2 vpos = game.camera.viewfinder.position;
    if (game.camera.canSee(torch)) return true;

    return (tp.x > vpos.x - (size.width / 2) - buffer &&
        tp.x < vpos.x + (size.width / 2) + buffer &&
        tp.y > vpos.y - (size.height / 2) - 40 &&
        tp.y < vpos.y + (size.height / 2) + 40);
  }
}

// List<LineSegment> getWallSegments(Floor floor) {
//   final segments = <LineSegment>[];
//   for (int y = 0; y < floor.height; y++) {
//     for (int x = 0; x < floor.width; x++) {
//       if (floor.walls.grid[x][y] != null) {
//         final topL = Vector2(x * 16.0, y * 16.0);
//         final topR = Vector2((x + 1) * 16.0, y * 16.0);
//         final bottomL = Vector2(x * 16, (y + 1) * 1);
//         final bottomR = Vector2((x + 1) * 16, (y + 1) * 16);

//         segments.add(LineSegment(topL, topR));
//         segments.add(LineSegment(topR, bottomR));
//         segments.add(LineSegment(topL, bottomL));
//         segments.add(LineSegment(bottomL, bottomR));
//       }
//     }
//   }
//   return segments;
// }
