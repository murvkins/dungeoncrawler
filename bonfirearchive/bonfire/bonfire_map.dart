// import 'package:bonfire/bonfire.dart';
// import 'package:bonfire/map/base/layer.dart';
// import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
// import 'package:dungeoncrawler/models/bonfire/bonfire_torch.dart';
// import 'package:dungeoncrawler/models/dungeon_floors.dart';
// import 'package:dungeoncrawler/models/floor_tiles.dart';
// import 'package:dungeoncrawler/models/props.dart';
// import 'package:dungeoncrawler/models/torches.dart';

// class BonfireGenerateMap extends WorldMap {
//   BonfireGenerateMap(List<Tile> floor, List<Tile> walls)
//     : super([
//         Layer(id: 0, tiles: floor),
//         Layer(id: 1, tiles: walls),
//       ]);

//   factory BonfireGenerateMap.fromState(DungeonState state) {
//     if (state.dungeon.floors.isEmpty) {
//       return BonfireGenerateMap([], []);
//     }
//     final floor = state.dungeon.floors.last;
//     final List<Tile> floorTiles = [];
//     final List<Tile> wallTiles = [];

//     for (int y = 0; y < floor.height; y++) {
//       for (int x = 0; x < floor.width; x++) {
//         final floortile = floor.floortiles.grid[x][y];
//         if (floortile != null) {
//           floorTiles.add(
//             Tile(
//               x: x.toDouble(),
//               y: y.toDouble(),
//               width: 16,
//               height: 16,
//               sprite: TileSprite(
//                 path: 'walls_floor2.png',
//                 position: Vector2(floortile.tilecol.toDouble(), floortile.tilerow.toDouble()),
//                 size: Vector2.all(16.0),
//               ),
//             ),
//           );
//         }

//         final walltile = floor.walls.grid[x][y];
//         if (walltile != null && walltile != TileType.blank_tile) {
//           wallTiles.add(
//             Tile(
//               x: x.toDouble(),
//               y: y.toDouble(),
//               width: 16,
//               height: 16,
//               sprite: TileSprite(
//                 path: 'walls_floor2.png',
//                 position: Vector2(walltile.tilecol.toDouble(), walltile.tilerow.toDouble()),
//                 size: Vector2.all(16.0),
//               ),
//             ),
//           );
//         }
//       }
//     }
//     print('tiles done');
//     return BonfireGenerateMap(floorTiles, wallTiles);
//   }
// }

// bool canPlaceTorch(Floor floor, DecorationTileLayer decorations, int x, int y) {
//   const int buffer = 2;
//   for (int dy = y - buffer; dy < y + buffer; dy++) {
//     for (int dx = x - buffer; dx < x + buffer; dx++) {
//       if (dx > 0 && dy > 0 && dx < floor.width && dy < floor.height) {
//         if (decorations.grid[dx][dy] == Props.cornertorch) return false;
//       }
//     }
//   }
//   return true;
// }

// List<GameDecoration> buildDecorations(DungeonState state) {
//   final floor = state.dungeon.floors.last;
//   final List<GameDecoration> decorations = [];

//   for (int y = 0; y < floor.height; y++) {
//     for (int x = 0; x < floor.width; x++) {
//       final prop = floor.decorations.grid[x][y];
//       if (prop != null && prop != Props.alpha_tile) {
//         String path;
//         double yoffset = 0;
//         if (prop.top_row_is_traversible) {
//           yoffset = 16.0;
//         }

//         switch (prop.sheettype) {
//           case SheetType.cratesbarrels:
//             path = 'Objects.png';
//             decorations.add(
//               GameDecoration.withSprite(
//                 sprite: Sprite.load(
//                   path,
//                   srcPosition: Vector2(prop.startx * 16, prop.starty * 16),
//                 ),
//                 position: Vector2(x * 16, y * 16),
//                 size: Vector2(prop.width * 16, prop.height * 16),
//               )..add(
//                 RectangleHitbox(
//                   position: Vector2(0, 0 + yoffset),
//                   isSolid: true,
//                   size: Vector2(
//                     prop.width * 16,
//                     prop.height * 16 - yoffset,
//                   ),
//                 ),
//               ),
//             );
//             break;
//           case SheetType.coffins:
//             path = 'coffins.png';
//             decorations.add(
//               GameDecoration.withSprite(
//                 sprite: Sprite.load(
//                   path,
//                   srcPosition: Vector2(prop.startx * 16, prop.starty * 16),
//                 ),
//                 position: Vector2(x * 16, y * 16),
//                 size: Vector2(prop.width * 16, prop.height * 16),
//               )..add(
//                 RectangleHitbox(
//                   position: Vector2(0, 0 + yoffset),
//                   isSolid: true,
//                   size: Vector2(
//                     prop.width * 16,
//                     prop.height * 16 - yoffset,
//                   ),
//                 ),
//               ),
//             );
//             break;
//           case SheetType.torches:
//             path = 'torches.png';
//             if (prop == Props.cornertorch) {
//               decorations.add(
//                 TorchDecoration(
//                   position: Vector2(x * 16, y * 16),
//                   type: TorchType.values[rng.nextInt(2) + 1],
//                 ),
//               );
//             } else if (canPlaceTorch(state.dungeon.floors.last, floor.decorations, x, y)) {
//               decorations.add(
//                 TorchDecoration(
//                   position: Vector2(x * 16, y * 16),
//                   type: TorchType.values[rng.nextInt(2) + 1],
//                 ),
//               );
//             }
//             continue;
//         }
//       }
//     }
//   }
//   print('returning decorations');
//   return decorations;
// }