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
  // WidgetsFlutterBinding.ensureInitialized();

  // // No need to load images here; FlameGame will handle it
  // runApp(GameWidget(
  //     game: LevelSelector())); // Use Flame's GameWidget to run the game
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
    debugPrint('level screen disposed');
    FlameAudio.bgm.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

    final screenWidth =
        MediaQuery.of(context).size.width; // Get screen height

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFB55022),
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
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // children: [
                  // Image(
                  //   image: selectALevel,
                  //   fit: BoxFit.contain, // Ensure the image scales properly
                  // ),
                  // ],
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
                        buttonWidth: screenWidth * 0.6,
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
                        buttonWidth: screenWidth * 0.6,
                        buttonHeight:
                            screenHeight * 0.2, // Responsive button height
                        enabled: gameState.level >= 1,
                      ),
                      const SizedBox(height: 5),
                      LevelButton(
                        title: "Medium",
                        iconPath: 'assets/images/medium_level.png',
                        level: 2,
                        buttonWidth: screenWidth * 0.6,
                        buttonHeight: screenHeight * 0.2,
                        enabled: gameState.level >= 2,
                      ),
                      const SizedBox(height: 5),
                      LevelButton(
                        title: "Hard",
                        iconPath: 'assets/images/hard_level.png',
                        level: 3,
                        buttonWidth: screenWidth * 0.6,
                        buttonHeight: screenHeight * 0.2,
                        enabled: gameState.level >= 3,
                      ),
                      const SizedBox(height: 5),
                      LevelButton(
                        title: "Expert",
                        iconPath: 'assets/images/expert_level.png',
                        level: 4,
                        buttonWidth: screenWidth * 0.6,
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
  final double buttonHeight;
  final bool enabled;
  final double buttonWidth;

  const LevelButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.level,
    required this.buttonHeight,
    required this.enabled,
    required this.buttonWidth
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5, // Dim when disabled
      child: InkWell(
        borderRadius: BorderRadius.circular(12), // Add ripple effect with rounded corners
        onTap: enabled
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
            : null, // Disable when not enabled
        child: ClipRRect(
          child: Image.asset(
            iconPath,
            fit: BoxFit.fill,
            width: buttonWidth,
            height: buttonHeight,
          ),
        ),
      ),
    );
  }
}
