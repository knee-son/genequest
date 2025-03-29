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

  const GameScreen(this.levelNum, {super.key});

  // HealthBar widget dynamically linked with healthNotifier
  Widget healthBar(BuildContext context) {
    final gameInstance = GenequestGame.instance;
    if (gameInstance == null) {
      return const SizedBox(); // Return an empty widget if the game is not initialized
    }
    return ValueListenableBuilder<int>(
      valueListenable: gameInstance.healthNotifier,
      builder: (context, health, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            int heartHealth = health - (index * 2);
            String asset;
            if (heartHealth >= 2) {
              asset = 'assets/images/heart_full.png'; // Full heart
            } else if (heartHealth == 1) {
              asset = 'assets/images/heart_half.png'; // Half heart
            } else {
              asset = 'assets/images/heart_empty.png'; // Empty heart
            }
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
                    levelNum: levelNum),
                overlayBuilderMap: {
                  'HealthBar': (_, game) => Align(
                        alignment: Alignment
                            .topRight, // Move health bar to the upper right
                        child: Padding(
                          padding: const EdgeInsets.all(
                              10), // Add spacing for aesthetics
                          child: healthBar(context),
                        ),
                      ),
                },
              );
            },
          ),

          // Bottom menu for movement buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left movement buttons (Back, Forward)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTapDown: (details) {
                            GenequestGame.instance?.startMovingAvatarBack();
                          },
                          onTapUp: (details) {
                            GenequestGame.instance?.stopMovingAvatar();
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.14159),
                            child: Image.asset(
                              'assets/images/button_forward.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTapDown: (details) {
                            GenequestGame.instance?.startMovingAvatar();
                          },
                          onTapUp: (details) {
                            GenequestGame.instance?.stopMovingAvatar();
                          },
                          child: Image.asset(
                            'assets/images/button_forward.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right movement button (Jump)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTapDown: (details) {
                        GenequestGame.instance?.startJump();
                      },
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationZ(-1.5708),
                        child: Image.asset(
                          'assets/images/button_forward.png',
                          width: 60,
                          height: 60,
                        ),
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
                  GestureDetector(
                    onTap: () {
                      // Start button logic
                      debugPrint('Start button pressed');
                    },
                    child: Image.asset(
                      'assets/images/button_start.png',
                      width: 100,
                      height: 50,
                    ),
                  ),
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
                      Navigator.push(
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
}

class DialogOverlayModal extends StatelessWidget {
  final String title;
  //Action has two states "Paused" and "Gameover"
  final String action;

  const DialogOverlayModal(
      {super.key, required this.title, required this.action});

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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (action == "Paused") ...[
              ElevatedButton(
                onPressed: () {
                  isDialogShowing = false;
                  if (GenequestGame.instance?.isPaused == true) {
                    GenequestGame.instance?.resume(); // Resume the game
                  }
                  Navigator.pop(context); // Close the pause menu
                },
                child: Text("Resume"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // isDialogShowing = false;
                  Navigator.pop(context); // Close pause menu
                  // Navigator.pop(context); // Navigate back to TitleScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LevelSelectorScreen(),
                    ),
                    (route) =>
                        false, // This will remove all the previous routes
                  );
                },
                child: Text("Go back"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
