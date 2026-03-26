import 'dart:math';

enum TileType {
  room_topWallTopLeft(0, 3),
  room_topWallTopMid(0, 4),
  room_topWallTopRight(0, 5),
  room_topWallMidLeft(1, 3),
  room_topWallMidMid(1, 4),
  room_topWallMidRight(1, 5),
  room_topWallBottomLeft(2, 3),
  room_topWallBottomMid(2, 4),
  room_topWallBottomRight(2, 5),
  room_leftWall(1, 2),
  room_rightWall(1, 0),
  room_bottomWallLeft(3, 3),
  room_bottomWallMid(3, 4),
  room_bottomWallRight(3, 5),
  hall_topWallTopLeft_shadow(2, 0),
  hall_topWallTopLeft_fullwall(0, 6),
  hall_topWallTopLeft_cornerwall(2, 6),
  hall_topWallTopMid(2, 1),
  hall_topWallTopRight_shadow(2, 2),
  hall_topWallTopRight_fullwall(0, 7),
  hall_topWallTopRight_cornerwall(2, 7),
  hall_topWallMidLeft_shadow(3, 0),
  hall_topWallMidLeft_cornerwall(1, 6),
  hall_topWallMidMid(3, 1),
  hall_topWallMidRight_shadow(3, 2),
  hall_topWallMidRight_cornerwall(1, 7),
  hall_topWallBottomLeft(4, 0),
  hall_topWallBottomMid(4, 1),
  hall_topWallBottomRight(4, 2),
  hall_bottomWallLeft(0, 0),
  hall_bottomWallMid(0, 1),
  hall_bottomWallRight(0, 2),

  blank_tile(1, 1),
  floor_tile1(4, 3),
  floor_tile2(4, 4),
  floor_tile3(4, 5),
  floor_tile4(4, 6),
  floor_tile5(4, 7),
  floor_tile6(4, 8),
  floor_tile7(4, 9),
  floor_tile8(4, 10),
  ;

  final int tilerow;
  final int tilecol;

  const TileType(this.tilerow, this.tilecol);
}

const floorwidth = 70;
const floorheight = 70;

const floor_tiles = [
  TileType.floor_tile1,
  TileType.floor_tile2,
  TileType.floor_tile3,
  TileType.floor_tile4,
  TileType.floor_tile5,
  TileType.floor_tile6,
  TileType.floor_tile7,
  TileType.floor_tile8,
];

const nocollisions = [
  TileType.room_topWallTopLeft,
  TileType.room_topWallTopMid,
  TileType.room_topWallTopRight,
  TileType.room_topWallMidLeft,
  TileType.room_topWallMidMid,
  TileType.room_topWallMidRight,
  TileType.hall_topWallTopMid,
  TileType.hall_topWallMidMid,
  TileType.room_topWallBottomLeft,
  TileType.room_topWallBottomRight,
  TileType.room_bottomWallLeft,
  TileType.room_bottomWallRight,
];

const topwalls = [
  // TileType.room_topWallTopLeft,
  TileType.room_topWallTopMid,
  // TileType.room_topWallTopRight,
  // TileType.room_topWallMidLeft,
  TileType.room_topWallMidMid,
  // TileType.room_topWallMidRight,
  // TileType.room_topWallBottomLeft,
  TileType.room_topWallBottomMid,
  // TileType.room_topWallBottomRight,
  TileType.hall_topWallTopLeft_shadow,
  TileType.hall_topWallTopMid,
  TileType.hall_topWallTopRight_shadow,
  TileType.hall_topWallMidLeft_shadow,
  TileType.hall_topWallMidMid,
  TileType.hall_topWallMidRight_shadow,
  TileType.hall_topWallBottomLeft,
  TileType.hall_topWallBottomMid,
  TileType.hall_topWallBottomRight,
];

const roomTopWallTop = [
  TileType.room_topWallTopLeft,
  TileType.room_topWallTopMid,
  TileType.room_topWallTopRight,
];
const roomTopWallMid = [
  TileType.room_topWallMidLeft,
  TileType.room_topWallMidMid,
  TileType.room_topWallMidRight,
];
const roomTopWallBottom = [
  TileType.room_topWallBottomLeft,
  TileType.room_topWallBottomMid,
  TileType.room_topWallBottomRight,
];

const roomBottomWall = [
  TileType.room_bottomWallLeft,
  TileType.room_bottomWallMid,
  TileType.room_bottomWallRight,
];

const roomWalls = [
  ...roomTopWallTop,
  ...roomTopWallMid,
  ...roomTopWallBottom,
  ...roomBottomWall,
];

const hallTopWallTop = [
  TileType.hall_topWallTopLeft_shadow,
  TileType.hall_topWallTopMid,
  TileType.hall_topWallTopRight_shadow,
];

const hallTopWallMid = [
  TileType.hall_topWallMidLeft_shadow,
  TileType.hall_topWallMidMid,
  TileType.hall_topWallMidRight_shadow,
];

const hallTopWallBottom = [
  TileType.hall_topWallBottomLeft,
  TileType.hall_topWallBottomMid,
  TileType.hall_topWallBottomRight,
];

const hallBottomWall = [
  TileType.hall_bottomWallLeft,
  TileType.hall_bottomWallMid,
  TileType.hall_bottomWallRight,
];

const hallWalls = [
  ...hallTopWallTop,
  ...hallTopWallMid,
  ...hallTopWallBottom,
  ...hallBottomWall,
];

extension TileTypeFromCoord on TileType {
  static TileType fromCoord(int x, int y) {
    return TileType.values.firstWhere(
      (element) => element.tilerow == x && element.tilecol == y,
      orElse: () => TileType.blank_tile,
    );
  }
}

final rng = Random();
