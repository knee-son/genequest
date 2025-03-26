
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';


import 'game_screen.dart';

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
  runApp(const LevelSelectorScreen(""));
}

class LevelSelectorScreen extends StatelessWidget {
  final String currentLevel;
  const LevelSelectorScreen(this.currentLevel, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; // Get screen height

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
                        backgroundColor: Colors.lightBlueAccent,
                        buttonHeight: screenHeight * 0.2, // Responsive button height
                      ),
                      const SizedBox(height: 2), // Reduced spacing between buttons
                      LevelButton(
                        title: "Easy",
                        iconPath: "assets/images/easy_level.png",
                        backgroundColor: Colors.green,
                        buttonHeight: screenHeight * 0.2, // Responsive button height
                      ),
                      const SizedBox(height: 2),
                      LevelButton(
                        title: "Med",
                        iconPath: "assets/images/medium_level.png",
                        backgroundColor: Colors.orange,
                        buttonHeight: screenHeight * 0.2,
                      ),
                      const SizedBox(height: 2),
                      LevelButton(
                        title: "Hard",
                        iconPath: "assets/images/hard_level.png",
                        backgroundColor: Colors.red,
                        buttonHeight: screenHeight * 0.2,
                      ),
                      const SizedBox(height: 2),
                      LevelButton(
                        title: "Expert",
                        iconPath: "assets/images/expert_level.png",
                        backgroundColor: Colors.purple,
                        buttonHeight: screenHeight * 0.2,
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
  final Color backgroundColor;
  final double buttonHeight; // New property for dynamic height

  const LevelButton({
    required this.title,
    required this.iconPath,
    required this.backgroundColor,
    required this.buttonHeight, // Pass height dynamically
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Button background color
          padding: EdgeInsets.zero, // Remove additional padding
          minimumSize: Size(double.infinity, buttonHeight), // Make button responsive
        ),
        onPressed: () {
          // Define navigation or functionality for each level
          if (title == "Peaceful"){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen("Level0.tmx"),
              ),
            );
          } else if(title == "Easy"){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen("Level1.tmx"),
              ),
            );
          }
        },
        child: Image.asset(
          iconPath,
          fit: BoxFit.cover, // Adjust image to fill the button perfectly
          width: double.infinity, // Stretch image to fill button width
          height: buttonHeight, // Stretch image to fill button height
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
