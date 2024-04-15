import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import '../chuck_environment/ground_block.dart';
import '../chuck_environment/platform_block.dart';
import '../chuck_environment/star.dart';
import '../chars/logo_enemy.dart';
import '../chuck_jump.dart';

class ChuckPlayer extends SpriteAnimationComponent
    with CollisionCallbacks ,HasGameReference<ChuckJumpGame>  {
  int horizontalDirection = 0;
  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;
  final Vector2 fromAbove = Vector2(0, -1);
  bool isOnGround = false;
  final double gravity = 15;
  final double jumpSpeed = 500;
  final double terminalVelocity = 75;
  bool hitByEnemy = false;
  bool hasJumped = false;

  ChuckPlayer({
    required super.position,
  }) : super(size: Vector2.all(32), anchor: Anchor.center);

  @override
  void onLoad() {
    add(CircleHitbox());
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('chuck.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );
  }

  @override
  bool onKeyEvent(Set<int> keys) {
    horizontalDirection = 0;
    horizontalDirection += (keys.contains(-1) ? -1: 0)*(keys.contains(2) ? 3 : 1);
    horizontalDirection += (keys.contains(1) ? 1: 0)*(keys.contains(2) ? 3 : 1);

    hasJumped = keys.contains(0);
    
    print(keys);
    print(horizontalDirection);
    return true;
  }

  @override
  void update(double dt) {
    velocity.x = horizontalDirection * moveSpeed;
    
    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally(); 
    } 
    velocity.y += gravity;

    if (hasJumped) {
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
      hasJumped = false;
    }

    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);

    game.objectSpeed = 0;
// Prevent ember from going backwards at screen edge.
  if (position.x - 36 <= 0 && horizontalDirection < 0) {
    velocity.x = 0;
  }
  // Prevent ember from going beyond half screen.
  if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
    velocity.x = 0;
    game.objectSpeed = -moveSpeed;
  }
  if (position.y > game.size.y + size.y) {
    game.health = 0;
  }

  if (game.health <= 0) {
    removeFromParent();
  }
  position += velocity * dt;
  super.update(dt);

  }
  
  @override
void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  if (other is GroundBlock || other is PlatformBlock) {
    if (intersectionPoints.length == 2) {
      // Calculate the collision normal and separation distance.
      final mid = (intersectionPoints.elementAt(0) +
        intersectionPoints.elementAt(1)) / 2;

      final collisionNormal = absoluteCenter - mid;
      final separationDistance = (size.x / 2) - collisionNormal.length;
      collisionNormal.normalize();

      // If collision normal is almost upwards,
      // ember must be on ground.
      if (fromAbove.dot(collisionNormal) > 0.9) {
        isOnGround = true;
      }

      // Resolve collision by moving ember along
      // collision normal by separation distance.
      position += collisionNormal.scaled(separationDistance);
      }
    }
    if (other is Star) {
      other.removeFromParent();
      game.starsCollected++;
    }

    if (other is LogoEnemy) {
      hit();
    }

  super.onCollision(intersectionPoints, other);
}
  void hit() {
    if (!hitByEnemy) {
      hitByEnemy = true;
      game.health--;
    }
    add(
      OpacityEffect.fadeOut(
      EffectController(
        alternate: true,
        duration: 0.1,
        repeatCount: 6,
      ),
      )..onComplete = () {
        hitByEnemy = false;
      },
    );
  }
}