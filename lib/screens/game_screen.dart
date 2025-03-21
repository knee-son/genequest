import 'package:flame/collisions.dart';
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
    final double containerHeight = MediaQuery.of(context).size.height *
        0.2; // Dynamically calculate height
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
            child: Visibility(
              visible: true,
              child: Container(
                height: containerHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  // Background color for the border area
                  border: Border(
                    top:
                        BorderSide(color: Colors.black, width: 2), // Top border
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                // Full width of the screen
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // Space between buttons
                  children: [
                    // Left-aligned buttons
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      // Padding for the left buttons
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTapDown: (details) {
                              GenequestGame.instance
                                  ?.startMovingAvatarBack(); // Start moving back
                            },
                            onTapUp: (details) {
                              GenequestGame.instance
                                  ?.stopMovingAvatar(); // Stop moving
                            },
                            onTapCancel: () {
                              GenequestGame.instance
                                  ?.stopMovingAvatar(); // Stop moving
                            },
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(3.14159),
                              // Flip the image horizontally
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
                              GenequestGame.instance
                                  ?.startMovingAvatar(); // Start moving forward
                            },
                            onTapUp: (details) {
                              GenequestGame.instance
                                  ?.stopMovingAvatar(); // Stop moving
                            },
                            onTapCancel: () {
                              GenequestGame.instance
                                  ?.stopMovingAvatar(); // Stop moving
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
                      padding: const EdgeInsets.only(right: 10),
                      // Add padding to the right
                      child: GestureDetector(
                        onTapDown: (details) {
                          GenequestGame.instance
                              ?.startJump(); // Trigger jump on press
                        },
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationZ(-1.5708),
                          // Rotate the image to point up
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
          ),
          // Start and Reset buttons on the left center
          Align(
            alignment: Alignment.centerLeft, // Align buttons to the left center
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              // Adjust padding if needed
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wrap around the buttons only
                children: [
                  GestureDetector(
                    onTap: () {
                      // Start button logic
                      // print('Start button pressed');
                    },
                    child: Image.asset(
                      'assets/images/button_start.png',
                      // Replace with your Start button asset
                      width: 100,
                      height: 50,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Space between Start and Reset buttons
                  GestureDetector(
                    onTap: () {
                      // Reset button logic
                      GenequestGame.instance?.reset(); // Call the reset method
                    },
                    child: Image.asset(
                      'assets/images/button_reset.png',
                      // Replace with your Reset button asset
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
              padding: const EdgeInsets.all(10),
              // Add padding for better placement
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
                      'assets/images/button_menu.png',
                      // Replace with your Menu button asset
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
                      'assets/images/button_pause.png',
                      // Replace with your pause button asset
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

class GenequestGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  static GenequestGame? instance; // Singleton for UI interaction
  late Avatar avatar;
  final double containerHeight;
  late Vector2 mapSize;
  bool isPaused = false;
  Vector2 spawnPosition = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];

  GenequestGame({required this.containerHeight}) {
    instance = this;
  }

  @override
  bool get debugMode => true;

  @override
  Color backgroundColor() => const Color(0xFFCCCCCC); // Light gray background

  @override
  Future<void> onLoad() async {
    await Flame.images.loadAll([
      'chromatid.png',
      'platform_1.png',
      'button_forward.png',
    ]);

    // Load the level
    final level = await flameTiled.TiledComponent.load(
      'Level.tmx',
      Vector2.all(64),
    );

    final spawnPointLayer =
        level.tileMap.getLayer<flameTiled.ObjectGroup>('SpawnPoint');
    // Create the avatar and set its spawn point dynamically
    final chromatidSprite = Sprite(Flame.images.fromCache('chromatid.png'));
    avatar = Avatar(chromatidSprite);
    spawnPosition = Vector2.zero(); // Default spawn position (fallback)

    // Find the spawn object in the SpawnPoint layer
    if (spawnPointLayer != null) {
      for (final spawn in spawnPointLayer.objects) {
        if (spawn.name == 'Spawn') {
          spawnPosition = Vector2(spawn.x, spawn.y);
          // Adjust spawn position to align the avatar's bottom with the top of the spawn point
          spawnPosition.y -= avatar.size.y;
          final floor = CollisionBlock(
            position: Vector2(spawn.x, spawn.y),
            size: Vector2(spawn.width, spawn.height),
            isFloor: true, // This is a floor, not a wall
          );
          collisionBlocks.add(floor);
          Future.delayed(Duration.zero, () {
            add(floor);
          });
          add(floor);
          // Set groundY to the top of the spawn point
          break;
        }
      }
    }

    final collisionsLayer =
        level.tileMap.getLayer<flameTiled.ObjectGroup>('Floor');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.name) {
          case 'Floor':
            final floor = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isFloor: true, // This is a floor, not a wall
            );
            collisionBlocks.add(floor);
            add(floor);
          default:
        }
      }
    }

    // Initialize the world and add the level
    final world = World();
    world.add(level);

    add(world);

    // Create the camera
    final camera = CameraComponent.withFixedResolution(
      width: 1980,
      height: 1080,
      world: world,
    );

    // Get the map size (in pixels)
    mapSize = level.size; // level.size is the total size of the map in pixels

    // Calculate container height for UI
    final double containerHeight = this.containerHeight;

    // Calculate the spawn point based on the map height (ground level)
    avatar.position = spawnPosition;
    // avatar.groundY = spawnPosition.y;

    // Add the avatar to the world
    world.add(avatar);

    // Make the camera follow the avatar
    camera.follow(avatar);

    // Adjust the camera's initial position (optional)
    camera.viewfinder.position = Vector2(
      0,
      mapSize.y -
          camera.viewport.size.y / 2, // Start near the bottom of the map
    );

    // Add keyboard listener
    add(KeyboardListenerComponent());

    // Add the camera to the game
    add(camera);
  }

  void pause() {
    isPaused = true; // Set the game to paused
  }

  void resume() {
    isPaused = false;
  }

  // Method to trigger a jump
  void startJump() {
    if (avatar.jumpCount < 2) {
      avatar.velocityY = -300; // Give an upward velocity
      avatar.isInAir = true; // Set the avatar as mid-air
      avatar.jumpCount++; // Increment the jump count
    }
  }

  // Movement methods
  void startMovingAvatar() {
    avatar.velocityX = 300; // Positive horizontal velocity
  }

  void startMovingAvatarBack() {
    avatar.velocityX = -300; // Negative horizontal velocity
  }

  void stopMovingAvatar() {
    avatar.velocityX = 0; // Stop horizontal movement
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      startJump();
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      stopMovingAvatar();
    } else {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        startMovingAvatarBack();
      } else if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        startMovingAvatar();
      }
    }

    if (event is KeyUpEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      stopMovingAvatar();
    } else if (event is KeyUpEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      stopMovingAvatar();
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPaused) {
      avatar.applyGravity(dt); // Apply gravity
      avatar.updatePosition(dt); // Update avatar position
    }
    // avatar.isInAir = true;
  }

  void reset() {
    // Reset avatar position
    avatar.position = spawnPosition;
    avatar.velocityX = 0; // Stop horizontal movement
    avatar.velocityY = 0; // Stop vertical movement
    avatar.isInAir = false; // Ensure avatar is grounded
    avatar.jumpCount = 0; // Reset jump count
    // If you have additional game state variables (e.g., score, level), reset them here
  }
}

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  bool isFloor;

  CollisionBlock({
    required Vector2 position,
    required Vector2 size,
    required this.isFloor,
  }) : super(position: position, size: size);

  @override
  bool get debugMode => true;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Add a colored rectangle to visualize the block
    final rectangle = RectangleComponent(
      position: position,
      size: size,
      paint: Paint()..color = const Color(0x88FF0000), // Semi-transparent red
    );
    add(rectangle);

    // Add the hitbox as usual
    add(RectangleHitbox());
  }
}

