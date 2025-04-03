import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genequest_app/globals.dart';
import 'package:genequest_app/screens/game_over_screen.dart';
import 'level_selector_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MiniGameScreen(0));
}

class MiniGameScreen extends StatefulWidget {
  final int levelNum;
  final String levelName;

  MiniGameScreen(this.levelNum, {super.key})
      : levelName = gameState.getLevelName(levelNum);

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  String? _blockColor; // Tracks the color of the block to spawn
  final List<String?> _droppedBlockFirst = [];
  final List<String?> _droppedBlockSecond =
      []; // Tracks the block dropped into the first drop zone// Tracks the block dropped into the second drop zone
  final AssetImage combinedChromatid =
  const AssetImage('assets/images/combined_chromatid.png');
  final AssetImage redButton =
  const AssetImage('assets/images/red_button.png');
  final AssetImage pillBlue =
  const AssetImage('assets/images/pill_blue.png');
  final AssetImage pillRed =
  const AssetImage('assets/images/pill_red.png');
  void onButtonPressed() {
    // Randomly choose the color of the block
    final isBlue = Random().nextBool();

    setState(() {
      _blockColor = isBlue ? 'blue' : 'red';
    });
  }

  void onResetPressed() {
    // Clear all blocks and drop zones
    setState(() {
      _blockColor = null;
      _droppedBlockFirst.clear();
      _droppedBlockSecond.clear();
    });
  }

