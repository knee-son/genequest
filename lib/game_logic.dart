import 'dart:async' as async;
import 'dart:math';

import 'package:flame/camera.dart' as flame_camera;
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
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

// ------------------- GAME LOGIC -------------------

class GenequestGame extends Forge2DGame
    with KeyboardEvents, HasCollisionDetection {
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
  late Goal goal;
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
          gravity: Vector2(0, 50.0),
          contactListener: MyCollisionListener(),
        ) {
    instance = this;
  }

  @override
  bool get debugMode => kDebugMode; // depends if flutter is in debug

  @override
  Color backgroundColor() => const Color(0xFF2185d5); // sky background

  @override
  Future<void> onLoad() async {
    super.onLoad();

    if (debugMode) {
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
    }

    await Flame.images.loadAll([
      'chromatid7.png',
      'sister_chromatid.png',
      'mob.png',
      'flame.png'
    ]);

    await FlameAudio.audioCache.load('jump.wav');
    await FlameAudio.audioCache.load('oof.mp3');

    overlays.add('HealthBar');

    // add levelMap to world, so it can be rendered by camera
    levelMap = await flameTiled.TiledComponent.load(
      levelName?.isNotEmpty == true
          ? levelName!
          : gameState.getLevelName(levelNum),
      Vector2.all(64 / 10), // Tile size
    );
    await world.add(levelMap);

    final spawnPointLayer =
        levelMap.tileMap.getLayer<flameTiled.ObjectGroup>('SpawnPoint');
    final collisionsLayer =
        levelMap.tileMap.getLayer<flameTiled.ObjectGroup>('Floor');

    if (collisionsLayer != null) {
      // a CollisionBlock may be a spike, chasm, lava, or plain floor
      for (flameTiled.TiledObject object in collisionsLayer.objects) {
        switch (object.name) {
          case 'Spike':
            await add(CollisionBlock(
              position: object.position,
              size: object.size,
              userData: 'spike',
            ));
            break;
          case 'Chasm':
            print('chasm!');
            await add(Chasm(
              position: object.position,
              size: object.size,
            ));
            break;
          default: // floor
            await add(object.polygon.isNotEmpty
                ? CollisionBlock(
                    position: object.position,
                    size: object.size,
                    polygon: object.polygon,
                  )
                : CollisionBlock(
                    position: object.position,
                    size: object.size,
                  ));
            break;
        }
      }
    }

    // spawn may be avatar, enemy, or the goal
    if (spawnPointLayer != null) {
      for (final spawn in spawnPointLayer.objects) {
        switch (spawn.name) {
          case 'Enemy':
            await world.add(Enemy(spawnPoint: spawn.position));
          case 'Fire':
            await world.add(Fire(spawnPoint: spawn.position));
          case 'Spawn':
            {
              avatar = Avatar(spawnPoint: spawn.position);
              await world.add(avatar);
            }
          case 'Finish':
            {
              goal = Goal(spawnPoint: spawn.position);
              await world.add(goal);
            }
        }
      }
    }

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    add(KeyboardListenerComponent());

    // too much fuckery with scaling. aiming to make it global
    camera = flame_camera.CameraComponent.withFixedResolution(
        width: screenWidth / 10 * 1.4,
        height: screenHeight / 10 * 1.4,
        world: world,
        viewfinder: flame_camera.Viewfinder()..position = avatar.body.position);
    // camera.viewport.size =
    //     Vector2(screenWidth / 10 * 1.4, screenWidth / 10 * 1.4);
    // camera.snap();

    world.add(avatar);
    camera.follow(avatar);
  }

  @override
  void render(Canvas canvas) {
    // Draw sky gradient first

    final rect = Rect.fromLTWH(0, 0, screenWidth, screenHeight);
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF87CEEB), // Light Sky Blue
        Color(0xFF4682B4), // Steel Blue
      ],
    );

    final paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);

    // Then let Forge2D render everything else on top
    super.render(canvas);
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        avatar.jump();
      }
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
    }
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

  void reset() {
    avatar.resetPosition();
    goal.resetPosition();

    avatar.health = 6;
  }

  void saveTrait() {
    pause();
    // not modified during forge2d migration
    if (gameState.currentLevel == 0) {
      // Ensure there are traits available before proceeding
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Trait Acquired'),
            content:
                Text('Congratulations, you are: ${newTrait.selectedTrait}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  gameState.incrementLevel();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LevelSelectorScreen()),
                  );
                  gameState.incrementLevel();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LevelSelectorScreen()),
                  );
                },
                child: const Text('Dismiss'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MiniGameScreenTransition(levelNum: gameState.currentLevel)),
      );
    }

    Flame.images.clear('chromatid.png');
    Flame.images.clear('sister_chromatid.png');
    Flame.images.clear('mob.png');
    Flame.images.clear('flame.png');
  }
}

