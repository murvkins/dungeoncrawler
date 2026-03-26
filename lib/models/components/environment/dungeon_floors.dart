import 'dart:math';

import 'package:dungeoncrawler/models/components/characters/enemies/enemy.dart';
import 'package:dungeoncrawler/models/components/environment/props.dart';
import 'package:dungeoncrawler/models/components/environment/floor_tiles.dart';

class Dungeon {
  final List<Floor> floors;

  const Dungeon({required this.floors});

  factory Dungeon.empty() {
    return const Dungeon(floors: []);
  }

  Dungeon addFloor() {
    print('adding floor');
    return Dungeon(floors: [...floors, Floor.newFloor()]);
  }
}

class Floor {
  int width;
  int height;
  FloorTileLayer walls; //non-movable areas
  FloorTileLayer floortiles; //moveable areas
  DecorationTileLayer decorations;
  List<Room> rooms;
  List<Corridor> corridors;
  List<Enemy> enemies;
  // FloorTileLayer? interactables; //chests, items, loot
  // FloorTileLayer characters; //player and enemies

  Floor({
    required this.width,
    required this.height,
    required this.walls,
    required this.floortiles,
    required this.rooms,
    required this.decorations,
    required this.corridors,
    required this.enemies,
    // this.interactables,
    // required this.characters,
  });

  factory Floor.newFloor({
    int minRoomSize = 5,
    int maxRoomSize = 20,
  }) {
    int maxRooms = Random().nextInt(5) + 8;
    Floor floor = Floor(
      width: floorwidth,
      height: floorheight,
      walls: FloorTileLayer.fillLayer(TileType.blank_tile, floorwidth, floorheight),
      floortiles: FloorTileLayer.fillLayer(null, floorwidth, floorheight),
      decorations: DecorationTileLayer.fillLayer(null, floorwidth, floorheight),
      rooms: [],
      corridors: [],
      enemies: [],
    );

    int retries = 0;
    int maxretries = 50;

    for (int i = 0; i < maxRooms; i++) {
      final roomwidth = rng.nextInt(maxRoomSize - minRoomSize + 1) + minRoomSize;
      final roomheight = rng.nextInt(maxRoomSize - minRoomSize + 1) + minRoomSize;

      final widthwithwalls = roomwidth + 2;
      final heightwithwalls = roomheight + 4;

      final rx = rng.nextInt(floorwidth - widthwithwalls - 1) + 1;
      final ry = rng.nextInt(floorheight - heightwithwalls - 1) + 1;

      final newroom = Room(x: rx, y: ry, width: widthwithwalls, height: heightwithwalls, connections: []);
      bool overlaps = floor.rooms.any((room) => newroom.intersects(room));
      if (overlaps) {
        retries++;
        if (retries <= maxretries) {
          i--;
        } else {
          retries = 0;
        }
        continue;
      }

      for (int y = 0; y < heightwithwalls; y++) {
        for (int x = 0; x < widthwithwalls; x++) {
          final worldX = x + rx;
          final worldY = y + ry;

          switch (y) {
            case 0:
              //top wall
              final index = x == 0
                  ? 0
                  : x == widthwithwalls - 1
                  ? 2
                  : 1;
              floor.walls.grid[worldX][worldY] = roomTopWallTop[index];
              floor.walls.grid[worldX][worldY + 1] = roomTopWallMid[index];
              floor.walls.grid[worldX][worldY + 2] = roomTopWallBottom[index];
              floor.floortiles.grid[worldX][worldY + 2] = floor_tiles[rng.nextInt(floor_tiles.length)];
              if (x == widthwithwalls - 1) y += 2;
              continue;
            case int val when val > 2 && val < heightwithwalls - 1:
              //side walls
              if (x == 0) {
                floor.walls.grid[worldX][worldY] = TileType.room_leftWall;
                floor.floortiles.grid[worldX][worldY] = floor_tiles[rng.nextInt(floor_tiles.length)];
              } else if (x == widthwithwalls - 1) {
                floor.walls.grid[worldX][worldY] = TileType.room_rightWall;
                floor.floortiles.grid[worldX][worldY] = floor_tiles[rng.nextInt(floor_tiles.length)];
              } else {
                floor.walls.grid[worldX][worldY] = null;
                floor.floortiles.grid[worldX][worldY] = floor_tiles[rng.nextInt(floor_tiles.length)];
              }
              continue;
            default:
              //bottom wall
              final index = x == 0
                  ? 0
                  : x == widthwithwalls - 1
                  ? 2
                  : 1;
              floor.walls.grid[worldX][worldY] = roomBottomWall[index];
              floor.floortiles.grid[worldX][worldY] = floor_tiles[rng.nextInt(floor_tiles.length)];
          }
        }
      }

      floor.decorations.grid[newroom.x + 1][newroom.y] = Props.cornertorch;
      floor.decorations.grid[newroom.x + newroom.width - 3][newroom.y] = Props.cornertorch;
      floor.decorations.grid[newroom.x + 1][newroom.y + newroom.height - 2] = Props.cornertorch;
      floor.decorations.grid[newroom.x + newroom.width - 3][newroom.y + newroom.height - 2] = Props.cornertorch;

      floor.rooms.add(newroom);
    }

    for (int r = 0; r < floor.rooms.length; r++) {
      final currentroom = floor.rooms[r];
      final corridorwidth = 1; //rng.nextInt(floor_tiles.length) + 1;

      for (int nr = 1; nr < floor.rooms.length; nr++) {
        if (r == nr) continue;

        final other = floor.rooms[nr];

        if (!currentroom.connections!.contains(nr) && !other.connections!.contains(r)) {
          if (connectRooms(floor, floor.rooms, currentroom, other, corridorwidth)) {
            currentroom.connections!.add(floor.rooms.indexWhere((element) => element == other));
            other.connections!.add(floor.rooms.indexWhere((element) => element == currentroom));
            nr = floor.rooms.length;
          }
        }
      }
    }

    placeProps(floor);

    final allgroups = findAllGroups(floor.rooms);

    if (allgroups.length > 1) {
      print('re-doing floor');
      floor = Floor.newFloor();
    } else {
      return floor;
    }

    return floor;
  }
}

