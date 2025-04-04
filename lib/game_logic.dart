import 'dart:async' as async;

import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart' as flameTiled;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genequest_app/globals.dart';
import 'package:genequest_app/screens/game_screen.dart';
import 'package:genequest_app/screens/level_selector_screen.dart';
import 'package:genequest_app/screens/minigame_screen.dart';
import 'package:flutter/foundation.dart';

// ------------------- GAME LOGIC -------------------

class GenequestGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  static GenequestGame? instance; // Singleton for UI interaction
  int levelNum;
  String? levelName;
  late Avatar avatar;
  late Goal goal;
  final double containerHeight;
  late BuildContext context;
  late double chasmHeight;
  bool isPaused = false;
  Vector2 spawnPosition = Vector2.zero();
  Vector2 goalPosition = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  ValueNotifier<int> healthNotifier = ValueNotifier(6);
  late flameTiled.TiledComponent levelMap;
  late double screenWidth;
  late double screenHeight;

  GenequestGame(
      {required this.containerHeight,
      required this.context,
      required this.levelNum,
      this.levelName}) {
    instance = this;
    // context = context;
    // levelNum = levelNum;
  }

  @override
  bool get debugMode => kDebugMode; // depends if flutter is in debug

  @override
  Color backgroundColor() => const Color(0xFF2185d5); // Light gray background

  @override
  Future<void> onLoad() async {
    await Flame.images.loadAll([
      'chromatid.png',
      'sister_chromatid.png',
      'mob.png',
    ]);
    overlays.add('HealthBar');

    // Load the level
    levelMap = await flameTiled.TiledComponent.load(
      levelName?.isNotEmpty == true
          ? levelName!
          : gameState.getLevelName(levelNum),
      Vector2.all(64),
    );

    final spawnPointLayer =
        levelMap.tileMap.getLayer<flameTiled.ObjectGroup>('SpawnPoint');

    // Create the avatar and set its spawn point dynamically
    final chromatidSprite = Sprite(Flame.images.fromCache('chromatid.png'));
    final sisterChromatid =
        Sprite(Flame.images.fromCache('sister_chromatid.png'));
    avatar =
        Avatar(sprite: chromatidSprite, context: context, levelNum: levelNum);
    goal = Goal(sprite: sisterChromatid, context: context);

    // Initialize the world
    final world = World();
    // Find the spawn object in the SpawnPoint layer
    if (spawnPointLayer != null) {
      for (final spawn in spawnPointLayer.objects) {
        if (spawn.name == 'Spawn') {
          spawnPosition = Vector2(spawn.x, spawn.y);
          spawnPosition.y -= avatar.size.y; // Adjust to align avatar
          final floor = CollisionBlock(
              position: Vector2(spawn.x, spawn.y),
              size: Vector2(spawn.width, spawn.height),
              isSolid: true, // This is a floor, not a wall
              isEnemy: false,
              isFinish: false)
            ..priority = 1; // Render above the map;
          collisionBlocks.add(floor);
          Future.delayed(Duration.zero, () {
            add(floor);
          });
          add(floor);
          collisionBlocks.add(floor);
        }
        // spawn sister chromatid
        else if (spawn.name == 'Finish') {
          goalPosition = Vector2(spawn.x, spawn.y);
          goalPosition.y -= goal.size.y; // Adjust to align avatar

          final floor = CollisionBlock(
              position: Vector2(spawn.x, spawn.y),
              size: Vector2(spawn.width, spawn.height),
              isSolid: false, // This is a floor, not a wall
              isEnemy: false,
              isFinish: true)
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
        levelMap.tileMap.getLayer<flameTiled.ObjectGroup>('Floor');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.name) {
          case 'Floor':
            final floor = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isSolid: true, // This is a floor, not a wall
                isEnemy: false,
                isFinish: false)
              ..priority = 1;
            collisionBlocks.add(floor);
            add(floor);

          case 'Enemy':
            // Load the mob.png sprite
            final mobSprite = Sprite(Flame.images.fromCache('mob.png'));

            // Create a new enemy instance
            final enemy = CollisionBlock(
              position: Vector2(collision.x, collision.y), // Enemy position
              size: Vector2(collision.width, collision.height), // Enemy size
              isSolid: false, // Not a solid block
              isEnemy: true, // Mark as enemy
              isFinish: false, // Not a finish block
            )..priority = 1; // Ensure enemy has higher rendering priority

            // Add the enemy to the collision blocks list
            collisionBlocks.add(enemy);

            // Add a mob image for every enemy
            final mobImage = SpriteComponent(
              sprite: mobSprite, // mob.png sprite
              size: Vector2(50, 50), // Adjust size as needed
              position: Vector2(
                  collision.x, collision.y), // Spawn on the enemy's position
            )..priority = 2; // Ensure mob is rendered above the enemy

            // Add the mob image to the game world
            mobImage.position = Vector2(enemy.x, enemy.y);
            world.add(mobImage);
          case 'Trap':
            final floor = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isSolid: true, // This is a floor, not a wall
                isEnemy: true,
                isFinish: false)
              ..priority = 1;
            collisionBlocks.add(floor);
            add(floor);
          default:
            break;
        }
      }
    }

    // Add collision blocks first to ensure they render above the tilemap
    for (final block in collisionBlocks) {
      world.add(block);
    }

    // Add the level (tilemap) after collision blocks
    world.add(levelMap);

    add(world);

    // How far from chasm damage. adjust to prevent camera off bounds
    int chasmPadding = 1;
    chasmHeight = levelMap.size.y - chasmPadding * 64;

    // Calculate the spawn point based on the map height (ground level)
    avatar.position = spawnPosition;
    goal.position = goalPosition;

    // Add the avatar to the world
    world.add(avatar);
    world.add(goal);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    // Create the camera
    camera = CameraComponent.withFixedResolution(
        width: screenWidth * 2,
        height: screenHeight * 2,
        world: world,
        viewfinder: Viewfinder()
          ..position = avatar.position // Define the starting position
        );
    // Assuming `camera` is already declared and added to the game

    add(KeyboardListenerComponent());

    // Add the camera to the game
    add(camera);
    camera.moveTo(goalPosition, speed: 1000);
  }

  void updateHealth(int newHealth) {
    healthNotifier.value = newHealth;
  }

  void pause() {
    isPaused = true;
  }

  void saveTrait() {
    if (gameState.currentLevel == 0) {
      // Ensure there are traits available before proceeding
      if (gameState.traits.isNotEmpty) {
        String dominantTrait =
            gameState.traits[gameState.currentLevel].defaultTrait;
        String nonDominantTrait =
            gameState.traits[gameState.currentLevel].traits.last;

        Trait newTrait = Trait(
            name: gameState.traits[gameState.currentLevel].name,
            traits: gameState.traits[gameState.currentLevel].traits,
            difficulty: gameState.traits[gameState.currentLevel].difficulty,
            selectedTrait: dominantTrait,
            level: gameState.traits[gameState.currentLevel].level);

        if (goal.size == goal.regularSize) {
          newTrait.selectedTrait = nonDominantTrait;
        } else {
          newTrait.selectedTrait = dominantTrait;
        }

        // Check for an existing trait where the level matches gameState.level
        var existingTraitIndex = gameState.savedTraits.indexWhere(
          (trait) => trait.level == gameState.currentLevel,
        );

        if (existingTraitIndex != -1) {
          // Update the existing trait instance if found and selectedTrait is not empty
          gameState.savedTraits[gameState.currentLevel] = newTrait;
        } else {
          gameState.savedTraits.add(newTrait);
        }
      }
      gameState.incrementLevel();
      Flame.images.clear('chromatid.png');
      Flame.images.clear('sister_chromatid.png');
      Flame.images.clear('mob.png');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LevelSelectorScreen()),
      );
      gameState.incrementLevel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LevelSelectorScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MiniGameScreenTransition(levelNum: gameState.currentLevel)),
      );
    }
  }

  void resume() {
    isPaused = false;
  }

  void startJump() {
    if (avatar.jumpCount < 2) {
      avatar.velocityY = -300; // Upward velocity
      avatar.isInAir = true; // Set mid-air state
      // play jump sound
      FlameAudio.play('jump.wav');
      avatar.jumpCount += 1;
    }
  }

  void startMovingAvatar() {
    avatar.horizontalMoveAxis = 1;
    avatar.velocityX = 300; // Move right
    camera.follow(avatar);
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
    if (!isPaused) {
      super.update(dt);
      dt = dt * 1.2;
      avatar.applyGravity(dt);
      avatar.updatePosition(dt);
    }
    if (avatar.position.y > chasmHeight) {
      avatarFallsOffChasm();
    }
  }

  void avatarFallsOffChasm() {
    avatar.position = spawnPosition;
    avatar.applyDamageWithImmunity();
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

// ------------------- GOAL LOGIC -------------------

class Goal extends SpriteComponent with CollisionCallbacks {
  final BuildContext context;
  final Vector2 regularSize = Vector2(60, 100);
  final Vector2 halfSize = Vector2(60, 100) / 2;

  Goal({required Sprite sprite, required this.context})
      : super(
          sprite: sprite,
          size: Vector2(60, 100), // Avatar size
          position: Vector2(200, 300), // Starting position above the border
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    await FlameAudio.audioCache.load('jump.wav');
    await FlameAudio.audioCache.load('oof.mp3');

    add(RectangleHitbox());

    if (gameState.currentLevel == 0) {
      async.Timer.periodic(const Duration(seconds: 1), (timer) {
        if (size == regularSize) {
          resize(halfSize);
        } else {
          resize(regularSize);
        }
      });
    }
  }

  void resize(Vector2 newSize) {
    size = newSize;
  }
}

// ----------------- COLLISION BLOCKS -----------------

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  final bool isSolid;
  final bool isEnemy;
  final bool isFinish;

  CollisionBlock({
    required Vector2 position,
    required Vector2 size,
    required this.isSolid,
    required this.isEnemy,
    required this.isFinish,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Hitbox for collision detection
    add(RectangleHitbox());

    return super.onLoad(); // Call at the end
  }
}

// ------------------- AVATAR LOGIC -------------------

class Avatar extends SpriteComponent
    with CollisionCallbacks, HasGameRef<GenequestGame> {
  double velocityX = 0; // Horizontal velocity
  double velocityY = 0; // Vertical velocity
  final double gravity = 300; // Downward acceleration
  bool isInAir = false; // Tracks whether the avatar is airborne
  int jumpCount = 0; // Tracks the number of jumps
  int health = 6;
  bool isImmune = false; // Tracks whether the player is immune to damage
  final BuildContext context;
  int horizontalMoveAxis = 0;
  int levelNum;

  Avatar(
      {required Sprite sprite, required this.context, required this.levelNum})
      : super(
          sprite: sprite,
          size: Vector2(60, 100), // Avatar size
          position: Vector2(200, 300), // Starting position above the border
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    return super.onLoad();
  }

  void applyGravity(double dt) {
    // Apply gravity only while airborne
    if (isInAir) {
      velocityY += gravity * dt; // Gravity pulls the avatar down
    } else {
      velocityY = 0;
    }
  }

  void applyDamageWithImmunity() {
    if (!isImmune) {
      health -= 1; // Reduce health
      GenequestGame.instance?.updateHealth(health); // Update health bar
      isImmune = true; // Grant immunity
      paint.color = const Color(
          0x88FFFFFF); // Make avatar semi-transparent (~50% opacity)
      // Start blinking effect
      int blinkCount = 0;
      async.Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (blinkCount >= 5) {
          timer.cancel(); // Stop blinking
          isImmune = false; // End immunity
          paint.color = const Color(0xFFFFFFFF); // Restore full opacity
        } else {
          // Play audio on each blink
          if (blinkCount == 0) {
            FlameAudio.play('oof.mp3');
          }
          // Alternate opacity between semi-transparent and fully transparent
          paint.color = paint.color.a == 0.0
              ? const Color(0x88FFFFFF) // Semi-transparent
              : const Color(0x00FFFFFF); // Fully transparent
          blinkCount++;
        }
      });
    }

    if (health <= 0) {
      // Game Over logic

      gameState.setLevel(levelNum - 1);
      // pause();
      gameRef.pause();

      if (!isDialogShowing) {
        isDialogShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return DialogOverlayModal(
                title: "Game Over", action: "Gameover"); // Pause menu dialog
          },
        );
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

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
      if (other.isFinish) {
        gameRef.pause();
        gameRef.saveTrait();
      } else if ((other.isSolid || other.isEnemy) && velocityY > 0) {
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
      if ((other.isSolid || other.isEnemy) && position.y != floorTop - size.y) {
        final allowance = (velocityX) * 0.1;
        if (avatarRight >= floorLeft && avatarRight <= floorLeft + allowance) {
          position.x = floorLeft - size.x;
        } else if (floorRight >= avatarLeft &&
            avatarLeft >= floorRight + allowance) {
          position.x = floorRight;
        }

        if (other.isEnemy && !isImmune) {
          applyDamageWithImmunity(); // Handle damage and grant immunity
        }
      }

      // Check if avatar collides below the floor
      if (other.isSolid &&
          avatarTop <= floorBottom &&
          avatarTop >= floorBottom + velocityY * 0.2 &&
          velocityY < 0) {
        velocityY = -velocityY; // Reverse vertical velocity
      }
    }
  }

  // [Unused] But may be useful for future reference
  // void navigateToTitleScreen(BuildContext context) {
  //   if (!isNavigatingToTitleScreen) {
  //     isNavigatingToTitleScreen = true;
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => TitleScreen(),
  //       ),
  //           (route) => false,
  //     );
  //   }
  // }

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