/*
collision objects are now migrated to Forge2D's BodyComponent.
it has collision detection dictated by our ContactListener.
the avatar's movements are all in the Avatar object. tweak it to
your liking.

TODO:
- there's a case where the avatar is still colliding with a
damaging object so it should still be in a hurt state.
- implement a different BodyComponent for Chasm and Lava.
- Chasm should not collide with avatar but is a sensor.
- same goes for Lava but just implement infinite jumping to
the avatar. apply linear damping along with damage so the
avatar gets punished
- the sister chromatid should have an alternating state between
'male' and 'female in peaceful level
- maybe change the sky backdrop to a gradient?
- the animation is bugged and needs fixing
*/

// ---------------- COLLISION DETECTION ---------------

class MyCollisionListener extends ContactListener {
  @override
  void beginContact(Contact contact) {
    final userDataA = contact.fixtureA.userData;
    final userDataB = contact.fixtureB.userData;


    final worldManifold = WorldManifold();
    contact.getWorldManifold(worldManifold);

    // This is the normal vector at the point of contact
    final normalY = worldManifold.normal.y;

    // negative y means fixture A is contacting upwards
    // y at -1.0 means it's flat faced down. y at ~ -0.7 is facing around 45°

    if (userDataB == 'avatar' && normalY >= -1.0 && normalY <= -0.7) {
      debugPrint("jumps have been reset!");
      GenequestGame.instance?.avatar.resetJumps();
    }

    if (userDataA == 'chasm' && userDataB == 'avatar' ||
        userDataA == 'avatar' && userDataB == 'chasm') {
      GenequestGame.instance!.avatar.applyDamage();
      GenequestGame.instance!.avatar.resetPosition();
    }

    if ((userDataA == 'enemy' || userDataA == 'spike' || userDataA == 'fire') &&
            userDataB == 'avatar' ||
        userDataA == 'avatar' &&
            (userDataB == 'enemy' || userDataB == 'spike' || userDataB == 'fire')
    ) {
      GenequestGame.instance!.avatar.applyDamage();
    } else if (userDataA == 'goal' && userDataB == 'avatar' ||
        userDataA == 'avatar' && userDataB == 'goal') {
      GenequestGame.instance?.saveTrait();
    }
  }
}

// ----------------- COLLISION BLOCKS -----------------

class CollisionBlock extends BodyComponent {
  @override
  Vector2 position;
  Vector2 size;
  final List<flameTiled.Point>? polygon;
  final String? userData;

  CollisionBlock({
    required this.position,
    required this.size,
    this.polygon,
    this.userData,
  });

  @override
  Body createBody() {
    position /= 10;
    size /= 10;

    paint = Paint()..color = Colors.transparent;

    final shape = PolygonShape();
    if (polygon != null) {
      // Convert your polygon points to Vector2 if needed
      shape.set(_convertToVector2List(polygon!));
    } else {
      // Use default box shape
      shape.setAsBox(
          size.x / 2, size.y / 2, Vector2(size.x / 2, size.y / 2), 0);
    }

    final bodyDef = BodyDef()
      ..position = position
      ..type = BodyType.static;

    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.5;

    if (userData != null) {
      fixtureDef.userData = userData;
    }

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  List<Vector2> _convertToVector2List(List<flameTiled.Point> points) {
    return points
        .map((p) => Vector2(p.x.toDouble() / 10, p.y.toDouble() / 10))
        .toList();
  }
}

// ---------------- SPOOKY SCARY CHASM ----------------

class Chasm extends BodyComponent {
  @override
  Vector2 position;
  Vector2 size;

  Chasm({
    required this.position,
    required this.size,
  });

