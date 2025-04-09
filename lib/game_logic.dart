import 'dart:async' as async;

import 'package:flame/camera.dart' as flame_camera;
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_tiled/flame_tiled.dart' as flameTiled;
import 'package:flutter/foundation.dart';

// Other imports
import 'package:flutter/material.dart';
import 'package:genequest_app/globals.dart';
import 'package:genequest_app/screens/game_screen.dart';
import 'package:genequest_app/screens/level_selector_screen.dart';
import 'package:genequest_app/screens/minigame_screen.dart';
import 'package:google_fonts/google_fonts.dart';

// // ----------------- HOMEBREW WORLD -----------------
// class WorldWithCamera extends Forge2DWorld implements CoordinateTransform {
//     @override
//   void renderTree(Canvas canvas) {}

//   // Optional: support for rendering from camera
//   @override
//   void renderFromCamera(Canvas canvas) {
//     super.renderTree(canvas); // or customize this if needed
//   }

//   @override
//   bool containsLocalPoint(Vector2 point) => true;

//   @override
//   Vector2? localToParent(Vector2 point) => point;

//   @override
//   Vector2? parentToLocal(Vector2 point) => point;
// }

// ------------------- GAME LOGIC -------------------

// CoordinateTransform helps with camera movement
class GenequestGame extends Forge2DGame with KeyboardEvents {
  static GenequestGame? instance; // Singleton for UI interaction
  int levelNum;
  String? levelName;
  final double timeScale = 1.0;
  final double g = 10.0;
  bool isPaused = false;
  Vector2 spawnPosition = Vector2.zero();
  Vector2 goalPosition = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  ValueNotifier<int> healthNotifier = ValueNotifier(6);

  late final Avatar avatar;
  // late Goal goal;
  late BuildContext context;
  late double chasmHeight;
  late flameTiled.TiledComponent levelMap;
  late double screenWidth;
  late double screenHeight;

  // Constructor
  GenequestGame({
    required this.context,
    required this.levelNum,
    this.levelName,
  }) : super(
          gravity: Vector2(0, 20.0),
        ); // Pass gravity to the super class

  @override
  bool get debugMode => kDebugMode; // depends if flutter is in debug

  @override
  Color backgroundColor() => const Color(0xFF2185d5); // Light gray background

