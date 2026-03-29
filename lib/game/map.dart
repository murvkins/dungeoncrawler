import 'dart:async';
import 'dart:ui' show FilterQuality;

import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/extensions.dart';
import 'package:dungeoncrawler/game/game.dart';
import 'package:dungeoncrawler/models/components/characters/enemies/enemy.dart';
import 'package:dungeoncrawler/models/components/characters/player/player.dart';
import 'package:dungeoncrawler/models/components/environment/darkness.dart';
import 'package:dungeoncrawler/models/components/environment/dungeon_floors.dart';
import 'package:dungeoncrawler/models/components/environment/floor_tiles.dart';
import 'package:dungeoncrawler/models/components/environment/lighting.dart';
import 'package:dungeoncrawler/models/components/turnmanager.dart';
import 'package:dungeoncrawler/models/enums/priority.dart';
import 'package:dungeoncrawler/models/components/environment/props.dart';
import 'package:dungeoncrawler/models/components/environment/torches.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' show Paint, Colors;
import 'package:flutter/services.dart';

class GenerateMap extends Component with HasGameReference<DungeonCrawl>, KeyboardHandler {
  GenerateMap({required this.dungeonBloc, this.onMapReady});

  final void Function(DungeonState state)? onMapReady;
  final DungeonBloc dungeonBloc;
  late final SpriteSheet floorWallSpriteSheet;
  late final SpriteSheet cratesBarrelsSpriteSheet;
  late final SpriteSheet coffinsSpriteSheet;
  StreamSubscription? _sub;
  bool _isBuilding = false;

  final Map<TorchType, SpriteAnimation> torchAnimations = {};
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  Future<void> loadTorchAnimations() async {
    final torchimage = await game.images.load('torches.png');
    final torchSpriteSheet = SpriteSheet(image: torchimage, srcSize: Vector2.all(48), spacing: 0);
    for (var type in TorchType.values) {
      final List<Vector2> frames = type.frames.map((e) => Vector2(e['x']!, e['y']!)).toList();
      torchAnimations[type] = SpriteAnimation.spriteList(
        frames.map((e) => torchSpriteSheet.getSprite(e.y.toInt(), e.x.toInt())).toList(),
        stepTime: 0.15,
        loop: true,
      );
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    game.images.prefix = 'assets/images/';
    final image = await game.images.load('walls_floor2.png');
    final cratesbarrelsimage = await game.images.load('Objects.png');
    final coffinsimage = await game.images.load('coffins.png');

    floorWallSpriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2.all(16),
      spacing: 0,
    );

    cratesBarrelsSpriteSheet = SpriteSheet(
      image: cratesbarrelsimage,
      srcSize: Vector2.all(16),
      spacing: 0,
    );

    coffinsSpriteSheet = SpriteSheet(
      image: coffinsimage,
      srcSize: Vector2.all(16),
      spacing: 0,
    );

    await loadTorchAnimations();

    _pressedKeys.clear();

    await _sub?.cancel();
    _sub = dungeonBloc.stream
        .distinct(
          (previous, next) => previous.dungeon == next.dungeon,
        )
        .listen(_onNewState);

    if (dungeonBloc.state.dungeon.floors.isEmpty) {
      dungeonBloc.add(GenerateNewMap());
    } else {
      _onNewState(dungeonBloc.state);
    }
  }

  void _onNewState(DungeonState state) {
    if (state.dungeon.floors.isEmpty || _isBuilding) return;

    final oldSprites = game.world.children
        .where((e) => e is ImageComposition || e is Torch || e is SpriteComponent || e is Prop || e is Enemy || e is DarknessLayer)
        .toList();
    game.world.removeAll(oldSprites);
    game.world.add(DarknessLayer()..priority = RenderPriority.darkness.value);
    buildMap(state);
    spawnEnemies(state);

    final player = game.world.children.whereType<Player>().firstOrNull;
    player?.pressedKeys.clear();

    Future.delayed(Duration.zero, () {
      game.world.children.whereType<TurnManager>().firstOrNull?.updateEnemyList();
    });
  }

