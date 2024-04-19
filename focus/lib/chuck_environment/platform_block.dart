import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../chuck_jump.dart';

class PlatformBlock extends SpriteComponent
    with HasGameReference<ChuckJumpGame> {
  final Vector2 velocity = Vector2.zero();
  final Vector2 gridPosition;
  double xOffset;
  final String blockImage;
  PlatformBlock({
    required this.gridPosition,
    required this.xOffset,
    required this.blockImage,
  }) : super(size: Vector2.all(32), anchor: Anchor.bottomLeft);

  @override
  void onLoad() {
    final platformImage = game.images.fromCache(blockImage);
    sprite = Sprite(platformImage);
    position = Vector2((gridPosition.x * size.x) + xOffset,
        game.size.y - (gridPosition.y * size.y),
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

   @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x|| game.health<=0 || game.starsCollected == game.score_to_achieve) removeFromParent();
    super.update(dt);
    
  }
}