  @override
  Body createBody() {
    position /= 10;
    size /= 10;

    paint = Paint()..color = Colors.transparent;

    final shape = PolygonShape();
    // Use default box shape
    shape.setAsBox(size.x / 2, size.y / 2, Vector2(size.x / 2, size.y / 2), 0);

    final bodyDef = BodyDef()
      ..position = position
      ..type = BodyType.static;

    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.5
      ..userData = 'chasm'
      ..isSensor = true;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

// ------------------- GOAL LOGIC ---------------------

class Goal extends BodyComponent {
  Vector2 spawnPoint;
  late Vector2 size;
  late Sprite sprite;
  late SpriteComponent spriteComponent;
  late final Vector2 halfSize;
  late final Vector2 regularSize;

  Goal({required this.spawnPoint});

  @override
  Body createBody() {
    // remove default white paint
    paint = Paint()..color = Colors.transparent;

    sprite = Sprite(Flame.images.fromCache('sister_chromatid.png'));

    size = sprite.srcSize;

    spawnPoint = Vector2(spawnPoint.x, spawnPoint.y - size.y * 2);

    size /= 10;
    spawnPoint /= 10;

    regularSize = size;
    halfSize = size * 0.7;

    spriteComponent = SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.center,
    );
    add(spriteComponent);

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = spawnPoint
      ..linearDamping = 1.2;

    final body = world.createBody(bodyDef);

    final shape = PolygonShape();
    shape.setAsBox(size.x / 2, size.y / 2, Vector2.all(0), 0);

    final fixtureDef = FixtureDef(shape)
      ..friction = 0.1
      ..density = 0.005
      ..userData = 'goal';

    body.createFixture(fixtureDef);

    if (gameState.currentLevel == 0) {
      async.Timer.periodic(const Duration(seconds: 1), (timer) {
        if (size == regularSize) {
          _resize(halfSize);
        } else {
          _resize(regularSize);
        }
      });
    }

    return body;
  }

  void _resize(newSize) {
    size = newSize;
    spriteComponent.size = newSize;

    // Remove existing fixtures
    for (final fixture in List.from(body.fixtures)) {
      body.destroyFixture(fixture);
    }

    // Create new shape and fixture
    final shape = PolygonShape();
    shape.setAsBox(newSize.x / 2, newSize.y / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(shape)
      ..friction = 0.1
      ..density = 0.005
      ..userData = 'goal';

    body.createFixture(fixtureDef);
  }

  void resetPosition() {
    body.position.setFrom(spawnPoint);
  }
}

// ------------------- ENEMY LOGIC --------------------

class Enemy extends BodyComponent {
  Vector2 spawnPoint;
  late Vector2 size;
  late Sprite sprite;
  late SpriteComponent spriteComponent;

  final int _maxDistance = 50;
  final double _walkSpeed = 120;

  Enemy({required this.spawnPoint});

  @override
  Body createBody() {
    // remove default white paint
    paint = Paint()..color = Colors.transparent;

    sprite = Sprite(Flame.images.fromCache('mob.png'));
    size = sprite.srcSize;
    size /= 10;

    spriteComponent = SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.center,
    );

    spawnPoint = Vector2(spawnPoint.x, spawnPoint.y - size.y * 2);
    spawnPoint /= 10;

    add(spriteComponent);

    final bodyDef = BodyDef()
      ..type = BodyType.kinematic
      ..position = spawnPoint
      ..linearDamping = 1.2
      ..linearVelocity.x = _walkSpeed;

    final body = world.createBody(bodyDef);
    final shape = CircleShape();
    shape.radius = size.x / 2; // or use min(size.x, size.y) / 2 for non-square

    final fixtureDef = FixtureDef(shape)..userData = 'enemy';

    body.createFixture(fixtureDef);

    return body;
  }

  void resetPosition() {
    body.position.setFrom(spawnPoint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double originalPosition = spawnPoint.x;
    double currentPosition = body.position.x;

    if (currentPosition > originalPosition + _maxDistance ||
        currentPosition < originalPosition - 0.1) {
      body.linearVelocity.x = -body.linearVelocity.x;
      spriteComponent.flipHorizontally();
    }
  }
}

// ------------------- ENEMY LOGIC --------------------

class Fire extends BodyComponent {
  Vector2 spawnPoint;
  late Vector2 size;
  late Sprite sprite;
  late SpriteComponent spriteComponent;

  final int _maxDistance = 50;
  final double _walkSpeed = 120;

  Fire({required this.spawnPoint});

  @override
  Body createBody() {
    // remove default white paint
    paint = Paint()..color = Colors.transparent;

    sprite = Sprite(Flame.images.fromCache('flame.png'));
    size = sprite.srcSize;
    size /= 50;

    spriteComponent = SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.center,
    );

    spawnPoint = Vector2(spawnPoint.x, spawnPoint.y - size.y * 2);
    spawnPoint /= 10;

    add(spriteComponent);

    final bodyDef = BodyDef()
      ..type = BodyType.kinematic
      ..position = spawnPoint
      ..linearDamping = 1.2
      ..linearVelocity.y = _walkSpeed;

    final body = world.createBody(bodyDef);
    final shape = CircleShape();
    shape.radius = size.x / 2; // or use min(size.x, size.y) / 2 for non-square

    final fixtureDef = FixtureDef(shape)..userData = 'fire';

    body.createFixture(fixtureDef);

    return body;
  }

  void resetPosition() {
    body.position.setFrom(spawnPoint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double originalPosition = spawnPoint.y;
    double currentPosition = body.position.y;

    if (currentPosition > originalPosition + _maxDistance ||
        currentPosition < originalPosition - 0.1) {
      body.linearVelocity.y = -body.linearVelocity.y;
    }
  }
}

// ------------------- AVATAR LOGIC -------------------

class Avatar extends BodyComponent {
  Vector2 spawnPoint;
  late Vector2 size;
  late Sprite sprite;
  late SpriteComponent spriteComponent;
  late final double jumpSpeed;
  late final double walkSpeed;
  bool movingForward = false;
  bool movingBackward = false;
  bool isImmune = false;
  int health = 6;
  int jumpFuel = 0;
  int jumpsRemaining = 2;

  Avatar({required this.spawnPoint});

  @override
  Body createBody() {
    // remove default white paint
    paint = Paint()..color = Colors.transparent;

    sprite = Sprite(Flame.images.fromCache('chromatid7.png'));

    size = sprite.srcSize;
    size /= 10;

    spriteComponent = SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.center,
    );

    spawnPoint = Vector2(spawnPoint.x, spawnPoint.y - size.y * 2);
    spawnPoint /= 10;

    add(spriteComponent);

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = spawnPoint
      ..linearDamping = 1.2;

    final body = world.createBody(bodyDef);

    final shape = PolygonShape();
    shape.setAsBox(size.x / 2, size.y / 2, Vector2.all(0), 0);

    jumpSpeed = -1.0 * (size.y);
    walkSpeed = 15;

    final fixtureDef = FixtureDef(shape)
      ..friction = 0.1
      ..density = 0.01
      ..userData = 'avatar';

    body.createFixture(fixtureDef);

    return body;
  }

  void applyDamage() {
    if (!isImmune) {
      health -= 1;
      GenequestGame.instance?.updateHealth(health);
      isImmune = true;

      int blinkCount = 0;
      spriteComponent.opacity = 0.4;

      async.Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (blinkCount >= 5) {
          timer.cancel();
          isImmune = false;
          spriteComponent.opacity = 1.0; // Fully visible again
        } else {
          if (blinkCount == 0) {
            FlameAudio.play('oof.mp3');
          }

          // Alternate between 0.5 and 0.0 opacity
          spriteComponent.opacity = spriteComponent.opacity == 0.0 ? 0.5 : 0.0;

          blinkCount++;
        }
      });
    }

