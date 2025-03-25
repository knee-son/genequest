import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:flame_tiled/flame_tiled.dart' as flameTiled;
import 'dart:async' as async;

import 'package:genequest_app/screens/title_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.images.loadAll([
    'chromatid.png',
    'platform_1.png',
    'button_forward.png',
    'heart_full.png',
    'heart_half.png',
    'heart_empty.png',
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

  // HealthBar widget dynamically linked with healthNotifier
  Widget healthBar(BuildContext context) {
    final gameInstance = GenequestGame.instance;
    if (gameInstance == null) {
      return const SizedBox(); // Return an empty widget if the game is not initialized
    }
    return ValueListenableBuilder<int>(
      valueListenable: gameInstance.healthNotifier,
      builder: (context, health, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            int heartHealth = health - (index * 2);
            String asset;
            if (heartHealth >= 2) {
              asset = 'assets/images/heart_full.png'; // Full heart
            } else if (heartHealth == 1) {
              asset = 'assets/images/heart_half.png'; // Half heart
            } else {
              asset = 'assets/images/heart_empty.png'; // Empty heart
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Image.asset(asset, width: 40, height: 40),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double containerHeight = MediaQuery.of(context).size.height * 0.2;

    return Scaffold(
      body: Stack(
        children: [
          // Game canvas
          LayoutBuilder(
            builder: (context, constraints) {
              return GameWidget(
                game: GenequestGame(
                    containerHeight: containerHeight, context: context),
                overlayBuilderMap: {
                  'HealthBar': (_, game) => Align(
                        alignment: Alignment
                            .topRight, // Move health bar to the upper right
                        child: Padding(
                          padding: const EdgeInsets.all(
                              10), // Add spacing for aesthetics
                          child: healthBar(context),
                        ),
                      ),
                },
              );
            },
          ),

          // Bottom menu for movement buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left movement buttons (Back, Forward)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTapDown: (details) {
                            GenequestGame.instance?.startMovingAvatarBack();
                          },
                          onTapUp: (details) {
                            GenequestGame.instance?.stopMovingAvatar();
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.14159),
                            child: Image.asset(
                              'assets/images/button_forward.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTapDown: (details) {
                            GenequestGame.instance?.startMovingAvatar();
                          },
                          onTapUp: (details) {
                            GenequestGame.instance?.stopMovingAvatar();
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

                  // Right movement button (Jump)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTapDown: (details) {
                        GenequestGame.instance?.startJump();
                      },
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationZ(-1.5708),
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

          // Left-center alignment for Start and Reset buttons
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Start button logic
                      debugPrint('Start button pressed');
                    },
                    child: Image.asset(
                      'assets/images/button_start.png',
                      width: 100,
                      height: 50,
                    ),
                  ),
                  const SizedBox(height: 10), // Space between buttons
                  GestureDetector(
                    onTap: () {
                      GenequestGame.instance?.reset(); // Reset game logic
                    },
                    child: Image.asset(
                      'assets/images/button_reset.png',
                      width: 100,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top-left alignment for Menu and Pause buttons
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Menu button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/images/button_menu.png',
                      width: 100,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Pause button
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return PauseMenu(); // Pause menu dialog
                        },
                      );
                    },
                    child: Image.asset(
                      'assets/images/button_pause.png',
                      width: 50,
                      height: 50,
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
  late BuildContext context;
  late Vector2 mapSize;
  bool isPaused = false;
  Vector2 spawnPosition = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  ValueNotifier<int> healthNotifier = ValueNotifier(6);

  GenequestGame({required this.containerHeight, required this.context}) {
    instance = this;
    context = context;
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
      'heart_full.png',
      'heart_half.png',
      'heart_empty.png',
    ]);
    overlays.add('HealthBar');
    // Load the level
    final level = await flameTiled.TiledComponent.load(
      'Level.tmx',
      Vector2.all(64),
    );

    final spawnPointLayer =
        level.tileMap.getLayer<flameTiled.ObjectGroup>('SpawnPoint');

    // Create the avatar and set its spawn point dynamically
    final chromatidSprite = Sprite(Flame.images.fromCache('chromatid.png'));
    avatar = Avatar(sprite: chromatidSprite, context: context);

    spawnPosition = Vector2.zero(); // Default spawn position (fallback)

    // Find the spawn object in the SpawnPoint layer
    if (spawnPointLayer != null) {
      for (final spawn in spawnPointLayer.objects) {
        if (spawn.name == 'Spawn') {
          spawnPosition = Vector2(spawn.x, spawn.y);
          spawnPosition.y -= avatar.size.y; // Adjust to align avatar

          final floor = CollisionBlock(
              position: Vector2(spawn.x, spawn.y),
              size: Vector2(spawn.width, spawn.height),
              isFloor: true, // This is a floor, not a wall
              isEnemy: false)
            ..priority = 1; // Render above the map;
          collisionBlocks.add(floor);
          Future.delayed(Duration.zero, () {
            add(floor);
          });
          add(floor);
          collisionBlocks.add(floor);
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
                isEnemy: false)
              ..priority = 1;
            ;
            collisionBlocks.add(floor);
            add(floor);
          case 'Enemy':
            final enemy = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isFloor: false, // This is a floor, not a wall
                isEnemy: true)
              ..priority = 1;
            ;
            collisionBlocks.add(enemy);
            add(enemy);
          default:
            // Handle other cases if needed
            break;
        }
      }
    }

    // Initialize the world
    final world = World();

    // Add collision blocks first to ensure they render above the tilemap
    for (final block in collisionBlocks) {
      world.add(block);
    }

    // Add the level (tilemap) after collision blocks
    world.add(level);

    add(world);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Create the camera
    final camera = CameraComponent.withFixedResolution(
      width: screenWidth,
      height: screenHeight,
      world: world,
    );

    mapSize = level.size;

    // Calculate the spawn point based on the map height (ground level)
    avatar.position = spawnPosition;

    // Add the avatar to the world
    world.add(avatar);

    // Make the camera follow the avatar
    camera.follow(avatar);

    // Add keyboard listener
    add(KeyboardListenerComponent());

    // Add the camera to the game
    add(camera);
  }

  void updateHealth(int newHealth) {
    healthNotifier.value = newHealth;
  }

  void pause() {
    isPaused = true;
  }

  void resume() {
    isPaused = false;
  }

  void startJump() {
    if (avatar.jumpCount < 2) {
      avatar.velocityY = -300; // Upward velocity
      avatar.isInAir = true; // Set mid-air state
      avatar.jumpCount += 1;
    }
  }

  void startMovingAvatar() {
    avatar.horizontalMoveAxis = 1;
    avatar.velocityX = 300; // Move right
  }

  void startMovingAvatarBack() {
    avatar.horizontalMoveAxis = -1;
    avatar.velocityX = -300; // Move left
  }

  void stopMovingAvatar() {
    avatar.horizontalMoveAxis = 0;
    avatar.velocityX = 0; // Stop movement
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
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
      avatar.applyGravity(dt);
      avatar.updatePosition(dt);
    }
    // avatar.isInAir = true;
  }

  void reset() {
    avatar.position = spawnPosition;
    avatar.velocityX = 0; // Stop horizontal movement
    avatar.velocityY = 0; // Stop vertical movement
    avatar.isInAir = false; // Ensure avatar is grounded
    avatar.jumpCount = 0; // Reset jump count
    avatar.health = 6;
    GenequestGame.instance?.updateHealth(avatar.health);
    // If you have additional game state variables (e.g., score, level), reset them here
  }
}

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  bool isFloor;
  bool isEnemy;

  CollisionBlock(
      {required Vector2 position,
      required Vector2 size,
      required this.isFloor,
      required this.isEnemy})
      : super(position: position, size: size);

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
  int health = 6;
  bool isImmune = false; // Tracks whether the player is immune to damage
  final BuildContext context;
  int horizontalMoveAxis = 0;

  bool leftFlag = true;

  Avatar({required Sprite sprite, required this.context})
      : super(
          sprite: sprite,
          size: Vector2(60, 100), // Avatar size
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

    void applyDamageWithImmunity() {
      if (health - 1 > 0 && !isImmune) {
        health -= 1; // Reduce health
        GenequestGame.instance?.updateHealth(health); // Update health bar
        isImmune = true; // Grant immunity
        paint.color = const Color(
            0x88FFFFFF); // Make avatar semi-transparent (~50% opacity)

        // Start blinking effect
        int blinkCount = 0;
        async.Timer.periodic(const Duration(milliseconds: 200), (timer) {
          // Toggle visibility or opacity every 200ms
          if (blinkCount >= 5) {
            // Blink for 1 second (5 cycles)
            timer.cancel(); // Stop blinking
            isImmune = false; // End immunity
            paint.color = const Color(0xFFFFFFFF); // Restore full opacity
          } else {
            // Alternate opacity between semi-transparent and fully transparent
            paint.color = paint.color.opacity == 0.0
                ? const Color(0x88FFFFFF) // Semi-transparent
                : const Color(0x00FFFFFF); // Fully transparent
            blinkCount++;
          }
        });
      } else {
        // replace with game over screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TitleScreen()), // Replace with your title screen widget
        );
      }
    }

    if (other is CollisionBlock) {
      // Check if avatar is landed on top of the floor
      if ((other.isFloor || other.isEnemy) && velocityY > 0) {
        jumpCount = 0; // Reset jump count when landing
        if (other.isEnemy && !isImmune) {
          applyDamageWithImmunity(); // Handle damage and grant immunity
        }
        if (floorTop <= avatarBottom &&
            avatarBottom <= floorTop + velocityY * 0.05) {
          position.y = floorTop - size.y; // Align avatar to floor
          isInAir = false; // Mark as grounded
          jumpCount = 0; // Reset jump count
        }
      } else if (velocityY == 0) {
        if (other.isEnemy && !isImmune) {
          applyDamageWithImmunity(); // Handle damage and grant immunity
        }
      }
      // Horizontal collisions
      if ((other.isFloor || other.isEnemy) && position.y != floorTop - size.y) {
        final allowance = (velocityX) * 0.1;
        if (avatarRight >= floorLeft && avatarRight <= floorLeft + allowance) {
          if (!leftFlag) leftFlag = !leftFlag;
          position.x = floorLeft - size.x;
        } else if (floorRight >= avatarLeft &&
            avatarLeft >= floorRight + allowance) {
          if (leftFlag) leftFlag = !leftFlag;
          position.x = floorRight;
        }

        if (other.isEnemy && !isImmune) {
          applyDamageWithImmunity(); // Handle damage and grant immunity
        }
      }

      // Check if avatar collides below the floor
      if (other.isFloor &&
          avatarTop <= floorBottom &&
          avatarTop >= floorBottom + velocityY * 0.2 &&
          velocityY < 0) {
        velocityY = -velocityY; // Reverse vertical velocity
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
