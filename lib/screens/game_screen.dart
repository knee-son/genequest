import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:genequest_app/screens/title_screen.dart';

import 'level_selector_screen.dart';
import '../game_logic.dart';
import '../globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.images.loadAll([
    'chromatid.png',
    'sister_chromatid.png',
    'platform_1.png',
    'button_forward.png',
    'heart_full.png',
    'heart_half.png',
    'heart_empty.png',
  ]);

  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Pass the level name here
    return MaterialApp(
      home: GameScreen(0),
    );
  }
}

bool isNavigatingToTitleScreen = false;
bool isDialogShowing = false;

class GameScreen extends StatelessWidget {
  // final String levelName; // Declare a final field for the level name
  final int levelNum; // change to int
  final String levelName; // optional param for debugging


  final AssetImage forwardButtonImage = const AssetImage('assets/images/button_forward.png');
  final AssetImage resetButtonImage = const AssetImage('assets/images/button_reset.png');
  final AssetImage pauseButtonImage = const AssetImage('assets/images/button_pause.png');
  final AssetImage menuButtonImage = const AssetImage('assets/images/button_menu.png');


  const GameScreen(this.levelNum, {this.levelName = "", super.key});

  // HealthBar widget dynamically linked with healthNotifier
  Widget _buildHealthBar(BuildContext context) {
    final gameInstance = GenequestGame.instance;

    if (gameInstance == null) {
      return const SizedBox(); // Return empty widget if the game instance is not initialized
    }

    return ValueListenableBuilder<int>(
      valueListenable: gameInstance.healthNotifier,
      builder: (context, health, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            int heartHealth = health - (index * 2);
            String asset = heartHealth >= 2
                ? 'assets/images/heart_full.png'
                : heartHealth == 1
                ? 'assets/images/heart_half.png'
                : 'assets/images/heart_empty.png';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Image.asset(asset, width: 40, height: 40),
            );
          }),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final double containerHeight = MediaQuery.of(context).size.height * 0.2;

    return Scaffold(
      body: Stack(
        children: [
          // Game canvas
          LayoutBuilder(
            builder: (context, constraints) {
              return GameWidget(
                game: GenequestGame(
                    containerHeight: containerHeight,
                    context: context,
                    levelNum: levelNum,
                    levelName: levelName),
                overlayBuilderMap: {
                  'HealthBar': (_, game) => Align(
                        alignment: Alignment
                            .topRight, // Move health bar to the upper right
                        child: Padding(
                          padding: const EdgeInsets.all(
                              10), // Add spacing for aesthetics
                          child: _buildHealthBar(context),
                        ),
                      ),
                },
              );
            },
          ),

          // Bottom menu for movement buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left movement buttons
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        InkWell(
                          onTapDown: (_) => GenequestGame.instance?.startMovingAvatarBack(),
                          onTapUp: (_) => GenequestGame.instance?.stopMovingAvatar(),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.14159),
                            child: Image(image: forwardButtonImage, width: 60, height: 60),
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTapDown: (_) => GenequestGame.instance?.startMovingAvatar(),
                          onTapUp: (_) => GenequestGame.instance?.stopMovingAvatar(),
                          child: Image(image: forwardButtonImage, width: 60, height: 60),
                        ),
                      ],
                    ),
                  ),

                  // Right movement button
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTapDown: (_) => GenequestGame.instance?.startJump(),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationZ(-1.5708),
                        child: Image(image: forwardButtonImage, width: 60, height: 60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Left-center alignment for Start and Reset buttons
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10), // Space between buttons
                  GestureDetector(
                    onTap: () {
                      GenequestGame.instance?.reset(); // Reset game logic
                    },
                    child: Image.asset(
                      'assets/images/button_reset.png',
                      width: 100,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top-left alignment for Menu and Pause buttons
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Menu button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TitleScreen(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/button_menu.png',
                      width: 100,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Pause button
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return DialogOverlayModal(
                            title: "Game Paused",
                            action: "Paused",
                          ); // Pause menu dialog
                        },
                      );
                    },
                    child: Image.asset(
                      'assets/images/button_pause.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clear cached assets to free memory
    forwardButtonImage.evict();
    resetButtonImage.evict();
    pauseButtonImage.evict();
    menuButtonImage.evict();
  }


}

class DialogOverlayModal extends StatelessWidget {
  final String title;
  final String action;

  const DialogOverlayModal({
    super.key,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    GenequestGame.instance?.pause();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (action == "Paused")
              ElevatedButton(
                onPressed: () => _dismissDialog(context),
                child: const Text("Resume"),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _navigateToLevelSelector(context),
              child: Text(action == "Paused" ? "Level Select" : "Go Back"),
            ),
          ],
        ),
      ),
    );
  }

  void _dismissDialog(BuildContext context) {
    isDialogShowing = false;
    GenequestGame.instance?.resume();
    Navigator.pop(context);
  }

  void _navigateToLevelSelector(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LevelSelectorScreen()),
    );
  }
}
