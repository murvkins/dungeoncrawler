import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

extension SpriteSheetHelpers on SpriteSheet {
  Sprite getSpriteGroup(int row, int col, int width, int height) {
    return Sprite(
      image,
      srcPosition: Vector2(col * 16.0, row * 16.0),
      srcSize: Vector2(width * 16.0, height * 16.0),
    );
  }
}
