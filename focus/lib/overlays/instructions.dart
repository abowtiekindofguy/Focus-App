import 'package:flutter/material.dart';
// import 'p/chuck_jump.dart';

import '../chuck_jump.dart';

class Instructions extends StatelessWidget {
  // Reference to parent game.
  final ChuckJumpGame game;
  const Instructions({super.key, required this.game});

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
          width: 700,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius:  BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const Text(
                'Use the left, and right arrow buttons to move Chuck. Use the up arrow button to jump. Collect stars to increase your score. Avoid the logo enemies and the notifications that they shoot! Do not fall down! Your initial health is proportional to your focus score (minimum 5, maximum 15). On respawning, you get 5 hearts. Choose your theme in the Main Menu and press \'Play\' to start the game.',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(
                width: 200,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('Instructions');
                    game.overlays.add('MainMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Main Menu',
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