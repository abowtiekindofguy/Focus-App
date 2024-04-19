import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'overlays/main_menu.dart';
import 'overlays/game_over.dart';
import 'overlays/instructions.dart';
import 'chuck_jump.dart'; 
import 'package:flutter/services.dart';// Make sure this is the correct path to your game logic


class GameScreen extends StatefulWidget {
  final init_health, fire_speed, gravity, score_to_achieve;
  GameScreen({this.init_health = 5, this.fire_speed = 1.5, this.gravity = 15, this.score_to_achieve = 20});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: GameWidget<ChuckJumpGame>.controlled(
          
          gameFactory: () => ChuckJumpGame(health: widget.init_health, fire_speed: widget.fire_speed, gravity:widget.gravity, score_to_achieve: widget.score_to_achieve),
          overlayBuilderMap: {
            'MainMenu': (_, game) => MainMenu(game: game),
            'GameOver': (_, game) => GameOver(game: game),
            'Instructions': (_, game) => Instructions(game: game),
          },
          initialActiveOverlays: const ['Instructions'],
        ),
      ),
    );
  }
}