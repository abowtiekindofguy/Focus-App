import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'chars/chuck.dart';
import 'chars/logo_enemy.dart';
import 'chuck_environment/ground_block.dart';
import 'chuck_environment/platform_block.dart';
import 'chuck_environment/star.dart';
import 'overlays/hud.dart';
import 'managers/segments.dart';
import 'package:flutter/material.dart';

class ChuckJumpGame extends FlameGame with HasCollisionDetection{
  late ChuckPlayer _chuck;
  double objectSpeed = 0.0;
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;
  late bool up_button = false;
  late final HudButtonComponent leftButton;
  late final HudButtonComponent rightButton;
  late final HudButtonComponent upButton;
  late final HudButtonComponent boosterButton;
  Set<int> keys = {};
  int starsCollected = 0;
  int health;
  int theme = 0;
  bool startGame = false;
  ChuckJumpGame({required this.health});
  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'chuck.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'instagram_icon.png',
      'button_up.png',
      'button_left.png',
      'button_right.png',
      'button_booster.png',
    ]);
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport.add(Hud(heartImage: 'heart.png', heartHalfImage: 'heart_half.png'));
    initializeGame(true);
        // Create left button
    leftButton = createButtonComponent(
      position: Vector2(70,300),
      size: Vector2.all(64),
      onPressed: () => add_key(-1),
      onReleased: () => remove_key(-1),
      direction: 'left',
    );
    add(leftButton);

    // Create right button
    rightButton = createButtonComponent(
      position: Vector2(150,300),
      size: Vector2.all(64),
      onPressed: () => add_key(1),
      onReleased: () => remove_key(1),
      direction: 'right',
    );
    add(rightButton);

    upButton = createButtonComponent(
      position: Vector2(840, 300),
      size: Vector2.all(64),
      onPressed: () => add_key(0),
      onReleased: () => remove_key(0),
      direction: 'up',
    );
    add(upButton);


    boosterButton = createButtonComponent(
      position: Vector2(840, 100),
      size: Vector2.all(64),
      onPressed: () => add_key(2),
      onReleased: () => remove_key(2),
      direction: 'booster',
    );
    add(boosterButton);
    
  }

  void remove_key(int key){
    keys.remove(key);
    _chuck.onKeyEvent(keys);
  }

  void add_key(int key){
    keys.add(key);
    _chuck.onKeyEvent(keys);
  }
  
  @override
  Color backgroundColor() {
    if(theme == 0){
      return const Color.fromARGB(255, 173, 223, 247);
    } else if(theme == 1){
      return Color.fromARGB(255, 80, 3, 101);
    } else if(theme == 2){
      return Color.fromARGB(255, 0, 0, 0);
    } else if(theme == 3){
      return Color.fromARGB(255, 65, 4, 4);
    }
      
    return const Color.fromARGB(255, 173, 223, 247);

  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          world.add(
            GroundBlock(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
              blockImage: (theme == 0) ? 'ground.png' : 'block.png',
            ),
          );
          break;
        case PlatformBlock:
          add(PlatformBlock(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
        case Star:
          world.add(
            Star(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
        
          break;
        case LogoEnemy:
        if(startGame){
          world.add(
            LogoEnemy(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
            ),
          );
          break;
        }
      }
    }
  }

  void initializeGame(bool loadHud) {
  // Assume that size.x < 3200
  final segmentsToLoad = (size.x / 640).ceil();
  segmentsToLoad.clamp(0, segments.length);

  for (var i = 0; i <= segmentsToLoad; i++) {
    loadGameSegments(i, (640 * i).toDouble());
  }
  if(startGame){
  _chuck = ChuckPlayer(
    position: Vector2(128, canvasSize.y - 128),
  );
  
  add(_chuck);
  if (loadHud) {
    add(Hud(heartImage: 'heart.png',heartHalfImage: 'heart_half.png'));
  } 
  }
}

void reset(bool start) {
  starsCollected = 0;
  if(!start) {
    health = 3;
    add(Hud(heartImage: 'heart.png',heartHalfImage: 'heart_half.png'));
  }
  // initializeGame(false);
}

  void set_theme(int theme){
    this.theme = theme;
    backgroundColor();
    // reset();
  } 

  void start_game(){
    startGame = true;
  }

  HudButtonComponent createButtonComponent({
    required Vector2 position,
    required Vector2 size,
    required void Function() onPressed,
    required void Function() onReleased,
    required String direction,
  }) {
    return HudButtonComponent(
      position: position,
      size: size,
      button:  PositionComponent(children: [SpriteComponent(
        sprite: Sprite(Flame.images.fromCache('button_$direction.png')),
      )]), 
      onReleased:() => onReleased(),
      onPressed: onPressed,
      anchor: Anchor.center,
      priority: 1,
    );
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
    }
    super.update(dt);
  }
}




