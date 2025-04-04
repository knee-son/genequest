import 'dart:async' as async;

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

// ------------------- GAME LOGIC -------------------

class GenequestGame extends Forge2DGame with KeyboardEvents {
  static GenequestGame? instance; // Singleton for UI interaction
  int levelNum;
  String? levelName;
  late Avatar avatar;
  // late Goal goal;
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

  // Constructor
  GenequestGame({
    required this.containerHeight,
    required this.context,
    required this.levelNum,
    this.levelName,
  }) : super(gravity: Vector2(0, 10)); // Pass gravity to the super class

  @override
  bool get debugMode => kDebugMode; // depends if flutter is in debug

  @override
  Color backgroundColor() => const Color(0xFF2185d5); // Light gray background

  @override
  Future<void> onLoad() async {
    super.onLoad();

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
    add(levelMap);

    // // Initialize physics world and objects (collision blocks, avatar)
    // physicsWorld = forge2d.World(Vector2(0, -10)); // Gravity
    // add(physicsWorld as flame.World);

    // final collisionsLayer =
    //     levelMap.tileMap.getLayer<flameTiled.ObjectGroup>('Floor');

    // if (collisionsLayer != null) {
    //   // Iterate through each object in the 'Floor' layer and create CollisionBlocks
    //   for (var object in collisionsLayer.objects) {
    //     var collisionBlock = CollisionBlock(
    //       position: Vector2(object.x, object.y),
    //       size: Vector2(object.width, object.height),
    //     );
    //     collisionBlock.initialize(physicsWorld);
    //     add(collisionBlock);
    //   }
    // }

    // Add the Avatar
    avatar = Avatar(size: Vector2(100, 100), position: Vector2(100, 100));
    // avatar.initialize(physicsWorld);
    add(avatar); // Add the avatar as a component

    // // final spawnPointLayer =
    // //     levelMap.tileMap.getLayer<flameTiled.ObjectGroup>('SpawnPoint');

    // // // Create the avatar and set its spawn point dynamically
    // // final chromatidSprite = Sprite(Flame.images.fromCache('chromatid2.png'));
    // // final sisterChromatid =
    // //     Sprite(Flame.images.fromCache('sister_chromatid.png'));
    // // // avatar =
    // // //     Avatar(sprite: chromatidSprite, context: context, levelNum: levelNum);
    // // goal = Goal(sprite: sisterChromatid, context: context);

    // // Calculate the spawn point based on the map height (ground level)
    // // avatar.position = spawnPosition;
    // // goal.position = goalPosition;

    // // Add the avatar to the world
    // // add(avatar);
    // // add(goal);

    // // How far from chasm damage. adjust to prevent camera off bounds
    // int chasmPadding = 1;
    // chasmHeight = levelMap.size.y - chasmPadding * 64;

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
    // camera.moveTo(goalPosition, speed: 1000);
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

  // void startJump() {
  //   if (avatar.jumpCount < 2) {
  //     avatar.velocityY = -300; // Upward velocity
  //     avatar.isInAir = true; // Set mid-air state
  //     // play jump sound
  //     FlameAudio.play('jump.wav');
  //     avatar.jumpCount += 1;
  //   }
  // }

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
    // if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space ||
    //     event.logicalKey == LogicalKeyboardKey.arrowUp) {
    //   startJump();
    // }

    // if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
    //     keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
    //   stopMovingAvatar();
    // } else {
    //   if (event is KeyDownEvent &&
    //       event.logicalKey == LogicalKeyboardKey.arrowLeft) {
    //     startMovingAvatarBack();
    //   } else if (event is KeyDownEvent &&
    //       event.logicalKey == LogicalKeyboardKey.arrowRight) {
    //     startMovingAvatar();
    //   }
    // }

    // if (event is KeyUpEvent &&
    //     event.logicalKey == LogicalKeyboardKey.arrowLeft) {
    //   stopMovingAvatar();
    // } else if (event is KeyUpEvent &&
    //     event.logicalKey == LogicalKeyboardKey.arrowRight) {
    //   stopMovingAvatar();
    // }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    if (!isPaused) {
      super.update(dt);
    }

    // world.stepDt(dt);
  }

  void avatarFallsOffChasm() {
    avatar.position = spawnPosition;
    // avatar.applyDamageWithImmunity();
  }

  void reset() {
    avatar.position = spawnPosition;
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

class CollisionBlock extends PositionComponent {
  // late forge2d.Body _body;

  // CollisionBlock({
  //   super.position,
  //   super.size,
  //   super.scale,
  //   super.angle,
  //   super.anchor,
  // });

  // void initialize(forge2d.World world) {
  //   var shape = forge2d.PolygonShape()
  //     ..setAsBox(width / 2, height / 2, position as forge2d.Vector2, 0);
  //   var bodyDef = forge2d.BodyDef()
  //     ..position = position as forge2d.Vector2
  //     ..type = forge2d.BodyType.static;

  //   _body = world.createBody(bodyDef);
  //   _body.createFixtureFromShape(shape);
  // }
}

// ------------------- AVATAR LOGIC -------------------

class Avatar extends BodyComponent {
  final Vector2 size;
  @override
  final Vector2 position;

  // Constructor to accept size and position parameters
  Avatar({
    required this.size,
    required this.position,
  });

  set position(Vector2 newPosition) {
    bodyDef?.position = newPosition;
  }

  @override
  Future<void> onLoad() async {
    // Create a polygon shape for the avatar using the provided size
    super.onLoad();
    final shape = PolygonShape();
    shape.setAsBox(size.x / 2, size.y / 2, position,
        0); // Define the size of the shape (half-width, half-height)

    // Define the fixture for the body (density, friction, restitution)
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.3
      ..restitution = 0.5;

    bodyDef?.type = BodyType.dynamic;
    bodyDef?.position = Vector2(100, 100);

    fixtureDefs?.add(fixtureDef);

    await super.onLoad();
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
