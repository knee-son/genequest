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

class LevelSelectorScreenState extends State<LevelSelectorScreen> {
  // final AssetImage selectALevel =
  //     const AssetImage('assets/images/select_a_level_text.png');
  @override
  void initState() {
    super.initState();
    FlameAudio.bgm.initialize();
    // gameState.loadState();
    _playMusic();
  }

  void _playMusic() {
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
        backgroundColor: const Color.fromARGB(255, 255, 242, 179),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Side: "Select a Level" vertically centered
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    'Select a Level:',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 47, 9, 2),
                      fontSize: 25,
                      fontFamily: 'WinkySans',
                      letterSpacing: 2,
                    ),
                  ),
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
                        iconPath: 'assets/images/peaceful_level.png',
                        level: 0,
                        backgroundColor: Colors.lightBlueAccent,
                        buttonHeight:
                            screenHeight * 0.2, // Responsive button height
                        enabled: gameState.level >= 0,
                      ),
                      const SizedBox(
                          height: 5), // Reduced spacing between buttons
                      LevelButton(
                        title: "Easy",
                        iconPath: 'assets/images/easy_level.png',
                        level: 1,
                        backgroundColor: Colors.green,
                        buttonHeight:
                            screenHeight * 0.2, // Responsive button height
                        enabled: gameState.level >= 1,
                      ),
                      const SizedBox(height: 5),
                      LevelButton(
                        title: "Medium",
                        iconPath: 'assets/images/medium_level.png',
                        level: 2,
                        backgroundColor: Colors.orange,
                        buttonHeight: screenHeight * 0.2,
                        enabled: gameState.level >= 2,
                      ),
                      const SizedBox(height: 5),
                      LevelButton(
                        title: "Hard",
                        iconPath: 'assets/images/hard_level.png',
                        level: 3,
                        backgroundColor: Colors.red,
                        buttonHeight: screenHeight * 0.2,
                        enabled: gameState.level >= 3,
                      ),
                      const SizedBox(height: 5),
                      LevelButton(
                        title: "Expert",
                        iconPath: 'assets/images/expert_level.png',
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
  final double buttonHeight;
  final bool enabled;

  const LevelButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.level,
    required this.backgroundColor,
    required this.buttonHeight,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5, // Dim when disabled
      child: SizedBox(
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: enabled
              ? () {
                  gameState.currentLevel = level;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(level),
                    ),
                  );
                  debugDumpApp();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            disabledBackgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Image.asset(
            iconPath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ), // Icon
        ),
      ),
    );
  }
}
