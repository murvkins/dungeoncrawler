// import 'package:bonfire/bonfire.dart';
// import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
// import 'package:dungeoncrawler/models/floor_tiles.dart';

// class CollisionBlock extends GameDecoration {
//   final Vector2 hitboxSize;

//   CollisionBlock({required super.position, required super.size, required this.hitboxSize});

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     add(RectangleHitbox(size: hitboxSize, isSolid: true));
//   }
// }

// List<GameDecoration> buildCollisionBlocks(DungeonState state) {
//   final floor = state.dungeon.floors.last;
//   final List<GameDecoration> blocks = [];
//   final visited = List.generate(floor.width, (_) => List.filled(floor.height, false));

//   for (int y = 0; y < floor.height; y++) {
//     for (int x = 0; x < floor.width; x++) {
//       final tile = floor.walls.grid[x][y];
//       if (tile != null && !nocollisions.contains(tile) && !visited[x][y]) {
//         int startx = x;
//         int starty = y;
//         int width = 0;
//         int height = 1;

//         int scanx = x;
//         while (scanx < floor.width && floor.walls.grid[scanx][y] != null && !visited[scanx][y]) {
//           // visited[x][y] = true;
//           width++;
//           scanx++;
//         }

//         bool canExpandDown = true;
//         while (canExpandDown && (starty + height) < floor.height) {
//           int nexty = starty + height;
//           for (int cx = startx; cx < startx + width; cx++) {
//             final tile = floor.walls.grid[cx][nexty];
//             if (tile == null || visited[cx][nexty] || nocollisions.contains(tile)) {
//               canExpandDown = false;
//               break;
//             }
//           }
//           if (canExpandDown) {
//             height++;
//           }
//         }

//         for (int vy = starty; vy < starty + height; vy++) {
//           for (int vx = startx; vx < startx + width; vx++) {
//             visited[vx][vy] = true;
//           }
//         }

//         blocks.add(
//           CollisionBlock(
//             position: Vector2(startx * 16.0, starty * 16.0),
//             size: Vector2(width * 16.0, height * 16.0),
//             hitboxSize: Vector2(width * 16.0, height * 16.0),
//           ),
//         );
//       }
//     }
//   }

//   return blocks;
// }