  @override
  Future<void> onLoad() async {
    super.onLoad();

    add(FpsTextComponent(
      anchor: Anchor.topRight,
      position: Vector2(size.x - 10, 10),
      textRenderer: TextPaint(
        style: GoogleFonts.robotoMono(
          color: const Color.fromARGB(159, 0, 0, 0),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    await Flame.images.loadAll([
      'chromatid2.png',
      'sister_chromatid.png',
      'mob.png',
    ]);

    await FlameAudio.audioCache.load('jump.wav');
    await FlameAudio.audioCache.load('oof.mp3');

    overlays.add('HealthBar');

    // Load the Tiled map (handles rendering of the map)
    levelMap = await flameTiled.TiledComponent.load(
      levelName?.isNotEmpty == true
          ? levelName!
          : gameState.getLevelName(levelNum),
      Vector2.all(64), // Tile size
    );
    world.add(levelMap);

    final spawnPointLayer =
        levelMap.tileMap.getLayer<flameTiled.ObjectGroup>('SpawnPoint');
    final collisionsLayer =
        levelMap.tileMap.getLayer<flameTiled.ObjectGroup>('Floor');

    if (collisionsLayer != null) {
      // Iterate through each object in the 'Floor' layer and create CollisionBlocks
      for (var object in collisionsLayer.objects) {
        var collisionBlock = CollisionBlock(
          position: Vector2(object.x, object.y),
          size: Vector2(object.width, object.height),
        );
        add(collisionBlock);
        // world.add(collisionBlock);
      }
    }

    if (spawnPointLayer != null) {
      for (final spawn in spawnPointLayer.objects) {
        if (spawn.name == 'Spawn') {
          avatar = Avatar(spawnPoint: spawn.position);
          // await world.add(avatar); // await to load body
          await add(avatar); // await to load body
        }
        // // spawn sister chromatid
        // else if (spawn.name == 'Finish') {
        //   goalPosition = Vector2(spawn.x, spawn.y);
        //   goalPosition.y -= goal.size.y; // Adjust to align avatar

        //   final floor = CollisionBlock(
        //       position: Vector2(spawn.x, spawn.y),
        //       size: Vector2(spawn.width, spawn.height),)
        //     ..priority = 1; // Render above the map;
        //   collisionBlocks.add(floor);
        //   Future.delayed(Duration.zero, () {
        //     add(floor);
        //   });
        //   add(floor);
        //   collisionBlocks.add(floor);
        //   break;
        // }
      }
    }

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    add(KeyboardListenerComponent());

    camera = flame_camera.CameraComponent.withFixedResolution(
        width: screenWidth * 1.2,
        height: screenHeight * 1.2,
        world: world,
        viewfinder: flame_camera.Viewfinder()..position = avatar.body.position);
    camera.viewport.size = Vector2(screenWidth, screenHeight);

    // workaround for camera

    // final cameraWorld = flame_camera.World();
    // await add(cameraWorld);
    // await add (avatar);
    world.add(avatar);
    world.add(levelMap);
    // camera.world = cameraWorld;
    camera.follow(avatar);
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

        // if (goal.size == goal.regularSize) {
        //   newTrait.selectedTrait = nonDominantTrait;
        // } else {
        //   newTrait.selectedTrait = dominantTrait;
        // }

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
      Flame.images.clear('chromatid2.png');
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
    avatar.jump();

    // if (avatar.jumpCount < 2) {
    //   avatar.velocityY = -300; // Upward velocity
    //   avatar.isInAir = true; // Set mid-air state
    //   // play jump sound
    //   FlameAudio.play('jump.wav');
    //   avatar.jumpCount += 1;
    // }
  }

  // void startMovingAvatar() {
  //   avatar.horizontalMoveAxis = 1;
  //   avatar.velocityX = 300; // Move right
  //   camera.follow(avatar);
  // }

  // void startMovingAvatarBack() {
  //   avatar.horizontalMoveAxis = -1;
  //   avatar.velocityX = -300; // Move left
  // }

  // void stopMovingAvatar() {
  //   avatar.horizontalMoveAxis = 0;
  //   avatar.velocityX = 0; // Stop movement
  // }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        avatar.jump();
      }
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        avatar.movingBackward = true;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        avatar.movingForward = true;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        avatar.movingBackward = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        avatar.movingForward = false;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    if (!isPaused) {
      super.update(dt * timeScale);
      // print(avatar.body.position);
      // camera.viewfinder.position = avatar.position;
      // print(camera.backdrop);
      // print(camera.viewport.size);
      // print(camera.viewfinder);
      // print(avatar.position);
    }
  }

  void avatarFallsOffChasm() {
    avatar.resetPosition();
    // avatar.applyDamageWithImmunity();
  }

  void reset() {
    avatar.resetPosition();

    // avatar.velocityX = 0; // Stop horizontal movement
    // avatar.velocityY = 0; // Stop vertical movement
    // avatar.isInAir = false; // Ensure avatar is grounded
    // avatar.jumpCount = 0; // Reset jump count
    // avatar.health = 6;
    // GenequestGame.instance?.updateHealth(avatar.health);
    // If you have additional game state variables (e.g., score, level), reset them here
  }
}

// ------------------- GOAL LOGIC -------------------

// class Goal extends SpriteComponent with CollisionCallbacks {
//   final BuildContext context;
//   final Vector2 regularSize = Vector2(60, 100);
//   final Vector2 halfSize = Vector2(60, 100) / 2;
//
//   Goal({required Sprite sprite, required this.context})
//       : super(
//           sprite: sprite,
//           size: Vector2(60, 100), // Avatar size
//           position: Vector2(200, 300), // Starting position above the border
//         );
//
//   @override
//   Future<void> onLoad() async {
//     super.onLoad();
//
//     await FlameAudio.audioCache.load('jump.wav');
//     await FlameAudio.audioCache.load('oof.mp3');
//
//     add(RectangleHitbox());
//
//     if (gameState.currentLevel == 0) {
//       async.Timer.periodic(const Duration(seconds: 1), (timer) {
//         if (size == regularSize) {
//           resize(halfSize);
//         } else {
//           resize(regularSize);
//         }
//       });
//     }
//   }
//
//   void resize(Vector2 newSize) {
//     size = newSize;
//   }
// }

// ----------------- COLLISION BLOCKS -----------------

class CollisionBlock extends BodyComponent {
  final Vector2 position;
  final Vector2 size;

  CollisionBlock({
    required this.position,
    required this.size,
  });

  @override
  Body createBody() {
    paint = Paint()..color = Colors.transparent;
    // paint = Paint()..color = const Color.fromARGB(0, 255, 255, 255);

    final shape = PolygonShape();
    shape.setAsBox(size.x / 2, size.y / 2, Vector2(size.x / 2, size.y / 2), 0);

    final bodyDef = BodyDef()
      ..position = position
      ..type = BodyType.static;

    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.5;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

// ------------------- AVATAR LOGIC -------------------

class Avatar extends BodyComponent {
  Vector2 spawnPoint;
  late Vector2 size;
  late Sprite sprite;
  late final double jumpStrength;
  bool movingForward = false;
  bool movingBackward = false;
  int impulseFramesRemaining = 0;

  Avatar({required this.spawnPoint});

  @override
  bool get debugMode => true;

  @override
  Body createBody() {
    paint = Paint()..color = Colors.transparent;
    // paint = Paint()..color = const Color.fromARGB(255, 255, 255, 255);

    sprite = Sprite(Flame.images.fromCache('chromatid2.png'));

    size = sprite.srcSize;

    add(SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.center,
    ));

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(spawnPoint.x, spawnPoint.y - size.y * 2)
      ..linearDamping = 1.2
      ..gravityScale = Vector2(0, 10);

    final body = world.createBody(bodyDef);

    final shape = PolygonShape();
    shape.setAsBox(size.x / 2, size.y / 2, Vector2.all(0), 0);

    jumpStrength = -3.0 * (size.y);

    final fixtureDef = FixtureDef(shape)
      ..density = 0.01
      ..friction = 0.0;

    body.createFixture(fixtureDef);

    return body;
  }

  // Method to update the position
  void setPosition(Vector2 newPosition) {
    body.position.setFrom(newPosition - size);
  }

  void resetPosition() {
    body.position.setFrom(Vector2(spawnPoint.x, spawnPoint.y - size.y * 2));
  }

  @override
  void update(double dt) {
    super.update(dt);

    double yVelocity = body.linearVelocity.y;

    if (movingForward) {
      body.linearVelocity = Vector2(100, yVelocity);
    }
    if (movingBackward) {
      body.linearVelocity = Vector2(-100, yVelocity);
    }

    if (impulseFramesRemaining > 0) {
      body.applyLinearImpulse(Vector2(0, jumpStrength),
          point: body.worldCenter);
      impulseFramesRemaining--;
    }
  }

  void jump() {
    double xVelocity = body.linearVelocity.x;
    double yVelocity = body.linearVelocity.y;
    body.linearVelocity = Vector2(xVelocity, yVelocity + jumpStrength);
  }

  void applyUpwardImpulse() {
    body.applyLinearImpulse(Vector2(0, jumpStrength), point: body.worldCenter);
  }

  // void moveLeft() {
  //   print('Velocity before: ${body.linearVelocity}');
  //   body.applyForce(Vector2(-walkStrength, 0), point: body.worldCenter);
  //   print('Velocity after: ${body.linearVelocity}');
  // }

  // void moveRight() {
  //   print('Velocity before: ${body.linearVelocity}');
  //   body.applyForce(Vector2(walkStrength, 0), point: body.worldCenter);
  //   print('Velocity after: ${body.linearVelocity}');
  // }
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
                  // Transform.scale(
                  //   scale: _zoomAnimation.value,
                  //   child: Transform.translate(
                  //     offset: Offset(
                  //       (0.5 - _zoomAnimation.value) * _shakeAnimation.value,
                  //       (0.5 - _zoomAnimation.value) * _shakeAnimation.value,
                  //     ),
                  //     child: child,
                  //   ),
                  // ),

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
