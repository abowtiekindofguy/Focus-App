import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'chars/chuck_breathe.dart';

class ChuckBreathe extends FlameGame{
  late Chuck _chuck;
  late SpriteComponent _sun;
  late HudButtonComponent _stop_button;
  double inhale_time = 5;
  double hold_up_time = 5;
  double exhale_time = 5;
  double hold_down_time = 5;
  double slider_idx = 0;
  String toggle_text = "Start Breathing";
  @override 
  Future<void> onLoad() async {
    await images.loadAll([
      'chuck.png',
      'stop_button.png',
      'sun.png',
    ]);
    initializeBreathe(false);
  }


  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 18, 18, 18);
  }
  void initializeBreathe(bool start){
    _chuck= Chuck(
      gridPosition: Vector2(52, 0.4*canvasSize.y), 
      xOffset: 0,
      inhale_time: inhale_time,
      hold_up_time: hold_up_time,
      exhale_time: exhale_time,
      hold_down_time: hold_down_time,
    );
    
    
    _sun = SpriteComponent(
        size: Vector2(100, 100),
        sprite: Sprite(images.fromCache('sun.png'), srcSize: Vector2(256, 256)),
        position: Vector2(size.x / 2, 13*size.y/30),
        anchor: Anchor.center,

      )..add(
            SequenceEffect(
            [
              ScaleEffect.by(
              Vector2.all(1.7),
              EffectController(
                duration: inhale_time,

              ),
              ),
              ScaleEffect.by(
              Vector2.all(1),
              EffectController(
                duration: hold_up_time,

              ),
              ),
              ScaleEffect.by(
              Vector2.all(1/1.7),
              EffectController(
                duration: exhale_time,

              ),
              ),
              ScaleEffect.by(
              Vector2.all(1),
              EffectController(
                duration: hold_down_time,

              ),
              ),
            ],
            infinite: true,
            ),
        );
    
    _stop_button = HudButtonComponent(
        size: Vector2(87, 49),
        position: Vector2(canvasSize.x/2, 0.7*canvasSize.y),
        anchor: Anchor.center,
        button: PositionComponent(
          anchor: Anchor.center, 
          children: [
            SpriteComponent(
              size: Vector2(87, 49),
              sprite: Sprite(images.fromCache('stop_button.png')),
            )
          ]
        ),
        onPressed: (){
          print("yes");
          overlays.add('dropdown');
          _chuck.removeFromParent();
          _sun.removeFromParent();
          _stop_button.removeFromParent();
        }
      );
      if(start){
        addStuff();
      }
  }  

  void addStuff(){
    add(_chuck);
    add(_sun);
    add(_stop_button);
  }

  void reset(){
    _chuck.removeFromParent();
    initializeBreathe(true);
  }
}