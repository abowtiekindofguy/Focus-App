import '../chuck_jump.dart';
import 'package:flame/components.dart';
// import 'package:gaem/chuck_jump.dart';

enum HeartState {
  available,
  unavailable,
}

class HeartHealthComponent extends SpriteGroupComponent<HeartState>
    with HasGameReference<ChuckJumpGame> {
  final int heartNumber;
  final heartImage;
  final heartHalfImage; 
  HeartHealthComponent({
    required this.heartNumber,
    required this.heartImage,
    required this.heartHalfImage,
    required super.position,
    required super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final availableSprite = await game.loadSprite(
      heartImage,
      srcSize: Vector2.all(32),
    );

    final unavailableSprite = await game.loadSprite(
      heartHalfImage,
      srcSize: Vector2.all(32),
    );

    sprites = {
      HeartState.available: availableSprite,
      HeartState.unavailable: unavailableSprite,
    };

    current = HeartState.available;
  }

  @override
  void update(double dt) {
    if (game.health < heartNumber) {
      current = HeartState.unavailable;
    } else {
      current = HeartState.available;
    }
    if(game.health == 0){
      removeFromParent();
    }
    super.update(dt);
  }
}