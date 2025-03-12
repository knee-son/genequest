import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:flame_tiled/flame_tiled.dart' as flameTiled;


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
    final double containerHeight = MediaQuery.of(context).size.height * 0.2; // Dynamically calculate height
    return Scaffold(
      body: Stack(
        children: [
          // Game canvas
          LayoutBuilder(
            builder: (context, constraints) {
              // Pass the containerHeight to your game logic
              return GameWidget(
                game: GenequestGame(containerHeight: containerHeight),
              );
            },
          ),

          // Buttons at the bottom of the screen with a border
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: containerHeight,
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
          // Start and Reset buttons on the left center
          Align(
            alignment: Alignment.centerLeft, // Align buttons to the left center
            child: Padding(
              padding: const EdgeInsets.only(left: 10), // Adjust padding if needed
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wrap around the buttons only
                children: [
                  GestureDetector(
                    onTap: () {
                      // Start button logic
                      print('Start button pressed');
                    },
                    child: Image.asset(
                      'assets/images/button_start.png', // Replace with your Start button asset
                      width: 100,
                      height: 50,
                    ),
                  ),
                  const SizedBox(height: 10), // Space between Start and Reset buttons
                  GestureDetector(
                    onTap: () {
                      // Reset button logic
                      GenequestGame.instance?.reset(); // Call the reset method
                    },
                    child: Image.asset(
                      'assets/images/button_reset.png', // Replace with your Reset button asset
                      width: 100,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu asset on the upper-right corner
          Align(
            alignment: Alignment.topLeft, // Align to the upper-left corner
            child: Padding(
              padding: const EdgeInsets.all(10), // Add padding for better placement
              child: Row(
                mainAxisSize: MainAxisSize.min, // Wrap content only
                children: [
                  // Menu button
                  GestureDetector(
                    onTap: () {
                      // Menu button logic
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/images/button_menu.png', // Replace with your Menu button asset
                      width: 100,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 10), // Add space between the buttons
                  // Pause button
                  GestureDetector(
                    onTap: () {
                      // Display the pause menu
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return PauseMenu();
                        },
                      );
                    },
                    child: Image.asset(
                      'assets/images/button_pause.png', // Replace with your pause button asset
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),


          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Wrap content only
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    // Space between hearts
                    child: Image.asset(
                      'assets/images/heart_full.png',
                      // Reuse the same heart image asset
                      width: 40,
                      height: 40,
                    ),
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
class PauseMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GenequestGame.instance?.pause();
        return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Game Paused",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (GenequestGame.instance?.isPaused == true) {
                  GenequestGame.instance?.resume(); // Resume the game
                }
                Navigator.pop(context); // Close the pause menu
              },
              child: Text("Resume"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close pause menu
                Navigator.pop(context); // Navigate back to TitleScreen
              },
              child: Text("Exit to Title"),
            ),
          ],
        ),
      ),
    );
  }
}



// ------------------- GAME LOGIC -------------------

class GenequestGame extends FlameGame {
  static GenequestGame? instance; // Singleton for UI interaction
  late Avatar avatar;
  final double containerHeight;
  bool isPaused = false;

  GenequestGame({required this.containerHeight}) {
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
    final level = await flameTiled.TiledComponent.load(
      'Level.tmx',
      Vector2.all(20),
    );
    add(level);
    final chromatidSprite = Sprite(Flame.images.fromCache('chromatid.png'));
    avatar = Avatar(chromatidSprite); // Pass the sprite to Avatar


    final screenHeight = size.y; // Total screen height
    avatar.groundY = screenHeight - containerHeight - avatar.size.y;
    add(avatar);
  }

  void pause() {
    isPaused = true; // Set the game to paused
  }

  void resume() {
    isPaused = false;
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
    if (!isPaused) {
      avatar.applyGravity(dt); // Apply gravity
      avatar.updatePosition(dt); // Update avatar position
    }
  }

  void reset() {
    // Reset avatar position
    avatar.position = Vector2(200, 300); // Initial position
    avatar.velocityX = 0; // Stop horizontal movement
    avatar.velocityY = 0; // Stop vertical movement
    avatar.isInAir = false; // Ensure avatar is grounded

    // If you have additional game state variables (e.g., score, level), reset them here
  }
}

// ------------------- AVATAR LOGIC -------------------

class Avatar extends SpriteComponent {
  double velocityX = 0; // Horizontal velocity
  double velocityY = 0; // Vertical velocity
  final double gravity = 500; // Downward acceleration
  double groundY = 0; // Adjusted ground level to sit above the button border
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