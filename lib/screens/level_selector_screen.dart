import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';

import 'game_screen.dart';
import '../globals.dart';

class LevelSelectorScreen extends StatefulWidget {
  const LevelSelectorScreen({super.key});

  @override
  LevelSelectorScreenState createState() => LevelSelectorScreenState();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No need to load images here; FlameGame will handle it
  runApp(GameWidget(game: LevelSelector())); // Use Flame's GameWidget to run the game
}


class LevelSelectorScreenState extends State<LevelSelectorScreen> {

  final AssetImage peacefulLevel = const AssetImage('assets/images/peaceful_level.png');
  final AssetImage easyLevel = const AssetImage('assets/images/easy_level.png');
  final AssetImage mediumLevel = const AssetImage('assets/images/medium_level.png');
  final AssetImage hardLevel = const AssetImage('assets/images/hard_level.png');
  final AssetImage expertLevel = const AssetImage('assets/images/expert_level.png');
  final AssetImage selectALevel = const AssetImage('assets/images/select_a_level_text.png');
  @override
  void initState() {
    super.initState();
    _playMusic();
  }

  void _playMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play(
      'music4.mp3',
      volume: 0.5,
    );
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    super.dispose();
  }

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
                    Image(
                      image: selectALevel,
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
                        iconPath: peacefulLevel,
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
                        iconPath: easyLevel,
                        level: 1,
                        backgroundColor: Colors.green,
                        buttonHeight:
                            screenHeight * 0.2, // Responsive button height
                        enabled: gameState.level >= 1,
                      ),
                      const SizedBox(height: 2),
                      LevelButton(
                        title: "Medium",
                        iconPath: mediumLevel,
                        level: 2,
                        backgroundColor: Colors.orange,
                        buttonHeight: screenHeight * 0.2,
                        enabled: gameState.level >= 2,
                      ),
                      const SizedBox(height: 2),
                      LevelButton(
                        title: "Hard",
                        iconPath: hardLevel,
                        level: 3,
                        backgroundColor: Colors.red,
                        buttonHeight: screenHeight * 0.2,
                        enabled: gameState.level >= 3,
                      ),
                      const SizedBox(height: 2),
                      LevelButton(
                        title: "Expert",
                        iconPath: expertLevel,
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
  final AssetImage iconPath;
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
                  gameState.currentLevel = level;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(level),
                    ),
                  );
                }
              : null,
          child: Image(
            image: iconPath,
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
    // Preload all required assets only once
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