// ------------------- AVATAR LOGIC -------------------

class Avatar extends SpriteComponent with CollisionCallbacks {
  double velocityX = 0; // Horizontal velocity
  double velocityY = 0; // Vertical velocity
  final double gravity = 300; // Downward acceleration
  bool isInAir = false; // Tracks whether the avatar is airborne
  int jumpCount = 0; // Tracks the number of jumps

  bool leftFlag = true;

  Avatar(Sprite sprite)
      : super(
          sprite: sprite,
          size: Vector2(100, 100), // Avatar size
          position: Vector2(200, 300), // Starting position above the border
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
  }

  void applyGravity(double dt) {
    // Apply gravity only while airborne
    if (isInAir) {
      velocityY += gravity * dt; // Gravity pulls the avatar down
    } else {
      velocityY = 0;
    }
    // position.y += velocityY * dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    final double avatarTop = position.y;
    final double avatarBottom = position.y + size.y;
    final double avatarRight = position.x + size.x;
    final double avatarLeft = position.x;
    final double floorTop = other.position.y;
    final double floorBottom = other.position.y + size.y;
    final double floorRight = other.position.x + other.size.x;
    final double floorLeft = other.position.x;

    if (other is CollisionBlock) {
      // Check if avatar is landed on top of the floor
      if (other.isFloor && velocityY > 0) {
        jumpCount = 0; // Reset jump count when landing

        // what's with adding velocityY?
        // horizontal clipping zone is dependent on the fall speed
        // and the *0.05 is an arbitrary factor how much the zone
        // scales the faster the fall is
        if (floorTop <= avatarBottom &&
            avatarBottom <= floorTop + velocityY * 0.05) {
          position.y = floorTop - size.y;
          isInAir = false; // Mark as grounded
          jumpCount = 0; // Reset jump count when landing
        }
      }
      // print(
      // 'checking for left colission now ($avatarLeft, ${floorRight - (velocityX) * .3})');

      // check if avatar collides beside the other component
      if (other.isFloor && position.y != floorTop - size.y) {
        final allowance = (velocityX) * .1;
        if (avatarRight >= floorLeft && avatarRight <= floorLeft + allowance) {
          if (!leftFlag) {
            leftFlag = !leftFlag;
          }
          position.x = floorLeft - size.x;
        } else if (avatarLeft <= floorRight &&
            avatarLeft >= floorRight + allowance) {
          if (leftFlag) {
            leftFlag = !leftFlag;
          }
          position.x = floorRight;
        }

        // check if avatar collides below the floor
        else if (other.isFloor &&
            avatarTop <= floorBottom &&
            avatarTop >= floorBottom + velocityY * .2 &&
            velocityY < 0) {
          print('hitting roof!');
          velocityY = -velocityY;
        }
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    // surely hovering on air, duh
    isInAir = true;
  }

  // Update the avatar's position based on velocities
  void updatePosition(double dt) {
    position.x += velocityX * dt;
    position.y += velocityY * dt; // Debugging print
  }
}
