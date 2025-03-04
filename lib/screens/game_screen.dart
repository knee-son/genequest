import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.images.loadAll([
    'chromatid.png',
    'platform_1.png',
    'button_forward.png',
  ]);

  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: GenequestGame()),
    );
  }
}

// ------------------- GAME LOGIC -------------------

class GenequestGame extends FlameGame with HasKeyboardHandlerComponents {
  late Avatar avatar;

  @override
  Future<void> onLoad() async {
    await Flame.images.loadAll([
      'chromatid.png',
      'platform_1.png',
      'button_forward.png',
    ]);

    final chromatidSprite = Sprite(Flame.images.fromCache('chromatid.png'));
    avatar = Avatar(chromatidSprite); // Pass the sprite to Avatar
    add(avatar);
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    if (event is KeyDownEvent &&
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      avatar.applyMomentum();
    }
    return KeyEventResult.handled;
  }
}

class Avatar extends SpriteComponent with HasGameRef<GenequestGame> {
  double momentum = 0;

  Avatar(Sprite sprite)
      : super(
            sprite: sprite, size: Vector2(50, 50), position: Vector2(100, 300));

  void applyMomentum() {
    momentum += 2;
  }

  @override
  void update(double dt) {
    position.x += momentum * dt;
    momentum *= 0.98;
  }
}
