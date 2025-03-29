import 'dart:async' as async;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart' as flameTiled;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genequest_app/screens/game_screen.dart';
import 'package:genequest_app/screens/level_selector_screen.dart';

// ------------------- GAME LOGIC -------------------

class GenequestGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  static GenequestGame? instance; // Singleton for UI interaction
  final int levelNum;
  late Avatar avatar;
  late Goal goal;
  final double containerHeight;
  late BuildContext context;
  late Vector2 mapSize;
  bool isPaused = false;
  Vector2 spawnPosition = Vector2.zero();
  Vector2 goalPosition = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  ValueNotifier<int> healthNotifier = ValueNotifier(6);
  late flameTiled.TiledComponent levelMap;

  GenequestGame(
      {required this.containerHeight,
      required this.context,
      required this.levelNum}) {
    instance = this;
    context = context;
    levelNum = levelNum;
  }

  @override
  bool get debugMode => true;

  @override
  Color backgroundColor() => const Color(0xFFCCCCCC); // Light gray background

  @override
  Future<void> onLoad() async {
    await Flame.images.loadAll([
      'chromatid.png',
      'sister_chromatid.png',
      'platform_1.png',
      'button_forward.png',
      'heart_full.png',
      'heart_half.png',
      'heart_empty.png',
    ]);
    overlays.add('HealthBar');

    // Load the level
    levelMap = await flameTiled.TiledComponent.load(
      levelName,
      Vector2.all(64),
    );

    final spawnPointLayer =
        levelMap.tileMap.getLayer<flameTiled.ObjectGroup>('SpawnPoint');

    // Create the avatar and set its spawn point dynamically
    final chromatidSprite = Sprite(Flame.images.fromCache('chromatid.png'));
    final sisterChromatid =
        Sprite(Flame.images.fromCache('sister_chromatid.png'));
    avatar =
        Avatar(sprite: chromatidSprite, context: context, levelName: levelName);
    goal = Goal(sprite: sisterChromatid, context: context);

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
              isFloor: true, // This is a floor, not a wall
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
        level.tileMap.getLayer<flameTiled.ObjectGroup>('Floor');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.name) {
          case 'Floor':
            final floor = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isFloor: true, // This is a floor, not a wall
                isEnemy: false,
                isFinish: false)
              ..priority = 1;
            collisionBlocks.add(floor);
            add(floor);
          case 'Enemy':
            final enemy = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isFloor: false, // This is a floor, not a wall
                isEnemy: true,
                isFinish: false)
              ..priority = 1;
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

    mapSize = level.size;

    // Calculate the spawn point based on the map height (ground level)
    avatar.position = spawnPosition;
    goal.position = goalPosition;

    // Add the avatar to the world
    world.add(avatar);
    world.add(goal);

    // Create the camera
    final camera = CameraComponent.withFixedResolution(
      width: screenWidth * 1.5,
      height: screenHeight * 1.5,
      world: world,
    );

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
      // play jump sound
      FlameAudio.play('jump.wav');
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
    if (avatar.position.y > 1400) {
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

class Goal extends SpriteComponent with CollisionCallbacks {
  final BuildContext context;
  Goal({required Sprite sprite, required this.context})
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
}

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  bool isFloor;
  bool isEnemy;
  bool isFinish;

  CollisionBlock(
      {required Vector2 position,
      required Vector2 size,
      required this.isFloor,
      required this.isEnemy,
      required this.isFinish})
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
  String levelName;

  final effect = RotateEffect.by(
    tau, // Rotate a full circle (2π radians)
    InfiniteEffectController(EffectController(duration: 2)), // Loops forever
  );

  Avatar(
      {required Sprite sprite, required this.context, required this.levelName})
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
          FlameAudio.play('oof.mp3');
          // Blink for 1 second (5 cycles)
          timer.cancel(); // Stop blinking
          isImmune = false; // End immunity
          paint.color = const Color(0xFFFFFFFF); // Restore full opacity
        } else {
          // Alternate opacity between semi-transparent and fully transparent
          paint.color = paint.color.a == 0.0
              ? const Color(0x88FFFFFF) // Semi-transparent
              : const Color(0x00FFFFFF); // Fully transparent
          blinkCount++;
        }
      });
    } else {
      // replace with GAME OVER SCREEN
      if (!isDialogShowing) {
        isDialogShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return PauseMenu(
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
        FlameAudio.play('tada.mp3');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LevelSelectorScreen()),
        );
      } else if ((other.isFloor || other.isEnemy) && velocityY > 0) {
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
      if (other.isFloor &&
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
