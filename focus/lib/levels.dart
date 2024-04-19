import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus/main_chuck.dart';// Make sure this is the correct path to your game logic
import 'package:shared_preferences/shared_preferences.dart';
import 'challenge.dart';
import 'firebase_map.dart';


Future<List<String>?> getList() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList('locked');
    return savedList;
}

class LevelsPage extends StatefulWidget {
  final String userId;
  
  LevelsPage({super.key, required this.userId});
  List<bool> locked = (List.generate(40, (index) => (index == 0) ? false : true)); 

  @override
  _LevelsPageState createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  double fire_speed = 1.5;
  int score_to_achieve= 20;
  double gravity = 15;
  int init_health = 5;
  int game_tries = 0;
  @override
  void initState()  {
    getTries();
    setList();
    set_init_health();
    updateScore();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void updateScore() async{
    List<bool> lockedLevels = widget.locked;
    int score = lockedLevels.where((element) => element == false).length;
    FirebaseMapSet(widget.userId+"chuckGameScore", score.toString());
  }

  void set_init_health() async{
    final score = await getChallengeScore(widget.userId);
    if(score>0){
      init_health = score~/10 + 5;
    }
    else{
      init_health = 5;
    }
    setState(() {
      init_health = init_health;
    });
  }

  void dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
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
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      body: GridView.count(
        
        crossAxisCount: 4,
        scrollDirection: Axis.horizontal,
        children: List.generate(40, (index) {
          return Padding(
            padding: EdgeInsets.all(4.0),

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
                            backgroundColor: Color.fromARGB(255, 18, 18, 18),
                 
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
                    minimumSize: Size(100, 70), 
                  ),
                  child: (widget.locked[index])? Icon(Icons.lock) :Text('Level ${index + 1}'),
                ),
            
          
          );
        }), 
      ),
    );
  }
}