import 'dart:ui';

import 'package:flame/camera.dart' as flame_camera;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_tiled/flame_tiled.dart' as flameTiled;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:genequest_app/globals.dart';

class Ball extends BodyComponent {
  final double radius;

  Ball(this.radius);

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..restitution = 0.8;

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(50, 10); // start position

    final body = world.createBody(bodyDef)..createFixture(fixtureDef);
    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(
        Offset.zero, radius, Paint()..color = const Color(0xFF00FF00));
  }
}

class Floor extends BodyComponent {
  final Vector2 position = Vector2(0, 100);
  final Vector2 size = Vector2.all(100);

  Floor();

  @override
  Body createBody() {
    paint = Paint()..color = const Color.fromARGB(255, 255, 255, 255);

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

class GenequestGame extends Forge2DGame {
  static GenequestGame? instance;
  ValueNotifier<int> healthNotifier = ValueNotifier(6);
  late flameTiled.TiledComponent levelMap;
  late flame_camera.World w;

  Ball? ball;
  Floor? floor;

  GenequestGame({required context, required levelNum, required levelName})
      : super(gravity: Vector2(0, 10.0), zoom: 10.0);

  @override
  Future<void> onLoad() async {

  levelMap = await flameTiled.TiledComponent.load(
    gameState.getLevelName(3),
    Vector2.all(64),
  );
    // print('context $context');
    ball = Ball(10.0);
    floor = Floor();

    await add(ball!);
    await add(floor!);
    // add(levelMap);

    final double screenWidth = size.x;
    final double screenHeight = size.y;

    camera = flame_camera.CameraComponent.withFixedResolution(
        width: screenWidth * 1.2,
        height: screenHeight * 1.2,
        world: world,
        viewfinder: flame_camera.Viewfinder()
          ..position = ball!.body.position
        );
    camera.viewport.size = Vector2(screenWidth, screenHeight);
    // camera.viewport.position = (Vector2.all(500));


    w = flame_camera.World();
    await add (w);
    w.add(ball!);
    w.add(levelMap);
    camera.world = w;

    camera.follow(ball!);
  }

  @override
  void update(double dt){
    super.update(dt * 2);

    // Vector2 p = ball!.position;
    // camera.moveTo(p); 
    // print(ball!.position);
    // print(camera.viewport.position);

  } 

  void resume() {
    print('resumed!');
  }

  void reset() {
    print('reset!');
  }

  void pause() {
    print('paused!');
  }
}
