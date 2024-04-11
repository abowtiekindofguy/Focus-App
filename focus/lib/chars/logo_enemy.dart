import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../chuck_jump.dart';

class LogoEnemy extends SpriteAnimationComponent
    with HasGameReference<ChuckJumpGame> {
  final Vector2 gridPosition;
  double xOffset;

  final Vector2 velocity = Vector2.zero();

  LogoEnemy({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(32), anchor: Anchor.bottomLeft);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('instagram_icon.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(256),
        stepTime: 0.70,
      ),
    );
    position = Vector2(
      (gridPosition.x * size.x) + xOffset,
      game.size.y - (gridPosition.y * size.y),
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
    add(
      MoveEffect.by(
        Vector2(-2 * size.x, 0),
        EffectController(
          duration: 3,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x|| game.health<=0) removeFromParent();
    super.update(dt);
  }
}