  void buildMap(DungeonState state) async {
    if (state.dungeon.floors.isEmpty || _isBuilding) return;
    _isBuilding = true;

    try {
      final floortiles = state.dungeon.floors.last.floortiles;
      final walls = state.dungeon.floors.last.walls;
      final decorations = state.dungeon.floors.last.decorations;

      final floorComposition = ImageComposition();
      final upperWallsComposition = ImageComposition();
      final wallsComposition = ImageComposition();

      final mapSize = Vector2(floortiles.width * 16.0, floortiles.height * 16.0);

      final ghostRect = Rect.fromLTWH(0, 0, 1, 1);

      void anchorComposition(ImageComposition comp, Image spriteSheet) {
        comp.add(spriteSheet, Vector2.zero(), source: ghostRect);
        comp.add(spriteSheet, mapSize - Vector2.all(1), source: ghostRect);
      }

      anchorComposition(floorComposition, floorWallSpriteSheet.image);
      anchorComposition(upperWallsComposition, floorWallSpriteSheet.image);
      anchorComposition(wallsComposition, floorWallSpriteSheet.image);

      for (int y = 0; y < floortiles.height; y++) {
        for (int x = 0; x < floortiles.width; x++) {
          final tile = floortiles.grid[x][y];
          if (tile != null) {
            final sprite = floorWallSpriteSheet.getSprite(tile.tilerow, tile.tilecol);
            floorComposition.add(
              sprite.image,
              Vector2(x * 16.0, y * 16.0),
              source: sprite.src,
            );
          }
        }
      }

      for (int y = 0; y < walls.height; y++) {
        for (int x = 0; x < walls.width; x++) {
          final tile = walls.grid[x][y];
          if (tile != null) {
            final sprite = floorWallSpriteSheet.getSprite(tile.tilerow, tile.tilecol);
            if (topwalls.contains(tile)) {
              upperWallsComposition.add(
                sprite.image,
                Vector2(x * 16.0, y * 16.0),
                source: sprite.src,
              );
            } else {
              wallsComposition.add(
                sprite.image,
                Vector2(x * 16.0, y * 16.0),
                source: sprite.src,
              );
            }
          }
        }
      }

      final floorImage = await floorComposition.compose();
      final upperWallImage = await upperWallsComposition.compose();
      final wallImage = await wallsComposition.compose();

      game.world.add(
        SpriteComponent(
          sprite: Sprite(floorImage),
          size: mapSize,
          priority: -100,
          paint: Paint()..filterQuality = FilterQuality.none,
        ),
      );

      game.world.add(
        SpriteComponent(
          sprite: Sprite(upperWallImage),
          size: mapSize,
          priority: RenderPriority.upperwalls.value,
          paint: Paint()..filterQuality = FilterQuality.none,
        ),
      );

      game.world.add(
        SpriteComponent(
          sprite: Sprite(wallImage),
          size: mapSize,
          priority: RenderPriority.walls.value,
          paint: Paint()..filterQuality = FilterQuality.none,
        ),
      );

      for (int y = 0; y < decorations.height; y++) {
        for (int x = 0; x < decorations.width; x++) {
          final tile = decorations.grid[x][y];
          if (tile != null) {
            late SpriteSheet sheet;
            switch (tile.sheettype) {
              case SheetType.cratesbarrels:
                sheet = cratesBarrelsSpriteSheet;
                break;
              case SheetType.coffins:
                sheet = coffinsSpriteSheet;
                break;
              case SheetType.torches:
                if (rng.nextDoubleBetween(0, 100) > 20.0) {
                  if (tile == Props.cornertorch) {
                    addTorch(x, y, TorchType.values[rng.nextInt(2) + 1], (RenderPriority.torches.value + y - 50).toInt());
                  } else if (canPlaceTorch(state.dungeon.floors.last, decorations, x, y)) {
                    addTorch(x, y, TorchType.values[rng.nextInt(2) + 1], (RenderPriority.torches.value + y).toInt());
                  }
                }
                continue;
            }

            final prop = Prop(
              sprite: sheet.getSpriteGroup(tile.starty, tile.startx, tile.width, tile.height),
              position: Vector2(x * 16.0, y * 16.0),
              size: Vector2(tile.width * 16.0, tile.height * 16.0),
            );
            game.world.add(prop);
          }
        }
      }

      onMapReady?.call(state);
    } catch (e) {
      print('Error building map: $e');
    } finally {
      _isBuilding = false;
    }
  }

  void addTorch(int x, int y, TorchType type, int priority) {
    final animation = torchAnimations[type]!.clone();

    final ticker = animation.createTicker();
    ticker.update(rng.nextDouble());
    final pos = Vector2(x * 16.0 + 16, y * 16.0 + 24);

    game.world.add(
      Torch(
        animation: animation,
        position: pos,
        priority: priority,
        lightingConfig: LightingConfig(
          radius: 40,
          color: Colors.transparent,
          withPulse: true,
          pulseSpeed: rng.nextDoubleBetween(0.03, 0.1),
          pulseVariation: rng.nextDoubleBetween(0.07, 0.12),
          blurBorder: 25,
        ),
      ),
    );
    // game.world.add(TorchLight(position: pos));
  }

  bool canPlaceTorch(Floor floor, DecorationTileLayer decorations, int x, int y) {
    const int buffer = 2;
    for (int dy = y - buffer; dy < y + buffer; dy++) {
      for (int dx = x - buffer; dx < x + buffer; dx++) {
        if (dx > 0 && dy > 0 && dx < floor.width && dy < floor.height) {
          if (decorations.grid[dx][dy] == Props.cornertorch || topwalls.contains(floor.walls.grid[dx][dy])) return false;
        }
      }
    }
    return true;
  }

  void spawnEnemies(DungeonState state) {
    final floor = state.dungeon.floors.last;
    final List<Enemy> enemies = [];

    for (final room in floor.rooms) {
      if (floor.rooms.indexOf(room) == 0) continue;

      int roomArea = room.width * room.height;
      int maxEnemies = (roomArea / 20).floor().clamp(1, 5);

      for (int e = 0; e < maxEnemies; e++) {
        int spawnX = room.x + 1 + rng.nextInt(room.width - 2);
        int spawnY = room.y + 4 + rng.nextInt(room.height - 5);
        if (floor.walls.grid[spawnX][spawnY] == null && floor.decorations.grid[spawnX][spawnY] == null) {
          enemies.add(
            Enemy(
              renderedState: state,
              position: Vector2(
                spawnX * 16.0,
                spawnY * 16.0,
              ),
            ),
          );
        }
      }
    }
    floor.enemies = enemies;
    game.world.addAll(enemies);
  }

  @override
  void onRemove() {
    _sub?.cancel();
    super.onRemove();
  }
}
