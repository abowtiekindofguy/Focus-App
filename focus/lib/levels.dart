import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus/main_chuck.dart';// Make sure this is the correct path to your game logic
import 'package:shared_preferences/shared_preferences.dart';
class LevelsPage extends StatefulWidget {
  List<bool> locked = List.generate(40, (index) => (index == 0) ? false : true); // Default values
  // TODO: Extract list from shared preferences if present
  // Example code to extract from shared preferences:
  
  @override
  _LevelsPageState createState() => _LevelsPageState();
}
class _LevelsPageState extends State<LevelsPage> {
  double fire_speed = 1.5;
  int score_to_achieve= 20;
  double gravity = 15;
  int init_health = 10;
  @override
  void initState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList('locked');
    if (savedList != null) {
      widget.locked = savedList.map((e) => e == 'true').toList();
    }
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 4,
        scrollDirection: Axis.horizontal,
        children: List.generate(40, (index) {
          return Padding(
            padding: EdgeInsets.all(4.0), // Add padding between buttons

                child: ElevatedButton(
                  onPressed: () {
                    fire_speed = 3 - (index~/10)*0.5;
                    score_to_achieve = 20 + (1+index%10)*2;
                    gravity = 15;
                    if(!widget.locked[index]){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => GameScreen(
                        init_health: init_health,
                        gravity: gravity,
                        score_to_achieve: score_to_achieve,
                        fire_speed: fire_speed,
                        lvl: index + 1,
                        lvls: widget,
                      ),
                      ),
                    );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    minimumSize: Size(100, 70), // Increase the button width to 120
                  ),
                  child: (widget.locked[index])?Icon(Icons.lock) :Text('Level ${index + 1}'),
                ),
            
          
          );
        }), // Make the buttons scrollable in the cross axis
      ),
    );
  }
}