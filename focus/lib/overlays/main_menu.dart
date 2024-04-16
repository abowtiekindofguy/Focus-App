import 'package:flutter/material.dart';
import 'package:focus/chuck_environment/ground_block.dart';

import '../chuck_jump.dart';

class MainMenu extends StatelessWidget {
  // Reference to parent game.
  final ChuckJumpGame game;
  
  MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuItem(
          'Ground Surf',
          blackTextColor,
          whiteTextColor,
          () {
            game.set_theme(0);
          },
          ),
          _buildMenuItem(
          'Tech Mania',
          blackTextColor,
          whiteTextColor,
          () {
            game.set_theme(1);
          },
          ),
          _buildMenuItem(
          'Cosmo Leap',
          blackTextColor,
          whiteTextColor,
          () {
            game.set_theme(2);
          },
          ),
          _buildMenuItem(
          'Lava Lunge',
          blackTextColor,
          whiteTextColor,
          () {
            game.set_theme(3);
          },
          ),
        ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
        onPressed: () {
          game.overlays.remove('MainMenu');
          game.start_game();
         // game.reset(true);
         game.initializeGame(false);
        },
        child: Text(
          'Start Game',
          style: TextStyle(
          color: blackTextColor,
          fontSize: 24,
          ),
        ),
        ),
      ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontStyle: FontStyle.values[0],
              ),
            ),
            // const SizedBox(height: 10),
            // Icon(
            //   Icons.add,
            //   color: textColor,
            //   size: 40,
            // ),
          ],
        ),
      ),
    );
  }
}