bool checkXRangesOverlap(Room a, Room b) {
  final aMin = a.x + 1;
  final aMax = a.x + a.width - 1;
  final bMin = b.x + 1;
  final bMax = b.x + b.width - 1;

  return max(aMin, bMin) < min(aMax, bMax);
}

bool checkYRangesOverlap(Room a, Room b) {
  final aMin = a.y + 3;
  final aMax = a.y + a.height - 1;
  final bMin = b.y + 3;
  final bMax = b.y + b.height - 1;

  return max(aMin, bMin) < min(aMax, bMax);
}

bool hallwayIntersectsOtherRoom(Floor floor, List<Room> rooms, int r, int nr, Rectangle hallway) {
  for (int cr = 0; cr < floor.rooms.length; cr++) {
    if (cr == r || nr == r) continue;
    Room other = floor.rooms[cr];
    if (hallway.intersects(other.asRect())) return true;
  }
  return false;
}

bool canPlaceHorizontalHallway(
  Floor floor,
  int x1,
  int x2,
  int y,
  int width,
  Room a,
  Room b,
) {
  final start = min(x1, x2) - 1;
  final end = max(x1, x2) + 1;

  final half = width ~/ 2;

  for (int x = start; x <= end; x++) {
    for (int w = -half - 3; w <= half + 1; w++) {
      final checkY = y + w;

      if (checkY < 0 || checkY >= floorheight || x < 0 || x >= floorwidth) {
        return false;
      }

      if (floor.walls.grid[x][checkY] != TileType.blank_tile && !a.belongsToRoom(x, checkY) && !b.belongsToRoom(x, checkY)) return false;
    }
  }
  return true;
}

bool canPlaceVerticalHallway(
  Floor floor,
  int y1,
  int y2,
  int x,
  int width,
  Room a,
  Room b,
) {
  final start = min(y1, y2) - 1;
  final end = max(y1, y2) + 1;

  final half = width ~/ 2;

  for (int y = start; y <= end; y++) {
    for (int w = -half - 1; w <= half + 1; w++) {
      final checkX = x + w;

      if (checkX < 0 || checkX >= floorwidth || y < 0 || y >= floorheight) {
        return false;
      }

      if (floor.walls.grid[checkX][y] != TileType.blank_tile && !a.belongsToRoom(checkX, y) && !b.belongsToRoom(checkX, y)) return false;
    }
  }
  return true;
}

