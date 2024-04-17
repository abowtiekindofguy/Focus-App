import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../chuck_jump.dart';
import 'chuck.dart';

class Shield extends SpriteComponent
    with HasGameReference<ChuckJumpGame> {
  Shield({
    super.position,
  }) : super(
          size: Vector2(24, 24),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = Sprite(Flame.images.fromCache('shield.png'), srcSize: Vector2(496, 503));
    // add(RectangleHitbox(collisionType: CollisionType.passive));

  }

  @override
  void update(double dt) {
    super.update(dt);

    // position.x += dt * game.chuck.velocity.x;
    // position.y += dt * game.chuck.velocity.y;

    if (position.x <0|| game.health<=0) {
      removeFromParent();
    }

    
  }
}