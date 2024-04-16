import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'breathe.dart';
import 'overlays/dropdown.dart';

// void main() {
//   final game = FlameGame();
//   runApp(
//     GameWidget<ChuckBreathe>.controlled(
//       gameFactory: ChuckBreathe.new,
//       overlayBuilderMap: {
//             'dropdown': (_, game) => DropdownOverlay(chuck_breathe: game),
//       },
//       initialActiveOverlays: const ['dropdown'],
//     )
//   );
// }
class BreatheGame extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: GameWidget<ChuckBreathe>.controlled(
      gameFactory: ChuckBreathe.new,
      overlayBuilderMap: {
            'dropdown': (_, game) => DropdownOverlay(chuck_breathe: game),
      },
      initialActiveOverlays: const ['dropdown'],
    ),
      ),
    );
  }
}