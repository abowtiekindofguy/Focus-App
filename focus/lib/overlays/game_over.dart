import 'package:flutter/material.dart';
// import 'p/chuck_jump.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
import '../chuck_jump.dart';

void setPref(String str, int n) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(str, n);
}
int getPref(String str) {
  int n = 0;
  SharedPreferences.getInstance().then((prefs) {
    n = prefs.getInt(str) ?? 1;
  });
  return n;
}
class GameOver extends StatelessWidget {
  // Reference to parent game.
  final ChuckJumpGame game;
  int game_tries = 0;
  String date_string = DateTime.now().day.toString()+"/"+DateTime.now().month.toString()+"/"+DateTime.now().year.toString();
  GameOver({super.key, required this.game});
  // int game_tries = 0;
  bool can_play = false;

  @override
  void update(double dt) {
    date_string = DateTime.now().day.toString()+"/"+DateTime.now().month.toString()+"/"+DateTime.now().year.toString();
    // getTries();
    // can_play = (game_tries < 5);
  }

  void getTries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    String cur_date = DateTime.now().day.toString()+"/"+DateTime.now().month.toString()+"/"+DateTime.now().year.toString();
    game_tries = prefs.getInt(cur_date) ?? 1;
  }
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
                    game.played = false;
                    game.overlays.remove('GameOver');
                    getTries();
                    can_play = (game_tries < 20);
                    print(can_play);
                    if(can_play) game.overlays.add('MainMenu');
                    else game.overlays.add('Exhausted');
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