
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'overlays/main_menu.dart';
import 'overlays/game_over.dart';
import 'chuck_jump.dart'; 
import 'package:flutter/services.dart';// Make sure this is the correct path to your game logic

class GameScreen extends StatelessWidget {
  //on back button press

  // @override
  // void initState() {
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitDown,
  //     DeviceOrientation.portraitUp,
  //   ]);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: GameWidget<ChuckJumpGame>.controlled(
          gameFactory: ChuckJumpGame.new,
          overlayBuilderMap: {
            'MainMenu': (_, game) => MainMenu(game: game),
            'GameOver': (_, game) => GameOver(game: game),
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    );
  }
}