// ----------------- TRANSITION LOGIC -----------------

class MiniGameScreenTransition extends StatefulWidget {
  final int levelNum;

  const MiniGameScreenTransition({required this.levelNum, super.key});

  @override
  State<MiniGameScreenTransition> createState() =>
      _MiniGameScreenTransitionState();
}

class _MiniGameScreenTransitionState extends State<MiniGameScreenTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _whiteOutAnimation;

  @override
  void initState() {
    super.initState();

    // Play 'woosh.wav' as the animation starts
    FlameAudio.play('slash.wav');

    // Animation Controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Zoom-in effect
    _zoomAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Shake effect (oscillating position offset)
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // White-out effect
    _whiteOutAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Start animation
    _controller.forward().then((_) {
      // Play transition sound and navigate
      FlameAudio.play('tada.mp3');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MiniGameScreen(widget.levelNum)),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  // Zoom & Shake
                  Transform.scale(
                    scale: _zoomAnimation.value,
                    child: Transform.translate(
                      offset: Offset(
                        (0.5 - _zoomAnimation.value) * _shakeAnimation.value,
                        (0.5 - _zoomAnimation.value) * _shakeAnimation.value,
                      ),
                      child: child,
                    ),
                  ),

                  // White-Out Overlay
                  Opacity(
                    opacity: _whiteOutAnimation.value,
                    child: Container(color: Colors.white),
                  ),
                ],
              );
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(
                    16), // Adds some spacing around the text
                color: Colors.white, // White background
                child: const Text(
                  "Minigame Time!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Black text
                  ),
                  textAlign: TextAlign.center, // Ensures text is centered
                ),
              ),
            )),
      ),
    );
  }
}
