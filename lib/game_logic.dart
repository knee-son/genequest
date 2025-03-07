import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

// ------------------- GAME LOGIC -------------------

class GenequestGame extends FlameGame {
  static GenequestGame? instance; // Singleton for UI interaction
  late Avatar avatar;
  final double containerHeight;

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

    final chromatidSprite = Sprite(Flame.images.fromCache('chromatid.png'));
    avatar = Avatar(chromatidSprite); // Pass the sprite to Avatar

    final screenHeight = size.y; // Total screen height
    avatar.groundY = screenHeight - containerHeight - avatar.size.y;
    add(avatar);
  }

  // Method to trigger a jump
  void startJump() {
    if (!avatar.isInAir) {
      avatar.velocityY = -300; // Give an upward velocity
      avatar.isInAir = true; // Set the avatar as mid-air
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
    position.y += velocityY * dt; // Debugging print
  }
}
