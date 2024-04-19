import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus/main_chuck.dart';// Make sure this is the correct path to your game logic
import 'package:shared_preferences/shared_preferences.dart';



Future<List<String>?> getList() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList('locked');
    return savedList;
    // if (savedList != null) {
    //   widget.locked = savedList.map((e) => e == 'true').toList();
    // }
}

class LevelsPage extends StatefulWidget {
  List<bool> locked = (List.generate(40, (index) => (index == 0) ? false : true)); // Default values
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
  int game_tries = 0;
  @override
  void initState()  {
    // resetList();
    // resetTries();
    getTries();
    setList();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void setList() async {
    List<String>? savedList = await getList();
    if (savedList != null) {
      setState(() {
        widget.locked = savedList.map((e) => e == 'true').toList();
      });
    }
  }  
  void resetList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('locked');
    setState(() {
      widget.locked = List.generate(40, (index) => (index == 0) ? false : true);
    });
  }
  void resetTries()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String date_string = DateTime.now().day.toString()+"/"+DateTime.now().month.toString()+"/"+DateTime.now().year.toString();
    prefs.setInt(date_string, 0);
  }
  void getTries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    String date_string = DateTime.now().day.toString()+"/"+DateTime.now().month.toString()+"/"+DateTime.now().year.toString();
    game_tries = prefs.getInt(date_string) ?? 1;
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
                    score_to_achieve = 15 + (1+index%10)*2;
                    gravity = 15;
                    getTries();
                    print(game_tries);
                    if(!widget.locked[index] && game_tries<20){
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
                    } else if(game_tries>=20){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('You have played 5 games today'),
                            content: Text('Please try again tomorrow'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    minimumSize: Size(100, 70), // Increase the button width to 120
                  ),
                  child: (widget.locked[index])? Icon(Icons.lock) :Text('Level ${index + 1}'),
                ),
            
          
          );
        }), // Make the buttons scrollable in the cross axis
      ),
    );
  }
}