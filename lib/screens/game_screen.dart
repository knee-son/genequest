import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:genequest_app/globals.dart';
import 'package:genequest_app/screens/title_screen.dart';

import 'level_selector_screen.dart';
import '../game_logic.dart';

class GameScreen extends StatefulWidget {
  final int levelNum;
  final String levelName;

  GameScreen(this.levelNum, {String? levelName, super.key})
      : levelName =
            levelName ?? gameState.getLevelName(levelNum); // Default if null

  @override
  State<GameScreen> createState() => _GameScreenState();
}

bool isNavigatingToTitleScreen = false;
bool isDialogShowing = false;

class _GameScreenState extends State<GameScreen> {
  final AssetImage forwardButtonImage =
      const AssetImage('assets/images/button_forward.png');
  final AssetImage resetButtonImage =
      const AssetImage('assets/images/button_reset.png');
  final AssetImage pauseButtonImage =
      const AssetImage('assets/images/button_pause.png');
  final AssetImage menuButtonImage =
      const AssetImage('assets/images/button_menu.png');
  final AssetImage heartEmptyImage =
      const AssetImage('assets/images/heart_empty.png');
  final AssetImage heartHalfImage =
      const AssetImage('assets/images/heart_half.png');
  final AssetImage heartFullImage =
      const AssetImage('assets/images/heart_full.png');

  @override
  void initState() {
    super.initState();
    FlameAudio.bgm.initialize();
    // gameState.loadState();
    _playMusic();
  }

  void _playMusic() {
    // List of music tracks to choose from
    final List<String> musicTracks = ['music1.mp3', 'music3.mp3'];

    // Pick a random track
    final String selectedMusic =
        musicTracks[Random().nextInt(musicTracks.length)];

    // Play the randomly selected music
    FlameAudio.bgm.play(
      selectedMusic,
      volume: 0.5,
    );
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    super.dispose();
  }

  // HealthBar widget dynamically linked with healthNotifier
  Widget _buildHealthBar(BuildContext context) {
    final gameInstance = GenequestGame.instance;

    if (gameInstance == null) {
      return const SizedBox(); // Return empty widget if the game instance is not initialized
    }

    return ValueListenableBuilder<int>(
      valueListenable: gameInstance.healthNotifier,
      builder: (context, health, child) {
        return RepaintBoundary(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              int heartHealth = health - (index * 2);
              AssetImage asset = heartHealth >= 2
                  ? heartFullImage
                  : heartHealth == 1
                      ? heartHalfImage
                      : heartEmptyImage;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Image(image: asset, width: 40, height: 40),
              );
            }),
          ),
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
                    levelNum: widget.levelNum,
                    levelName: widget.levelName),
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
              child: RepaintBoundary(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left movement buttons
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          InkWell(
                            // onTapDown: (_) =>
                            //     GenequestGame.instance?.startMovingAvatarBack(),
                            // onTapUp: (_) =>
                            //     GenequestGame.instance?.stopMovingAvatar(),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(3.14159),
                              child: Image(
                                  image: forwardButtonImage,
                                  width: 60,
                                  height: 60),
                            ),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            // onTapDown: (_) =>
                            //     GenequestGame.instance?.startMovingAvatar(),
                            // onTapUp: (_) =>
                            //     GenequestGame.instance?.stopMovingAvatar(),
                            child: Image(
                                image: forwardButtonImage,
                                width: 60,
                                height: 60),
                          ),
                        ],
                      ),
                    ),

                    // Right movement button
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        // onTapDown: (_) => GenequestGame.instance?.startJump(),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationZ(-1.5708),
                          child: Image(
                              image: forwardButtonImage, width: 60, height: 60),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top-left alignment for Menu and Pause buttons
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: RepaintBoundary(
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
                      child: Image(
                        image: menuButtonImage,
                        width: 100,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Reset button
                    GestureDetector(
                      onTap: () {
                        GenequestGame.instance?.reset(); // Reset game logic
                      },
                      child: Image(
                        image: resetButtonImage,
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
                      child: Image(
                        image: pauseButtonImage,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
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
