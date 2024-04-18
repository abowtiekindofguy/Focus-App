import 'package:flutter/material.dart';
// import 'p/chuck_jump.dart';

import '../chuck_jump.dart';

class GameOver extends StatelessWidget {
  // Reference to parent game.
  final ChuckJumpGame game;
  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Color.fromRGBO(34, 1, 66, 1),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 300,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              (game.starsCollected == game.score_to_achieve) ? const Text(
                'Congratulations, You Won! Try the higher levels',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 20,
                ),
              ) : const Text(
                'You Lost! Better Luck Next Time.',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.startGame = false;
                    game.reset(false);
                    game.overlays.remove('GameOver');
                    game.overlays.add('MainMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}