    if (health <= 0) {
      // Game Over logic

      gameState.setLevel(gameState.currentLevel - 1);
      GenequestGame.instance?.pause();

      if (!isDialogShowing) {
        isDialogShowing = true;
        showDialog(
          context: GenequestGame.instance!.context,
          barrierDismissible: false,
          builder: (context) {
            return DialogOverlayModal(
                title: "Game Over", action: "Gameover"); // Pause menu dialog
          },
        );
      }
    }
  }

  // Method to update the position
  void setPosition(Vector2 newPosition) {
    body.position.setFrom(newPosition - size);
  }

  void resetPosition() {
    body.setTransform(spawnPoint, body.angle);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double yVelocity = body.linearVelocity.y;
    double xVelocity = body.linearVelocity.x;

    if (movingForward) {
      body.applyForce(Vector2(20, 0));
    }
    if (movingBackward) {
      body.applyForce(Vector2(-20, 0));
    }
    if (jumpFuel > 0) {
      body.linearVelocity =
          Vector2(body.linearVelocity.x, yVelocity + jumpSpeed);
      jumpFuel -= 1;
    }
    else {
      body.linearVelocity = Vector2(xVelocity, yVelocity + GenequestGame.instance!.g * dt);
    }

    // 🔧 Rotation correction logic
    const double rotationCorrectionSpeed = 5.0; // tune this
    const double rotationDamping = 1.0; // optional

    double angle = body.angle;
    double angularVelocity = body.angularVelocity;

    // Apply torque to return to angle = 0
    double torque =
        -angle * rotationCorrectionSpeed - angularVelocity * rotationDamping;
    body.applyTorque(torque);
  }

  void jump() {
    if (jumpsRemaining > 0) {
      FlameAudio.play('jump.wav');
      jumpFuel = 6; // will jump for n frames
      jumpsRemaining -= 1;
    }
  }

  void resetJumps() {
    jumpsRemaining = 2;
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
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
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
