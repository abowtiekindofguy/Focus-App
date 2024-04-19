import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';


import '../chuck_jump.dart';
import 'notif.dart';

class LogoEnemy extends SpriteAnimationComponent
    with HasGameReference<ChuckJumpGame> {
  final Vector2 gridPosition;
  double xOffset;
  bool shoot_power = false;
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
    if (position.x < -size.x|| game.health<=0 || game.starsCollected == game.score_to_achieve) removeFromParent();
    super.update(dt);
  }
}

class ShooterEnemy extends LogoEnemy{
  late final SpawnComponent _bulletSpawner;
  bool shoot_power = false;
  double fire_speed;
  ShooterEnemy({
    required this.fire_speed,
    required super.gridPosition,
    required super.xOffset,
  });

  @override
  Future<void> onLoad() async {
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
    _bulletSpawner = SpawnComponent(
      period: fire_speed,
      selfPositioning: true,
      factory: (index) {
        return Notif(
          position: position+Vector2(0,-size.y/2),
        );
      },
      autoStart: true,
    );
    if(!shoot_power && game.camera.visibleWorldRect.contains(Offset(position.x,position.y))){
      shoot_power= true;
      super.game.add(_bulletSpawner);
    }
  }

  @override
  void update(double dt) {
    // velocity.x = game.objectSpeed;
    // position += velocity * dt;
    if(!shoot_power && game.camera.visibleWorldRect.contains(Offset(position.x,position.y))){
      shoot_power= true;
      super.game.add(_bulletSpawner);
    }
    if (position.x < -size.x|| game.health<=0 || game.starsCollected == game.score_to_achieve) {
      removeFromParent();
      _bulletSpawner.removeFromParent();
    }
    super.update(dt);
  }

}