import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
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
      body: Stack(
        children: [
          // Game canvas
          GameWidget(game: GenequestGame()),

          // Buttons at the bottom of the screen with a border
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Background color for the border area
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2), // Top border
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity, // Full width of the screen
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between buttons
                children: [
                  // Left-aligned buttons
                  Padding(
                    padding: const EdgeInsets.only(left: 10), // Padding for the left buttons
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTapDown: (details) {
                            GenequestGame.instance?.startMovingAvatarBack(); // Start moving back
                          },
                          onTapUp: (details) {
                            GenequestGame.instance?.stopMovingAvatar(); // Stop moving
                          },
                          onTapCancel: () {
                            GenequestGame.instance?.stopMovingAvatar(); // Stop moving
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.14159), // Flip the image horizontally
                            child: Image.asset(
                              'assets/images/button_forward.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20), // Space between buttons
                        // Forward button
                        GestureDetector(
                          onTapDown: (details) {
                            GenequestGame.instance?.startMovingAvatar(); // Start moving forward
                          },
                          onTapUp: (details) {
                            GenequestGame.instance?.stopMovingAvatar(); // Stop moving
                          },
                          onTapCancel: () {
                            GenequestGame.instance?.stopMovingAvatar(); // Stop moving
                          },
                          child: Image.asset(
                            'assets/images/button_forward.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right-aligned "Up" button
                  Padding(
                    padding: const EdgeInsets.only(right: 10), // Add padding to the right
                    child: GestureDetector(
                      onTapDown: (details) {
                        GenequestGame.instance?.startJump(); // Trigger jump on press
                      },
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationZ(-1.5708), // Rotate the image to point up
                        child: Image.asset(
                          'assets/images/button_forward.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- GAME LOGIC -------------------

class GenequestGame extends FlameGame {
  static GenequestGame? instance; // Singleton for UI interaction
  late Avatar avatar;

  GenequestGame() {
    instance = this;
  }

  @override
  Color backgroundColor() => const Color(0xFFCCCCCC); // Light gray background

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

  // Method to trigger a jump
  void startJump() {
    if (!avatar.isInAir) {
      avatar.velocityY = -300; // Give an upward velocity
      avatar.isInAir = true;  // Set the avatar as mid-air
    }
  }

  // Movement methods
  void startMovingAvatar() {
    avatar.velocityX = 100; // Positive horizontal velocity
  }

  void startMovingAvatarBack() {
    avatar.velocityX = -100; // Negative horizontal velocity
  }

  void stopMovingAvatar() {
    avatar.velocityX = 0; // Stop horizontal movement
  }

  @override
  void update(double dt) {
    super.update(dt);
    avatar.applyGravity(dt); // Apply gravity
    avatar.updatePosition(dt); // Update avatar position
  }
}

// ------------------- AVATAR LOGIC -------------------

class Avatar extends SpriteComponent {
  double velocityX = 0; // Horizontal velocity
  double velocityY = 0; // Vertical velocity
  final double gravity = 500; // Downward acceleration
  final double groundY = 200; // Adjusted ground level to sit above the button border
  bool isInAir = false; // Tracks whether the avatar is airborne

  Avatar(Sprite sprite)
      : super(
    sprite: sprite,
    size: Vector2(100, 100), // Avatar size
    position: Vector2(200, 300), // Starting position above the border
  );

  // Apply gravity to the avatar
  void applyGravity(double dt) {
    // Only apply gravity if in the air
    if (isInAir) {
      velocityY += gravity * dt;
    }
    // If the avatar has fallen to the ground, stop gravity and reset position
    if (position.y > groundY) {
      velocityY = 0;
      isInAir = false;
      position.y = groundY; // Lock to the ground
    }
  }

  // Update the avatar's position based on velocities
  void updatePosition(double dt) {

    position.x += velocityX * dt;
    position.y += velocityY * dt;// Debugging print
  }
}