import 'package:flutter/material.dart';
import 'package:flutter/services.dart';// Make sure this is the correct path to your game logic

class LevelsPage extends StatefulWidget {
  @override
  _LevelsPageState createState() => _LevelsPageState();
}
class _LevelsPageState extends State<LevelsPage> {
  double fire_speed = 1.5;
  int score_to_achive= 20;
  @override
  void initState() {
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
        children: List.generate(40, (index) {
          return Padding(
            padding: EdgeInsets.all(4.0), // Add padding between buttons
           
                child: ElevatedButton(
                  onPressed: () {
                    fire_speed = 1.5 + (index~/10)*0.5;
                    score_to_achive = 20 + (1+index%10)*2;
                  },
                  style: ElevatedButton.styleFrom(
                    shape : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    minimumSize: Size(100, 70), // Increase the button width to 120
                  ),
                  child: Text('Lvl ${index + 1}'),
                ),
            
          
          );
        }),
        scrollDirection: Axis.horizontal, // Make the buttons scrollable in the cross axis
      ),
    );
  }
}