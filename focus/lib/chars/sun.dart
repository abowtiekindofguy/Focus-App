import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/rendering.dart';

import '../breathe.dart';

class SunBall extends SpriteAnimationComponent with HasGameReference<ChuckBreathe>{
  int chuck_speed = 100;
  double inhale_time;
  double hold_up_time;
  double exhale_time;
  double hold_down_time;
  final Vector2 gridPosition;
  double xOffset;

  final Vector2 velocity = Vector2.zero();

  SunBall({
    required this.gridPosition,
    required this.xOffset,
    
    required this.inhale_time,
    required this.hold_up_time,
    required this.exhale_time,
    required this.hold_down_time,
  }) : super(size: Vector2.all(52), anchor: Anchor.bottomLeft);
  
  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('chuck.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: (inhale_time+exhale_time+hold_up_time+hold_down_time)/80,
      ),
    );
    position = Vector2(
      (gridPosition.x) + xOffset,
      game.size.y - (gridPosition.y),
    );
    add(
      SequenceEffect([
        MoveAlongPathEffect(
          Path()..addPolygon([const Offset(0, 0), Offset(0, -game.canvasSize.y/3)], false),
          EffectController(
            duration: inhale_time,
            
          ),
        ),
        MoveAlongPathEffect(
          Path()..addPolygon([const Offset(0, 0), Offset(game.canvasSize.x-156, 0)], false),
          EffectController(
            duration: hold_up_time,
            
          ),
        ),
        MoveAlongPathEffect(
          Path()..addPolygon([const Offset(0, 0), Offset(0, game.canvasSize.y/3)], false),
          EffectController(
            duration: exhale_time,
            
          ),
        ),
        MoveAlongPathEffect(
          Path()..addPolygon([const Offset(0, 0), Offset(-game.canvasSize.x+156, 0)], false),
          EffectController(
            duration: hold_down_time,
            
          ),
        ),
      ],
        infinite: true,
      ),
      
    );
  }

  @override
  void update(double dt) {
    velocity.x = 0;
    position += velocity * dt;
    super.update(dt);
  }
}