import 'package:flutter/material.dart';
import 'package:focus/chars/chuck_breathe.dart';
// import 'p/chuck_jump.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../chuck_jump.dart';

class Exhausted extends StatelessWidget{
  final ChuckJumpGame game;
  Exhausted({required this.game});
  @override
  Widget build(BuildContext context){
    return Material(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 300,
          width: 300,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Tries Exhausted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'You have played 20 times today. Please try again tomorrow.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30,),
              SizedBox(
                width: 200,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    // back to app route
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text('Back to App'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}