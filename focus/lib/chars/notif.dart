import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../chuck_jump.dart';

class Notif extends SpriteAnimationComponent
    with HasGameReference<ChuckJumpGame> {
  Notif({
    super.position,
  }) : super(
          size: Vector2(32, 28),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'notif.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: .2,
        textureSize: Vector2(700, 700),
      ),
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));

  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x += dt * -300;
    if(game.objectSpeed != 0){
      position.x += dt * game.objectSpeed;
    }
    if (position.y < -height || position.x <0|| game.health<=0 || game.starsCollected == game.score_to_achieve) {
      removeFromParent();
    }

    
  }
}