  void checkIfValid() {
    if (_droppedBlockFirst.length == 2 &&
        _droppedBlockSecond.length == 2 &&
        _droppedBlockFirst.toString() ==
            _droppedBlockSecond.reversed.toList().toString()) {
      String dominantTrait =
          gameState.traits[gameState.currentLevel].defaultTrait;
      String nondomi = gameState.traits[gameState.currentLevel].traits.last;

      Trait newTrait = Trait(
          name: gameState.traits[gameState.currentLevel].name,
          traits: gameState.traits[gameState.currentLevel].traits,
          difficulty: gameState.traits[gameState.currentLevel].difficulty,
          selectedTrait: dominantTrait,
          level: gameState.traits[gameState.currentLevel].level);

      if (_droppedBlockFirst.contains("red")) {
        newTrait.selectedTrait = dominantTrait;
      } else {
        newTrait.selectedTrait = nondomi;
      }

      // Check for an existing trait where the level matches gameState.level
      var existingTraitIndex = gameState.savedTraits.indexWhere(
        (trait) => trait.level == gameState.currentLevel,
      );
      if (existingTraitIndex != -1) {
        // Update the existing trait instance if found and selectedTrait is not empty
        gameState.savedTraits[existingTraitIndex] = newTrait;
      } else {
        gameState.savedTraits.add(newTrait);
      }
      if (gameState.currentLevel == 4) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => GameOverScreen(),
          ),
              (Route<dynamic> route) => false, // Removes all previous routes
        );
      } else {
        gameState.incrementLevel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LevelSelectorScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title:
              kDebugMode ? Text('Mini Game - ${widget.levelName}') : SizedBox(),
        ),
        body: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Combined chromatid asset
                  Stack(
                    children: [
                      Image(
                        image: combinedChromatid,
                        width: 300,
                        height: 300,
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // "50% chance" label with button beside it
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 150,
                            height: 50,
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text(
                                '50% chance',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Display blocks dynamically
                          if (_blockColor != null)
                            Draggable(
                              data: _blockColor,
                              feedback: widget.levelName.contains("Level1.tmx")
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image(
                                          image: _blockColor == 'blue'
                                              ? pillBlue
                                              : pillRed,
                                          width: 100,
                                          height: 100,
                                        ),
                                        Image(
                                          image: _blockColor == 'blue'
                                              ? pillBlue
                                              : pillRed,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ],
                                    )
                                  : Image(
                                    image: _blockColor == 'blue'
                                        ? pillBlue
                                        : pillRed,
                                      width: 100,
                                      height: 100,
                                    ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: widget.levelName == "Level1.tmx"
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image(
                                            image: _blockColor == 'blue'
                                                ? pillBlue
                                                : pillRed,
                                            width: 100,
                                            height: 100,
                                          ),
                                          Image(
                                            image: _blockColor == 'blue'
                                                ? pillBlue
                                                : pillRed,
                                            width: 100,
                                            height: 100,
                                          ),
                                        ],
                                      )
                                    : Image(
                                        image: _blockColor == 'blue'
                                            ? pillBlue
                                            : pillRed,
                                        width: 100,
                                        height: 100,
                                      ),
                              ),
                              child: widget.levelName == "Level1.tmx"
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image(
                                          image: _blockColor == 'blue'
                                              ? pillBlue
                                              : pillRed,
                                          width: 100,
                                          height: 100,
                                        ),
                                        Image(
                                          image: _blockColor == 'blue'
                                              ? pillBlue
                                              : pillRed,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ],
                                    )
                                  : Image(
                                      image: _blockColor == 'blue'
                                          ? pillBlue
                                          : pillRed,
                                      width: 100,
                                      height: 100,
                                    ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          // Reset button
                          GestureDetector(
                            onTap: onResetPressed,
                            child: Container(
                              width: 100,
                              height: 50,
                              color: Colors.grey,
                              child: const Center(
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Red button
                          GestureDetector(
                            onTap:
                                onButtonPressed, // Trigger the logic to spawn a block
                            child: Image(
                              image: redButton,
                              width: 100,
                              height: 150,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // First drop zone (bottom-left)
            Align(
              alignment: Alignment.bottomLeft,
              child: DragTarget<String>(
                onAccept: (data) {
                  setState(() {
                    if (_droppedBlockFirst.length < 2 &&
                        widget.levelName != 'Level1.tmx') {
                      // Allow up to 2 blocks
                      _droppedBlockFirst
                          .add(data); // Add the new block to the list
                      _blockColor = null; // Clear the draggable block's state
                    } else {
                      _droppedBlockFirst
                          .add(data); // Add the new block to the list
                      _droppedBlockFirst
                          .add(data); // Add the new block to the list
                      _blockColor = null; // Clear the draggable block's state
                    }

                    checkIfValid();
                  });
                },
                builder: (context, accepted, rejected) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    width: 220, // Width accommodates up to two blocks
                    height: 100, // Maintain consistent height
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black, // Outline color
                        width: 3.0, // Outline thickness
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _droppedBlockFirst.map((block) {
                          return Image(
                            image: block == 'blue'
                                ? pillBlue
                                : pillRed,
                            width: 100,
                            height: 100,
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),

// Second drop zone (beside the first one)
            Align(
              alignment: Alignment.bottomCenter,
              child: DragTarget<String>(
                onAccept: (data) {
                  setState(() {
                    if (_droppedBlockSecond.length < 2 &&
                        widget.levelName != 'Level1.tmx') {
                      // Allow up to 2 blocks
                      _droppedBlockSecond
                          .add(data); // Add the new block to the list
                      _blockColor = null; // Clear the draggable block's state
                    } else {
                      _droppedBlockSecond
                          .add(data); // Add the new block to the list
                      _droppedBlockSecond
                          .add(data); // Add the new block to the list
                      _blockColor = null; // Clear the draggable block's state
                    }
                    checkIfValid();
                  });
                },
                builder: (context, accepted, rejected) {
                  return Container(
                    margin: const EdgeInsets.only(left: 160, bottom: 20),
                    width: 220, // Width accommodates up to two blocks
                    height: 100, // Maintain consistent height
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black, // Outline color
                        width: 3.0, // Outline thickness
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _droppedBlockSecond.map((block) {
                          return Image(
                            image: block == 'blue'
                                ? pillBlue
                                : pillRed,
                            width: 100,
                            height: 100,
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
