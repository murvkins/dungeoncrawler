import 'package:dungeoncrawler/bloc/dungeon_bloc/dungeon_bloc.dart';
import 'package:dungeoncrawler/game/gamewindow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DungeonCrawlApp());
}

class DungeonCrawlApp extends StatelessWidget {
  const DungeonCrawlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DungeonBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Untitled Dungeon-Crawler Flutter/Flame',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.texturinaTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const GameWindow(),
      ),
    );
  }
}
