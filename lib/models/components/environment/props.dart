import 'dart:ui';

import 'package:dungeoncrawler/game/game.dart';
import 'package:dungeoncrawler/models/enums/priority.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum SheetType { cratesbarrels, coffins, torches }

enum Props {
  alpha_tile(SheetType.coffins, 16, 9, 1, 1, true),
  large_closed_vertical_sarcophagus(SheetType.coffins, 0, 0, 2, 4, true),
  large_open_empty_vertical_sarcophagus(SheetType.coffins, 3, 0, 2, 4, true),
  large_open_skeleton_vertical_sarcophagus(SheetType.coffins, 6, 0, 2, 4, true),
  small_closed_horizontal_sarcophagus(SheetType.coffins, 8, 0, 3, 2, true),
  small_open_empty_horizontal_sarcophagus(SheetType.coffins, 11, 0, 3, 2, true),
  small_open_skeleton_horizontal_sarcophagus(SheetType.coffins, 14, 0, 3, 2, true),
  small_open_skeleton_horizontal_sarcophagus_alt(SheetType.coffins, 17, 0, 3, 2, true),
  thin_open_skeleton_horizontal_sarcophagus(SheetType.coffins, 20, 0, 2, 2, true),
  thin_open_skeleton_horizontal_sarcophagus_alt(SheetType.coffins, 22, 0, 2, 2, true),
  medium_closed_horizontal_sarcophagus(SheetType.coffins, 8, 2, 3, 2, true),
  medium_open_empty_horizontal_sarcophagus(SheetType.coffins, 11, 2, 3, 2, true),
  medium_open_skeleton_horizontal_sarcophagus(SheetType.coffins, 14, 2, 3, 2, true),
  medium_open_skeleton_horizontal_sarcophagus_alt(SheetType.coffins, 17, 2, 3, 2, true),
  thin_closed_horizontal_sarcophagus(SheetType.coffins, 20, 2, 2, 2, true),
  thin_open_empty_horizontal_sarcophagus(SheetType.coffins, 22, 2, 2, 2, true),
  large_closed_horizontal_sarcophagus(SheetType.coffins, 0, 4, 3, 3, true),
  large_open_skeleton_horizontal_sarcophagus(SheetType.coffins, 4, 4, 3, 3, true),
  medium_closed_vertical_sarcophagus(SheetType.coffins, 8, 4, 2, 3, true),
  medium_open_empty_vertical_sarcophagus(SheetType.coffins, 10, 4, 2, 3, true),
  medium_open_skeleton_vertical_sarcophagus(SheetType.coffins, 12, 4, 2, 3, true),
  medium_open_skeleton_vertical_sarcophagus_alt(SheetType.coffins, 12, 4, 2, 3, true),
  large_closed_vertical_sarcophagus_alt(SheetType.coffins, 14, 4, 2, 3, true),
  large_open_empty_vertical_sarcophagus_alt(SheetType.coffins, 16, 4, 2, 3, true),
  large_open_skeleton_vertical_sarcophagus_alt(SheetType.coffins, 18, 4, 2, 3, true),
  large_open_skeleton_vertical_sarcophagus_alt2(SheetType.coffins, 20, 4, 2, 3, true),
  thin_open_skeleton_vertical_sarcophagus(SheetType.coffins, 0, 7, 2, 3, true),
  thin_open_empty_vertical_sarcophagus(SheetType.coffins, 2, 7, 2, 3, true),
  open_skeleton_vertical_coffin(SheetType.coffins, 4, 7, 2, 3, true),
  open_empty_vertical_coffin(SheetType.coffins, 6, 7, 2, 3, true),
  closed_vertical_coffin(SheetType.coffins, 8, 7, 2, 3, true),
  open_skeleton_vertical_coffin_alt(SheetType.coffins, 10, 7, 2, 3, true),
  open_skeleton_horizontal_coffin(SheetType.coffins, 12, 7, 2, 2, true),
  open_skeleton_horizontal_coffin_alt(SheetType.coffins, 14, 7, 2, 2, true),
  closed_horizontal_coffin(SheetType.coffins, 16, 7, 2, 2, true),
  open_empty_horizontal_coffin(SheetType.coffins, 18, 7, 2, 2, true),
  thin_open_skeleton_vertical_sarcophagus_alt(SheetType.coffins, 20, 7, 2, 3, true),
  thin_closed_vertical_sarcophagus(SheetType.coffins, 22, 7, 2, 3, true),