void placeHorizontalHallway(
  Floor floor,
  int x1,
  int x2,
  int y,
  int width,
) {
  final start = min(x1, x2);
  final end = max(x1, x2);

  final half = width ~/ 2;

  const int torchspacing = 6;
  bool torchside = rng.nextBool();
  int torchstart = 0;

  floor.corridors.add(Corridor(height: 5, width: end - start, x: start, y: y));

  for (int x = start; x <= end; x++) {
    final currenttile = floor.walls.grid[x][y];
    switch (currenttile) {
      case TileType.blank_tile:
        if (x == start && torchstart == 0) torchstart = x;
        floor.walls.grid[x][y - half - 3] = hallTopWallTop[1];
        floor.walls.grid[x][y - half - 2] = hallTopWallMid[1];
        floor.walls.grid[x][y - half - 1] = hallTopWallBottom[1];
        floor.floortiles.grid[x][y - half - 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
        for (int w = -half; w <= half; w++) {
          floor.walls.grid[x][y + w] = null;
          floor.floortiles.grid[x][y + w] = floor_tiles[rng.nextInt(floor_tiles.length)];
        }
        floor.walls.grid[x][y + half + 1] = hallBottomWall[1];
        break;
      case TileType.room_rightWall:
        torchstart = x - start;
        if (roomTopWallMid.contains(floor.walls.grid[x][y - half - 3])) {
          //place top corner piece with wall
          floor.walls.grid[x][y - half - 3] = TileType.hall_topWallTopLeft_fullwall;
        } else if (roomTopWallBottom.contains(floor.walls.grid[x][y - half - 3])) {
          //place corner piece with wall
          floor.walls.grid[x][y - half - 3] = TileType.hall_topWallTopLeft_cornerwall;
        } else {
          floor.walls.grid[x][y - half - 3] = hallTopWallTop[0];
        }

        if (roomTopWallMid.contains(floor.walls.grid[x][y - half - 2])) {
          //place top corner piece with wall
          floor.walls.grid[x][y - half - 2] = TileType.hall_topWallTopLeft_cornerwall;
        } else if (roomTopWallBottom.contains(floor.walls.grid[x][y - half - 2])) {
          //place corner piece with wall
          floor.walls.grid[x][y - half - 2] = TileType.hall_topWallMidLeft_cornerwall;
        } else {
          floor.walls.grid[x][y - half - 2] = hallTopWallMid[0];
        }

        floor.walls.grid[x][y - half - 1] = hallTopWallBottom[0];
        floor.floortiles.grid[x][y - half - 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
        for (int w = -half; w <= half; w++) {
          floor.walls.grid[x][y + w] = null;
          floor.floortiles.grid[x][y + w] = floor_tiles[rng.nextInt(floor_tiles.length)];
        }
        floor.walls.grid[x][y + half + 1] = hallBottomWall[0];
        break;
      case TileType.room_leftWall:
        torchstart = 0;
        if (roomTopWallMid.contains(floor.walls.grid[x][y - half - 3])) {
          //place top corner piece with wall
          floor.walls.grid[x][y - half - 3] = TileType.hall_topWallTopRight_fullwall;
        } else if (roomTopWallBottom.contains(floor.walls.grid[x][y - half - 3])) {
          //place corner piece with wall
          floor.walls.grid[x][y - half - 3] = TileType.hall_topWallTopRight_cornerwall;
        } else {
          floor.walls.grid[x][y - half - 3] = hallTopWallTop[2];
        }

        if (roomTopWallMid.contains(floor.walls.grid[x][y - half - 2])) {
          //place top corner piece with wall
          floor.walls.grid[x][y - half - 2] = TileType.hall_topWallTopRight_cornerwall;
        } else if (roomTopWallBottom.contains(floor.walls.grid[x][y - half - 2])) {
          //place corner piece with wall
          floor.walls.grid[x][y - half - 2] = TileType.hall_topWallMidRight_cornerwall;
        } else {
          floor.walls.grid[x][y - half - 2] = hallTopWallMid[2];
        }

        floor.walls.grid[x][y - half - 1] = hallTopWallBottom[2];
        for (int w = -half; w <= half; w++) {
          floor.walls.grid[x][y + w] = null;
          floor.floortiles.grid[x][y + w] = floor_tiles[rng.nextInt(floor_tiles.length)];
        }
        floor.walls.grid[x][y + half + 1] = hallBottomWall[2];
        break;
      default:
        break;
    }
    if (((x - start - torchstart) == 0 || (x - start - torchstart) % torchspacing == 0) && torchstart != 0) {
      floor.decorations.grid[x][y + (torchside ? -3 : 0)] = Props.torch;
      torchside = !torchside;
    }
  }
}

void placeVerticalHallway(
  Floor floor,
  int y1,
  int y2,
  int x,
  int width,
) {
  final start = min(y1, y2);
  final end = max(y1, y2);

  final half = width ~/ 2;

  const int torchspacing = 6;
  bool torchside = rng.nextBool();
  int torchstart = 0;

  floor.corridors.add(Corridor(height: end - start, width: 5, x: x, y: start));

  for (int y = start; y <= end; y++) {
    final currenttile = floor.walls.grid[x][y];
    switch (currenttile) {
      case TileType.blank_tile:
        if (y == start && torchstart == 0) torchstart = y;
        floor.walls.grid[x - half - 1][y] = TileType.room_leftWall;
        floor.floortiles.grid[x - half - 1][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        for (int w = -half; w <= half; w++) {
          floor.walls.grid[x + w][y] = null;
          floor.floortiles.grid[x + w][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        }
        floor.floortiles.grid[x + half + 1][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        floor.walls.grid[x + half + 1][y] = TileType.room_rightWall;
        break;
      case TileType.room_bottomWallMid:
        torchstart = y - start;
        floor.walls.grid[x - half - 1][y] = hallBottomWall[2];
        for (int w = -half; w <= half; w++) {
          floor.walls.grid[x + w][y] = null;
          floor.floortiles.grid[x + w][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        }
        floor.floortiles.grid[x + half + 1][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        floor.walls.grid[x + half + 1][y] = hallBottomWall[0];
        break;
      case TileType val when roomTopWallTop.contains(val):
        torchstart = 0;
        floor.walls.grid[x - half - 1][y] = hallTopWallTop[2];
        floor.floortiles.grid[x - half - 1][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        for (int w = -half; w <= half; w++) {
          floor.walls.grid[x + w][y] = null;
          floor.floortiles.grid[x + w][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        }
        floor.floortiles.grid[x + half + 1][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        floor.walls.grid[x + half + 1][y] = hallTopWallTop[0];
        break;
      case TileType val when roomTopWallMid.contains(val):
        floor.walls.grid[x - half - 1][y] = hallTopWallMid[2];
        floor.floortiles.grid[x - half - 1][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        for (int w = -half; w <= half; w++) {
          floor.walls.grid[x + w][y] = null;
          floor.floortiles.grid[x + w][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        }
        floor.floortiles.grid[x + half + 1][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        floor.walls.grid[x + half + 1][y] = hallTopWallMid[0];
        break;
      case TileType val when roomTopWallBottom.contains(val):
        floor.walls.grid[x - half - 1][y] = hallTopWallBottom[2];
        for (int w = -half; w <= half; w++) {
          floor.walls.grid[x + w][y] = null;
          floor.floortiles.grid[x + w][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        }
        floor.floortiles.grid[x + half + 1][y] = floor_tiles[rng.nextInt(floor_tiles.length)];
        floor.walls.grid[x + half + 1][y] = hallTopWallBottom[0];
        break;
      default:
        break;
    }
    if (((y - start - torchstart) == 0 || (y - start - torchstart) % torchspacing == 0) && torchstart != 0) {
      floor.decorations.grid[x + (torchside ? 0 : -1)][y] = Props.torch;
      torchside = !torchside;
    }
  }
}

void placeHallwayCorner(Floor floor, int x, int y) {
  if (floor.walls.grid[x][y - 1] == TileType.blank_tile && floor.walls.grid[x - 1][y] == null) {
    //corner turning from left to down, place top right corner of a room above x,y
    floor.decorations.grid[x][y - 3] = Props.cornertorch;
    floor.walls.grid[x - 1][y - 3] = TileType.room_topWallTopMid;
    floor.walls.grid[x - 1][y - 2] = TileType.room_topWallMidMid;
    floor.walls.grid[x - 1][y - 1] = TileType.room_topWallBottomMid;
    floor.floortiles.grid[x - 1][y - 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
    floor.walls.grid[x][y - 3] = TileType.room_topWallTopMid;
    floor.walls.grid[x][y - 2] = TileType.room_topWallMidMid;
    floor.walls.grid[x][y - 1] = TileType.room_topWallBottomMid;
    floor.floortiles.grid[x][y - 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
    floor.walls.grid[x + 1][y - 3] = TileType.room_topWallTopRight;
    floor.walls.grid[x + 1][y - 2] = TileType.room_topWallMidRight;
    floor.walls.grid[x + 1][y - 1] = TileType.room_topWallBottomRight;
    floor.floortiles.grid[x + 1][y - 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
    return;
  }
  if (floor.walls.grid[x][y - 1] == TileType.blank_tile && floor.walls.grid[x + 1][y] == null) {
    //corner turning from right to down, place top left corner of a room above x,y
    //????borked???? didnt get placed
    floor.decorations.grid[x][y - 3] = Props.cornertorch;
    floor.walls.grid[x + 1][y - 3] = TileType.room_topWallTopMid;
    floor.walls.grid[x + 1][y - 2] = TileType.room_topWallMidMid;
    floor.walls.grid[x + 1][y - 1] = TileType.room_topWallBottomMid;
    floor.floortiles.grid[x + 1][y - 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
    floor.walls.grid[x][y - 3] = TileType.room_topWallTopMid;
    floor.walls.grid[x][y - 2] = TileType.room_topWallMidMid;
    floor.walls.grid[x][y - 1] = TileType.room_topWallBottomMid;
    floor.floortiles.grid[x][y - 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
    floor.walls.grid[x - 1][y - 3] = TileType.room_topWallTopLeft;
    floor.walls.grid[x - 1][y - 2] = TileType.room_topWallMidLeft;
    floor.walls.grid[x - 1][y - 1] = TileType.room_topWallBottomLeft;
    floor.floortiles.grid[x - 1][y - 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
    return;
  }
  if (floor.walls.grid[x][y + 1] == TileType.blank_tile && floor.walls.grid[x - 1][y] == null) {
    //corner turning from left to up, place top right corner of a room above x,y
    floor.decorations.grid[x - 2][y - 3] = Props.cornertorch;
    floor.walls.grid[x - 1][y + 1] = TileType.room_bottomWallMid;
    floor.walls.grid[x][y + 1] = TileType.room_bottomWallMid;
    floor.floortiles.grid[x][y + 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
    floor.walls.grid[x + 1][y + 1] = TileType.room_bottomWallRight;
    return;
  }
  if (floor.walls.grid[x][y + 1] == TileType.blank_tile && floor.walls.grid[x + 1][y] == null) {
    //corner turning from right to up, place top right corner of a room above x,y
    floor.decorations.grid[x + 1][y - 3] = Props.cornertorch;
    floor.walls.grid[x + 1][y + 1] = TileType.room_bottomWallMid;
    floor.walls.grid[x][y + 1] = TileType.room_bottomWallMid;
    floor.floortiles.grid[x][y + 1] = floor_tiles[rng.nextInt(floor_tiles.length)];
    floor.walls.grid[x - 1][y + 1] = TileType.room_bottomWallLeft;
  }
}

Set<int> findconnections(List<Room> rooms, int start) {
  final visited = <int>{};
  final stack = <int>[start];

  while (stack.isNotEmpty) {
    final current = stack.removeLast();
    if (visited.contains(current)) continue;

    visited.add(current);

    for (final neighbor in rooms[current].connections!) {
      if (!visited.contains(neighbor)) stack.add(neighbor);
    }
  }

  return visited;
}

List<Set<int>> findAllGroups(List<Room> rooms) {
  final visited = <int>{};
  final groups = <Set<int>>[];

  for (int i = 0; i < rooms.length; i++) {
    if (visited.contains(i)) continue;

    final group = findconnections(rooms, i);

    groups.add(group);
    visited.addAll(group);
  }

  return groups;
}

GroupConnection? findClosestGroup(
  List<Room> rooms,
  List<Set<int>> groups,
  List<GroupConnection> failedconnections,
) {
  GroupConnection? best;

  for (int g = 0; g < groups.length; g++) {
    for (int ng = g + 1; ng < groups.length; ng++) {
      for (final r in groups[g]) {
        for (final nr in groups[ng]) {
          final a = rooms[r];
          final b = rooms[nr];

          final dx = a.centerX - b.centerX;
          final dy = a.centerY - b.centerY;
          final dist = dx * dx + dy * dy;

          if (best == null || dist < best.distance) {
            final currentconnection = GroupConnection(r, nr, dist);
            if (!failedconnections.contains(currentconnection)) best = GroupConnection(r, nr, dist);
          }
        }
      }
    }
  }
  return best;
}

bool connectRooms(Floor floor, List<Room> rooms, Room roomA, Room roomB, int corridorwidth) {
  if (checkXRangesOverlap(roomA, roomB)) {
    final aMin = roomA.x + 3;
    final aMax = roomA.x + roomA.width - 3;
    final bMin = roomB.x + 3;
    final bMax = roomB.x + roomB.width - 3;
    int overlapMin = max(aMin, bMin);
    int overlapMax = min(aMax, bMax);
    if (overlapMin < overlapMax) {
      int corridorx = rng.nextInt(overlapMax - overlapMin + 1) + overlapMin;
      if (canPlaceVerticalHallway(
        floor,
        roomA.centerY,
        roomB.centerY,
        corridorx,
        corridorwidth,
        roomA,
        roomB,
      )) {
        placeVerticalHallway(
          floor,
          roomB.centerY,
          roomA.centerY,
          corridorx,
          corridorwidth,
        );
        return true;
      }
    }
  }

  if (checkYRangesOverlap(roomA, roomB)) {
    final aMin = roomA.y + 4;
    final aMax = roomA.y + roomA.height - 3;
    final bMin = roomB.y + 4;
    final bMax = roomB.y + roomB.height - 3;
    int overlapMin = max(aMin, bMin);
    int overlapMax = min(aMax, bMax);
    if (overlapMin < overlapMax) {
      int corridory = rng.nextInt(overlapMax - overlapMin + 1) + overlapMin;
      if (canPlaceHorizontalHallway(
        floor,
        roomA.centerX,
        roomB.centerX,
        corridory,
        corridorwidth,
        roomA,
        roomB,
      )) {
        placeHorizontalHallway(
          floor,
          roomA.centerX,
          roomB.centerX,
          corridory,
          corridorwidth,
        );
        return true;
      }
    }
  }

  if (canPlaceHorizontalHallway(floor, roomA.centerX, roomB.centerX, roomA.centerY, 1, roomA, roomA) &&
      canPlaceVerticalHallway(floor, roomA.centerY, roomB.centerY, roomB.centerX, 1, roomB, roomB)) {
    placeVerticalHallway(floor, roomA.centerY, roomB.centerY, roomB.centerX, 1);
    placeHorizontalHallway(floor, roomA.centerX, roomB.centerX, roomA.centerY, 1);
    placeHallwayCorner(floor, roomB.centerX, roomA.centerY);
    roomA.connections!.add(rooms.indexOf(roomB));
    roomB.connections!.add(rooms.indexOf(roomA));
    return true;
  } else if (canPlaceVerticalHallway(floor, roomA.centerY, roomB.centerY, roomA.centerX, 1, roomA, roomA) &&
      canPlaceHorizontalHallway(floor, roomA.centerX, roomB.centerX, roomB.centerY, 1, roomB, roomB)) {
    placeVerticalHallway(floor, roomA.centerY, roomB.centerY, roomA.centerX, 1);
    placeHorizontalHallway(floor, roomA.centerX, roomB.centerX, roomB.centerY, 1);
    placeHallwayCorner(floor, roomA.centerX, roomB.centerY);
    roomA.connections!.add(rooms.indexOf(roomB));
    roomB.connections!.add(rooms.indexOf(roomA));
    return true;
  }
  return false;
}

bool canPlaceProp(Floor floor, int rx, int ry, Props prop) {
  if (rx + prop.width >= floor.width || ry + prop.height >= floor.height) return false;

  for (int dy = 0; dy < prop.height; dy++) {
    for (int dx = 0; dx < prop.width; dx++) {
      if (floor.decorations.grid[dx + rx][dy + ry] != null ||
          floor.decorations.grid[dx + rx][dy + ry] == Props.alpha_tile ||
          floor.walls.grid[dx + rx][dy + ry] != null) {
        return false;
      }
    }
  }

  // for (int dy = ry - 5; dy < ry; dy++) {
  //   for (int dx = rx - 5; dx < rx; dx++) {
  //     if (dx < 0 || dy < 0) continue;
  //     if (floor.decorations.grid[dx][dy] != null) {
  //       final foundprop = floor.decorations.grid[dx][dy];
  //       bool overlapX = (dx + foundprop!.width > rx);
  //       bool overlapY = (dy + foundprop!.height > ry);
  //       if (overlapX && overlapY) return false;
  //     }
  //   }
  // }
  return true;
}

void placeProps(Floor floor) {
  for (var room in floor.rooms) {
    if (floor.rooms.indexOf(room) == 0) continue;
    switch (rng.nextInt(6)) {
      case 0:
        roomlayout_centerpiece(floor, room);
        break;
      case 1:
        roomlayout_corners(floor, room);
        break;
      case 2:
        roomlayout_topwallline(floor, room);
        break;
      default:
        break;
    }
    int totalprops = rng.nextInt(3);

    int count = 0;
    int tries = 0;

    final int propcategory = rng.nextInt(all_props.length);
    final int proptype = rng.nextInt(all_props[propcategory].length);

    while (count < totalprops && tries < 5) {
      tries++;
      final Props prop = all_props[propcategory][proptype][rng.nextInt(all_props[propcategory][proptype].length)];
      int rx = room.x + 2 + rng.nextInt(room.width - prop.width - 3);
      int maxy = room.height - prop.height - 5;
      if (maxy < 1) continue;

      int ry = room.y + 4 + rng.nextInt(maxy);

      if (canPlaceProp(floor, rx, ry, prop)) {
        for (int dy = 0; dy < prop.height; dy++) {
          for (int dx = 0; dx < prop.width; dx++) {
            floor.decorations.grid[rx + dx][ry + dy] = Props.alpha_tile;
          }
        }
        floor.decorations.grid[rx][ry] = prop;
        count++;
      }
    }
  }
}

class FloorTileLayer {
  final int width;
  final int height;
  final List<List<TileType?>> grid;

  FloorTileLayer({required this.width, required this.height, required this.grid});

  factory FloorTileLayer.fillLayer(TileType? type, int floorwidth, int floorheight) {
    return FloorTileLayer(
      width: floorwidth,
      height: floorheight,
      grid: List.generate(
        floorwidth,
        (_) => List.generate(
          floorheight,
          (_) => type == TileType.floor_tile1 ? floor_tiles[rng.nextInt(floor_tiles.length)] : type,
        ),
      ),
    );
  }
}

class DecorationTileLayer {
  final int width;
  final int height;
  final List<List<Props?>> grid;

  DecorationTileLayer({required this.width, required this.height, required this.grid});

  factory DecorationTileLayer.fillLayer(Props? type, int floorwidth, int floorheight) {
    return DecorationTileLayer(
      width: floorwidth,
      height: floorheight,
      grid: List.generate(
        floorwidth,
        (_) => List.generate(
          floorheight,
          (_) => type,
        ),
      ),
    );
  }
}

class Room {
  final int x;
  final int y;
  final int width;
  final int height;
  final List<int>? connections;
  const Room({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.connections,
  });

  int get centerX => x + width ~/ 2;
  int get centerY => y + height ~/ 2;

  Rectangle<int> asRect() {
    return Rectangle<int>(x * 16, y * 16, width * 16, height * 16);
  }

  bool intersects(Room other) {
    return (x < other.x + other.width && x + width > other.x && y < other.y + other.height && y + height > other.y);
  }

  bool belongsToRoom(int cx, int cy) {
    return (cx >= x && cx < x + width && cy >= y && cy < y + height);
  }
}

class GroupConnection {
  final int roomA;
  final int roomB;
  final int distance;

  GroupConnection(this.roomA, this.roomB, this.distance);

  @override
  bool operator ==(Object other) =>
      other is GroupConnection && ((roomA == other.roomA && roomB == other.roomB) || (roomA == other.roomB && roomB == other.roomA));

  @override
  int get hashCode => roomA.hashCode ^ roomB.hashCode;
}

void roomlayout_centerpiece(Floor floor, Room room) {
  int totalprops;
  final int propcategory = rng.nextInt(all_props.length);
  final int proptype = rng.nextInt(all_props[propcategory].length);

  if (all_props[propcategory][proptype][0].name.contains('vertical')) {
    if (room.width < 7) {
      totalprops = 1;
    } else {
      totalprops = 2;
    }
  } else {
    if (room.height < 7) {
      totalprops = 1;
    } else {
      totalprops = 2;
    }
  }

  for (int propcount = 0; propcount < totalprops; propcount++) {
    final Props prop = all_props[propcategory][proptype][rng.nextInt(all_props[propcategory][proptype].length)];
    int rx;
    int ry;
    if (prop.name.contains('vertical')) {
      ry = room.centerY - (prop.height ~/ 2);
      if (totalprops == 2) {
        if (propcount == 0) {
          rx = room.centerX - prop.width;
        } else {
          rx = room.centerX + 1;
        }
      } else {
        rx = room.centerX - (prop.width ~/ 2);
      }
    } else {
      //horizontal
      rx = room.centerX - (prop.width ~/ 2);
      if (totalprops == 2) {
        if (propcount == 0) {
          ry = room.centerY - prop.height;
        } else {
          ry = room.centerY + 1;
        }
      } else {
        ry = room.centerY - (prop.height ~/ 2);
      }
    }

    if (canPlaceProp(floor, rx, ry, prop)) {
      for (int dy = 0; dy < prop.height; dy++) {
        for (int dx = 0; dx < prop.width; dx++) {
          floor.decorations.grid[rx + dx][ry + dy] = Props.alpha_tile;
        }
      }
      floor.decorations.grid[rx][ry] = prop;
    }
  }
}

void roomlayout_corners(Floor floor, Room room) {
  final int propcategory = rng.nextInt(all_props.length);
  final int proptype = rng.nextInt(all_props[propcategory].length);

  Props prop;
  int x;
  int y;
  prop = all_props[propcategory][proptype][rng.nextInt(all_props[propcategory][proptype].length)];
  x = room.x + 2;
  y = room.y + 3;
  if (canPlaceProp(floor, x, y, prop)) {
    for (int dy = 0; dy < prop.height; dy++) {
      for (int dx = 0; dx < prop.width; dx++) {
        floor.decorations.grid[x + dx][y + dy] = Props.alpha_tile;
      }
    }
    floor.decorations.grid[x][y] = prop;
  }

  prop = all_props[propcategory][proptype][rng.nextInt(all_props[propcategory][proptype].length)];
  x = room.x + room.width - 2 - prop.width;
  if (canPlaceProp(floor, x, y, prop)) {
    for (int dy = 0; dy < prop.height; dy++) {
      for (int dx = 0; dx < prop.width; dx++) {
        floor.decorations.grid[x + dx][y + dy] = Props.alpha_tile;
      }
    }
    floor.decorations.grid[x][y] = prop;
  }

  prop = all_props[propcategory][proptype][rng.nextInt(all_props[propcategory][proptype].length)];
  x = room.x + 2;
  y = room.y + room.height - 2 - prop.height;
  if (canPlaceProp(floor, x, y, prop)) {
    for (int dy = 0; dy < prop.height; dy++) {
      for (int dx = 0; dx < prop.width; dx++) {
        floor.decorations.grid[x + dx][y + dy] = Props.alpha_tile;
      }
    }
    floor.decorations.grid[x][y] = prop;
  }

  prop = all_props[propcategory][proptype][rng.nextInt(all_props[propcategory][proptype].length)];
  x = room.x + room.width - 2 - prop.width;
  y = room.y + room.height - 2 - prop.height;
  if (canPlaceProp(floor, x, y, prop)) {
    for (int dy = 0; dy < prop.height; dy++) {
      for (int dx = 0; dx < prop.width; dx++) {
        floor.decorations.grid[x + dx][y + dy] = Props.alpha_tile;
      }
    }
    floor.decorations.grid[x][y] = prop;
  }
}

void roomlayout_topwallline(Floor floor, Room room) {
  final int propcategory = rng.nextInt(all_props.length);
  final int proptype = rng.nextInt(all_props[propcategory].length);

  int startx = room.x + 2;
  int starty = room.y + 3;

  while (startx < room.x + room.width - 3) {
    final Props prop = all_props[propcategory][proptype][rng.nextInt(all_props[propcategory][proptype].length)];
    if (!rng.nextBool()) {
      startx += prop.width;
      continue;
    }
    if (canPlaceProp(floor, startx, starty, prop)) {
      for (int dy = 0; dy < prop.height; dy++) {
        for (int dx = 0; dx < prop.width; dx++) {
          floor.decorations.grid[startx + dx][starty + dy] = Props.alpha_tile;
        }
      }
      floor.decorations.grid[startx][starty] = prop;
      startx += prop.width;
    }
  }
}

class Corridor {
  final int x;
  final int y;
  final int width;
  final int height;

  const Corridor({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
