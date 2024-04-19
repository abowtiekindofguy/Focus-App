import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../breathe.dart';

class DropdownOverlay extends StatefulWidget{
  final ChuckBreathe chuck_breathe;
  DropdownOverlay({Key? key, required this.chuck_breathe}) : super(key: key);
  @override
  State<DropdownOverlay> createState() => _DropdownState();
}

class _DropdownState extends State<DropdownOverlay>{
  double _currentSliderValue = 5;
  
  String _button_text = "Inhale Time";
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
      color: Colors.transparent,
      child: Container(
        
        child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: const EdgeInsets.all(8.0),
            child: Text(
              "Breathe",style: TextStyle(color:Colors.white, fontSize: 20),
            ),
          ),
          ElevatedButton(
            onPressed: (){
              widget.chuck_breathe.overlays.remove('dropdown');
              widget.chuck_breathe.reset();
            }, 
            child: Text("Start", style: TextStyle(color:Colors.white),),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 24, 24, 24)),
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Inhale Time", style: TextStyle(color:Colors.white),
                ),
              ),
              Container(
                height: 100,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(builder: (context) =>
                      Slider(
                        value: _currentSliderValue,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          _currentSliderValue = value;
                          widget.chuck_breathe.inhale_time = value;
                        },
                      )
                    )
                  ]            
                ), 
              ),
            ],
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Hold Up Time",style: TextStyle(color:Colors.white),
                ),
              ),
              Container(
                height: 100,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(builder: (context) =>
                      Slider(
                        value: _currentSliderValue,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          _currentSliderValue = value;
                          widget.chuck_breathe.hold_up_time = value;
                        },
                      )
                    )
                  ]           
                ), 
              ),
            ],
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Exhale Time",style: TextStyle(color:Colors.white),
                ),
              ),
              Container(
                height: 100,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(builder: (context) =>
                      Slider(
                        value: _currentSliderValue,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          _currentSliderValue = value;
                          widget.chuck_breathe.exhale_time = value;
                        },
                      )
                    )
                  ]            
                ), 
              ),
            ],
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Hold Up Time",style: TextStyle(color:Colors.white),
                ),
              ),
              Container(
                height: 100,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(builder: (context) =>
                      Slider(
                        value: _currentSliderValue,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          _currentSliderValue = value;
                          widget.chuck_breathe.hold_down_time = value;
                        },
                      )
                    )
                  ]            
                ), 
              ),
            ],
          ),
        ],
      ),
      )
      )
    );
  }
}