  stairs_down_no_border(SheetType.cratesbarrels, 0, 0, 1, 1, false),
  stair_down_with_border(SheetType.cratesbarrels, 0, 4, 2, 2, false),
  large_light_brown_crate(SheetType.cratesbarrels, 2, 4, 2, 2, true),
  small_light_brown_crate(SheetType.cratesbarrels, 4, 4, 1, 2, true),
  medium_light_brown_crate(SheetType.cratesbarrels, 5, 4, 1, 2, true),
  light_brown_barrel(SheetType.cratesbarrels, 6, 4, 1, 2, true),
  large_dark_brown_crate(SheetType.cratesbarrels, 7, 4, 2, 2, true),
  small_dark_brown_crate(SheetType.cratesbarrels, 9, 4, 2, 2, true),
  medium_dark_brown_crate(SheetType.cratesbarrels, 10, 4, 2, 2, true),
  dark_brown_barrel(SheetType.cratesbarrels, 11, 4, 1, 2, true),
  large_black_jar(SheetType.cratesbarrels, 12, 4, 1, 2, true),
  medium_black_jar(SheetType.cratesbarrels, 13, 4, 1, 2, true),
  small_black_jar(SheetType.cratesbarrels, 14, 4, 1, 2, true),
  large_brown_jar(SheetType.cratesbarrels, 15, 4, 1, 2, true),
  medium_brown_jar(SheetType.cratesbarrels, 16, 4, 1, 2, true),
  small_brown_jar(SheetType.cratesbarrels, 17, 4, 1, 2, true),
  barrel_and_crate(SheetType.cratesbarrels, 20, 4, 2, 2, false),
  four_jars(SheetType.cratesbarrels, 22, 0, 2, 2, true),
  three_jars(SheetType.cratesbarrels, 22, 2, 2, 2, true),
  two_big_crates(SheetType.cratesbarrels, 16, 0, 2, 2, true),
  three_crates_stacked(SheetType.cratesbarrels, 18, 0, 2, 3, true),
  all_items_pile(SheetType.cratesbarrels, 20, 2, 2, 2, true),
  torch(SheetType.torches, 0,0,0,0,false),
  cornertorch(SheetType.torches, 0,0,0,0,false),
  ;

  final SheetType sheettype;
  final int startx;
  final int starty;
  final int width;
  final int height;
  final bool top_row_is_traversible;

  const Props(this.sheettype, this.startx, this.starty, this.width, this.height, this.top_row_is_traversible);
}

const all_props = [all_cratebarrel_props, all_coffin_props];

const all_cratebarrel_props = [
  crates,
  barrels,
  jars,
];

const all_coffin_props = [vertical_sarcophagi, horizontal_sarcophagi, vertical_coffins, horizontal_coffins];

const vertical_sarcophagi = [
  Props.large_closed_vertical_sarcophagus,
  Props.large_open_empty_vertical_sarcophagus,
  Props.large_open_skeleton_vertical_sarcophagus,
  Props.medium_closed_vertical_sarcophagus,
  Props.medium_open_empty_vertical_sarcophagus,
  Props.medium_open_skeleton_vertical_sarcophagus,
  Props.medium_open_skeleton_vertical_sarcophagus_alt,
  Props.large_closed_vertical_sarcophagus_alt,
  Props.large_open_empty_vertical_sarcophagus_alt,
  Props.large_open_skeleton_vertical_sarcophagus_alt,
  Props.large_open_skeleton_vertical_sarcophagus_alt2,
  Props.thin_open_skeleton_vertical_sarcophagus,
  Props.thin_open_empty_vertical_sarcophagus,
  Props.thin_open_skeleton_vertical_sarcophagus_alt,
  Props.thin_closed_vertical_sarcophagus,
];

const horizontal_sarcophagi = [
  Props.small_closed_horizontal_sarcophagus,
  Props.small_open_empty_horizontal_sarcophagus,
  Props.small_open_skeleton_horizontal_sarcophagus,
  Props.small_open_skeleton_horizontal_sarcophagus_alt,
  Props.thin_open_skeleton_horizontal_sarcophagus,
  Props.thin_open_skeleton_horizontal_sarcophagus_alt,
  Props.medium_closed_horizontal_sarcophagus,
  Props.medium_open_empty_horizontal_sarcophagus,
  Props.medium_open_skeleton_horizontal_sarcophagus,
  Props.medium_open_skeleton_horizontal_sarcophagus_alt,
  Props.thin_closed_horizontal_sarcophagus,
  Props.thin_open_empty_horizontal_sarcophagus,
  Props.large_closed_horizontal_sarcophagus,
  Props.large_open_skeleton_horizontal_sarcophagus,
];

const vertical_coffins = [
  Props.open_skeleton_vertical_coffin,
  Props.open_empty_vertical_coffin,
  Props.closed_vertical_coffin,
  Props.open_skeleton_vertical_coffin_alt,
];

const horizontal_coffins = [
  Props.open_skeleton_horizontal_coffin,
  Props.open_skeleton_horizontal_coffin_alt,
  Props.closed_horizontal_coffin,
  Props.open_empty_horizontal_coffin,
];

const crates = [
  Props.large_light_brown_crate,
  Props.small_light_brown_crate,
  Props.medium_light_brown_crate,
  Props.large_dark_brown_crate,
  Props.small_dark_brown_crate,
  Props.medium_dark_brown_crate,
  Props.two_big_crates,
  Props.three_crates_stacked,
  Props.all_items_pile,
];

const barrels = [
  Props.light_brown_barrel,
  Props.dark_brown_barrel,
  Props.all_items_pile,
];

const jars = [
  Props.large_black_jar,
  Props.medium_black_jar,
  Props.small_black_jar,
  Props.large_brown_jar,
  Props.medium_brown_jar,
  Props.small_brown_jar,
  Props.four_jars,
  Props.three_jars,
  Props.all_items_pile,
];

extension TileTypeFromCoord on Props {
  static Props fromCoord(SheetType sheet, int x, int y) {
    return Props.values.firstWhere(
      (element) => element.sheettype == sheet && element.startx == x && element.starty == y,
      orElse: () => Props.alpha_tile,
    );
  }
}

class Prop extends SpriteComponent with HasGameReference<DungeonCrawl> {
  Prop({required Sprite sprite, required Vector2 position, required Vector2 size})
    : super(
        sprite: sprite,
        position: position,
        size: size,
        anchor: Anchor.topLeft,
        paint: Paint()..filterQuality = FilterQuality.none,
      );

  @override
  void onMount() {
    super.onMount();
    priority = (RenderPriority.props.value + position.y).toInt();
  }
}
