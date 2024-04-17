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
          'Plenty Plains',
          Color.fromARGB(255, 66, 126, 154),
          whiteTextColor,
          () {
            game.set_theme(0);
            game.startGame = false;
            game.backgroundColor();
            game.reset(true);
          },
          ),
          _buildMenuItem(
          'Ender City',
          Color.fromARGB(255, 121, 62, 216),
          whiteTextColor,
          () {
            game.set_theme(1);
            game.startGame = false;
            game.backgroundColor();
            game.reset(true);
          },
          ),
          _buildMenuItem(
          'The Dark Side of the Moon',
          Color.fromARGB(255, 56, 56, 56),
          whiteTextColor,
          () {
            game.set_theme(2);
            game.startGame = false;
            game.backgroundColor();
            game.reset(true);
          },
          ),
          _buildMenuItem(
          'Lava Lunge',
          Color.fromARGB(255, 152, 30, 30),
          whiteTextColor,
          () {
            game.set_theme(3);
            game.startGame = false;
            game.backgroundColor();
            game.reset(true);
          },
          ),
        ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
        onPressed: () {
          game.overlays.remove('MainMenu');
          game.start_game();
          game.reset(true);
          // game.initializeGame(false);
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