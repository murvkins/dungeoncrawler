import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameWindow extends StatefulWidget {
  const GameWindow({super.key});

  @override
  State<GameWindow> createState() => _GameWindowState();
}

class _GameWindowState extends State<GameWindow> {
  @override
  Widget build(BuildContext context) {
    final dungeonbloc = BlocProvider.of<DungeonBloc>(context);

    DungeonCrawl game = DungeonCrawl(dungeonBloc: dungeonbloc);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(
        game: game,
        autofocus: true,
        loadingBuilder: (p0) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

// class _GameWindowState extends State<GameWindow> {
//   bool isLoaded = false;
//   late SpriteSheet idleSpriteSheet;
//   late SpriteSheet walkSpriteSheet;
//   late SpriteSheet attackSpriteSheet;

//   @override
//   void initState() {
//     super.initState();
//     _setupGame();
//     context.read<DungeonBloc>().add(GenerateNewMap());
//   }

//   Future<void> _setupGame() async {
//     await loadTorchAnimations(Flame.images);
//     final idleimage = await Flame.images.load('Swordsman_lvl1_Idle_with_shadow.png');
//     final walkimage = await Flame.images.load('Swordsman_lvl1_Walk_with_shadow.png');
//     final attackimage = await Flame.images.load('Swordsman_lvl1_attack_with_shadow.png');

//     idleSpriteSheet = SpriteSheet(image: idleimage, srcSize: Vector2.all(64.0), spacing: 0);
//     walkSpriteSheet = SpriteSheet(image: walkimage, srcSize: Vector2.all(64.0), spacing: 0);
//     attackSpriteSheet = SpriteSheet(image: attackimage, srcSize: Vector2.all(64.0), spacing: 0);

//     setState(() {
//       isLoaded = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!isLoaded) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return BlocBuilder<DungeonBloc, DungeonState>(
//       builder: (context, state) {
//         if (state.dungeon.floors.isEmpty || state.dungeon.floors.last.rooms.isEmpty) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         final firstroom = state.dungeon.floors.last.rooms.first;

//         return BonfireWidget(
//           map: BonfireGenerateMap.fromState(state),
//           player: BonfirePlayer(
//             position: Vector2(
//               (firstroom.x + 1) * 16 - 8,
//               (firstroom.y + 2) * 16,
//             ),
//             idleSpriteSheet: idleSpriteSheet,
//             walkSpriteSheet: walkSpriteSheet,
//             attackSpriteSheet: attackSpriteSheet,
//           ),
//           lightingColorGame: Colors.black.withValues(alpha: 0.1),
//           backgroundColor: Colors.grey[900],
//           // debugMode: true,
//           cameraConfig: CameraConfig(zoom: 3.0, moveOnlyMapArea: true),
//           // playerControllers: [
//           //   Keyboard(
//           //     config: KeyboardConfig(
//           //       enable: true,
//           //       directionalKeys: [KeyboardDirectionalKeys.wasd()],
//           //     ),
//           //   ),
//           // ],
//           components: [
//             ...buildCollisionBlocks(state),
//             // ...buildDecorations(state),
//           ],
//         );
//       },
//     );
//   }
// }
