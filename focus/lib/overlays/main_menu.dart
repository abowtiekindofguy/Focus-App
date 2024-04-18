import 'package:flutter/material.dart';
import 'package:focus/chuck_environment/ground_block.dart';

import '../chuck_jump.dart';

class MainMenu extends StatelessWidget {
  // Reference to parent game.
  final ChuckJumpGame game;
  String difficulty = 'Medium';
  MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Row(
      children: [
        Container(
            width: 400,
            height: 200,
            // child: 
            
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
  
                //     ElevatedButton(
                //       onPressed: () {
                //         game.difficulty = 0;
                //         difficulty = 'Easy';
                //       },
                //       child: Text('Easy'),
                //     ),
                //     ElevatedButton(
                //       onPressed: () {
                //         game.difficulty = 1;
                //         difficulty = 'Medium';
                //       },
                //       child: Text('Medium'),
                //     ),
                //     ElevatedButton(
                //       onPressed: () {
                //         game.difficulty = 2;
                //         difficulty = 'Hard';
                //       },
                //       child: Text('Hard'),
                //     ),
                //   ],
                // ),
              
          ),
        Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          
          Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
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
          ElevatedButton(
          onPressed: () {
            game.overlays.remove('MainMenu');
            game.start_game();
            game.reset(true);
          },
          child: const Text(
            'Play',
            style: TextStyle(
            color: blackTextColor,
            fontSize: 24,
            ),
          ),
          ),
        ],
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
      width: 400,
      height: 50,
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