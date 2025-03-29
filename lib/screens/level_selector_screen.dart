import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';

import 'game_screen.dart';
import '../globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load all required images at the start
  await Flame.images.loadAll([
    'assets/images/peaceful_level.png',
    'assets/images/easy_level.png',
    'assets/images/medium_level.png',
    'assets/images/hard_level.png',
    'assets/images/expert_level.png',
    'assets/images/select_a_level_text.png',
  ]);
  runApp(const LevelSelectorScreen());
}

class LevelSelectorScreen extends StatelessWidget {
  const LevelSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Side: "Select a Level" vertically centered
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/select_a_level_text.png",
                      fit: BoxFit.contain, // Ensure the image scales properly
                    ),
                  ],
                ),
              ),
              // Right Side: Levels Column with reduced spacing
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LevelButton(
                        title: "Peaceful",
                        iconPath: "assets/images/peaceful_level.png",
                        level: 0,
                        backgroundColor: Colors.lightBlueAccent,
                        buttonHeight:
                            screenHeight * 0.2, // Responsive button height
                        enabled: gameState.level >= 0,
                      ),
                      const SizedBox(
                          height: 2), // Reduced spacing between buttons
                      LevelButton(
                        title: "Easy",
                        iconPath: "assets/images/easy_level.png",
                        level: 1,
                        backgroundColor: Colors.green,
                        buttonHeight:
                            screenHeight * 0.2, // Responsive button height
                        enabled: gameState.level >= 1,
                      ),
                      const SizedBox(height: 2),
                      LevelButton(
                        title: "Medium",
                        iconPath: "assets/images/medium_level.png",
                        level: 2,
                        backgroundColor: Colors.orange,
                        buttonHeight: screenHeight * 0.2,
                        enabled: gameState.level >= 2,
                      ),
                      const SizedBox(height: 2),
                      LevelButton(
                        title: "Hard",
                        iconPath: "assets/images/hard_level.png",
                        level: 3,
                        backgroundColor: Colors.red,
                        buttonHeight: screenHeight * 0.2,
                        enabled: gameState.level >= 3,
                      ),
                      const SizedBox(height: 2),
                      LevelButton(
                        title: "Expert",
                        iconPath: "assets/images/expert_level.png",
                        level: 4,
                        backgroundColor: Colors.purple,
                        buttonHeight: screenHeight * 0.2,
                        enabled: gameState.level >= 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final int level;
  final Color backgroundColor;
  final double buttonHeight; // New property for dynamic height
  final bool enabled; // NEW: Enable/Disable Button

  const LevelButton({
    required this.title,
    required this.iconPath,
    required this.level,
    required this.backgroundColor,
    required this.buttonHeight, // Pass height dynamically
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5, // Dim when disabled
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Button background color
            padding: EdgeInsets.zero, // Remove additional padding
            minimumSize:
                Size(double.infinity, buttonHeight), // Make button responsive
          ),
          onPressed: enabled
              ? () {
                  // Define navigation or functionality for each level
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(level),
                    ),
                  );
                }
              : null,
          child: Image.asset(
            iconPath,
            fit: BoxFit.cover, // Adjust image to fill the button perfectly
            width: double.infinity, // Stretch image to fill button width
            height: buttonHeight, // Stretch image to fill button height
          ),
        ),
      ),
    );
  }
}

class LevelSelector extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Ensure consistent paths to assets
    await Flame.images.loadAll([
      'assets/images/peaceful_level.png',
      'assets/images/easy_level.png',
      'assets/images/medium_level.png',
      'assets/images/hard_level.png',
      'assets/images/expert_level.png',
      'assets/images/select_a_level_text.png',
    ]);
  }
}
