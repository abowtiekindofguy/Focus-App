import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../chuck_jump.dart';
import 'heart.dart';

class Hud extends PositionComponent with HasGameReference<ChuckJumpGame> {
  final String heartImage;
  final String heartHalfImage; 
  Hud({
    required this.heartImage,
    required this.heartHalfImage, 
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  });
  
  late TextComponent _scoreTextComponent;
  late TextComponent _scoreTargetComponent;

  @override
  Future<void> onLoad() async {
    _scoreTextComponent = TextComponent(
      text: '${game.starsCollected}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Color.fromRGBO(128, 86, 1, 1),
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x - 60, 20),
    );
    add(_scoreTextComponent);
    
    _scoreTargetComponent = TextComponent(
      text: 'Target:${game.score_to_achieve}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(128, 86, 1, 1),
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x - 168, 22),
    );
    add(_scoreTargetComponent);

    final starSprite = await game.loadSprite('star.png');
    add(
      SpriteComponent(
        sprite: starSprite,
        position: Vector2(game.size.x - 100, 20),
        size: Vector2.all(32),
        anchor: Anchor.center,
      ),
    );

    for (var i = 1; i <= game.health; i++) {
      final positionX = 40 * i;
      await add(
        HeartHealthComponent(
          heartNumber: i,
          position: Vector2(positionX.toDouble(), 20),
          size: Vector2.all(32),
          heartImage: heartImage,
          heartHalfImage: heartHalfImage,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.starsCollected}';
  }
}