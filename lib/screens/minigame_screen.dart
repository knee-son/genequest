import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genequest_app/globals.dart';
import 'package:genequest_app/screens/game_over_transition_screen.dart';
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
  final List<String?> _droppedBlockSecond = [];
  final List<String?> _droppedBlockThird = [];
  final List<String?> _droppedBlockFourth = [];
  final List<String?> _droppedBlockFifth = [];
  final List<String?> _droppedBlockSixth = [
  ]; // Tracks the block dropped into the first drop zone// Tracks the block dropped into the second drop zone
  final AssetImage combinedChromatid =
  const AssetImage('assets/images/combined_chromatid_new.png');
  final AssetImage redButton =
  const AssetImage('assets/images/red_button.png');
  final AssetImage resetButton =
  const AssetImage('assets/images/button_reset.png');
  final AssetImage pillBlue =
  const AssetImage('assets/images/pill_blue.png');
  final AssetImage pillRed =
  const AssetImage('assets/images/pill_red.png');

  double spawnPillWidth = 70;
  double spawnPillHeight = 60;

  double dropZoneWidth = 150;
  double dropZoneHeight = 50;

  GlobalKey chromatidKey = GlobalKey(); // Key for chromatid widget
  Offset leftDropZonePosition1 = Offset.zero;
  Offset rightDropZonePosition1 = Offset.zero;
  Offset leftDropZonePosition2 = Offset.zero;
  Offset rightDropZonePosition2 = Offset.zero;
  Offset leftDropZonePosition3 = Offset.zero;
  Offset rightDropZonePosition3 = Offset.zero;

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
      _droppedBlockThird.clear();
      _droppedBlockFourth.clear();
      _droppedBlockFifth.clear();
      _droppedBlockSixth.clear();
    });
  }

  void checkIfValid() {
    int isFinishFlags = 0;
    int totalBlueCount = 0;
    int totalRedCount = 0;
    AssetImage fullImagePath = AssetImage('assets/images/portraits');
    List<String> traitFilePathList = [
      "Almond_Eyes_Trait.png",
      "Black_Hair_Trait.png",
      "Fair_Skin_Trait.png",
      "Brown_Skin_Trait.png",
      "Fair_Skin_Trait.png",
      "Round_Eyes_Trait.png",
      "Short_Height_Trait.png",
      "Tall_Height_Trait.png",
      "Male_Trait.png",
      "Female_Trait.png"
    ];
    // for level 1 and 2
    if (_droppedBlockFirst.length == 2 &&
        _droppedBlockSecond.length == 2) {
      int blueCount = _droppedBlockFirst.where((e) => e == "blue").length +
          _droppedBlockSecond.where((e) => e == "blue").length;
      int redCount = (_droppedBlockFirst.length + _droppedBlockSecond.length) - blueCount;
      totalBlueCount += blueCount;
      totalRedCount += redCount;
      isFinishFlags++;
    }
    // for level 3
    if (gameState.currentLevel >= 3 && _droppedBlockThird.length == 2 &&
        _droppedBlockFourth.length == 2 ) {
      int blueCount = _droppedBlockThird.where((e) => e == "blue").length +
          _droppedBlockFourth.where((e) => e == "blue").length;
      int redCount = (_droppedBlockThird.length + _droppedBlockFourth.length) - blueCount;
      totalBlueCount += blueCount;
      totalRedCount += redCount;
      isFinishFlags++;
    }
    // for level 4
    if (gameState.currentLevel >= 4 && _droppedBlockFifth.length == 2 &&
        _droppedBlockSixth.length == 2 ) {
      int blueCount = _droppedBlockFifth.where((e) => e == "blue").length +
          _droppedBlockSixth.where((e) => e == "blue").length;
      int redCount = (_droppedBlockFifth.length + _droppedBlockSixth.length) - blueCount;

      totalBlueCount += blueCount;
      totalRedCount += redCount;
      isFinishFlags++;
    }

    if (isFinishFlags == gameState.currentLevel - 1 &&
        gameState.currentLevel >= 3 ||
        (isFinishFlags == 1 && gameState.currentLevel == 1) ||
        (isFinishFlags == 1 && gameState.currentLevel == 2)) {
      String dominantTrait =
          gameState.traits[gameState.currentLevel].defaultTrait;
      String nonDomi = gameState.traits[gameState.currentLevel].traits.last;
      // Purpose of newTempTrait is to add the necessary description after the trait
      String newTemptrait = "";
      Trait newTrait = Trait(
          name: gameState.traits[gameState.currentLevel].name,
          traits: gameState.traits[gameState.currentLevel].traits,
          difficulty: gameState.traits[gameState.currentLevel].difficulty,
          selectedTrait: dominantTrait,
          level: gameState.traits[gameState.currentLevel].level);

      if (totalBlueCount >= totalRedCount) {
        newTrait.selectedTrait = dominantTrait;
      } else {
        newTrait.selectedTrait = nonDomi;
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

      newTemptrait = "${newTrait.selectedTrait} ${newTrait.name[0].toUpperCase()}${newTrait.name.substring(1)}";
      String? imageFilePath = findMatchingImage(newTrait.selectedTrait, traitFilePathList);
      fullImagePath = AssetImage("assets/images/portraits/$imageFilePath");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Trait Acquired'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Acquired Trait: $newTemptrait'),
                const SizedBox(height: 10), // Adds spacing
                fullImagePath != null
                    ? Image(
                        image: fullImagePath,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover
                      )
                    : const Center(
                        child: Text(
                          'Error: Image not available',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  if (gameState.currentLevel == 4) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameOverTransitionScreen(),
                      ),
                          (Route<dynamic> route) => false, // Removes all previous routes
                    );
                  } else {
                    gameState.incrementLevel();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LevelSelectorScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Dismiss'),
              ),
            ],
          );
        },
      );
    }
  }

  String? findMatchingImage(String selectedTrait, List<String> traitFilePathList) {
    for (String fileName in traitFilePathList) {
      if (fileName.contains(selectedTrait)) {
        return fileName; // Return the matching file name
      }
    }
    return null; // Return null if no match is found
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title:
          kDebugMode ? Text('Mini Game - ${gameState.levelName}') : SizedBox(),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline), // "?" icon
              onPressed: () {
                // Handle help action, e.g., show a dialog
                _showMultiStepDialog(context);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Combined chromatid asset
                  Stack(
                    key: chromatidKey,
                    children: [
                      Image(
                        image: combinedChromatid,
                        width: 300,
                        height: 300,
                      ),
                    ],
                  ),
                  // "50% chance" label with button beside it
                  Row(
                    children: [
                      Column(
                        children: [
                          // Row containing Reset and Red buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // Aligns buttons horizontally
                            children: [
                              // Reset button
                              GestureDetector(
                                onTap: onResetPressed,
                                // Trigger the logic to spawn a block
                                child: Image(
                                  image: resetButton,
                                  width: 80,
                                  height: 100,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Adds spacing between the buttons
                              // Red button
                              GestureDetector(
                                onTap: onButtonPressed,
                                // Trigger the logic to spawn a block
                                child: Image(
                                  image: redButton,
                                  width: 100,
                                  height: 150,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Adds spacing between the Row and Draggable
                          // Draggable widget
                          if (_blockColor != null)
                            Draggable(
                              data: _blockColor,
                              feedback: gameState.currentLevel == 1
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image(
                                    image: _blockColor == 'blue'
                                        ? pillBlue
                                        : pillRed,
                                    width: spawnPillWidth,
                                    height: spawnPillHeight,
                                  ),
                                  Image(
                                    image: _blockColor == 'blue'
                                        ? pillBlue
                                        : pillRed,
                                    width: spawnPillWidth,
                                    height: spawnPillHeight,
                                  ),
                                ],
                              )
                                  : Image(
                                image: _blockColor == 'blue'
                                    ? pillBlue
                                    : pillRed,
                                width: spawnPillWidth,
                                height: spawnPillHeight,
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: gameState.currentLevel == 11
                                    ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image(
                                      image: _blockColor == 'blue'
                                          ? pillBlue
                                          : pillRed,
                                      width: spawnPillWidth,
                                      height: spawnPillHeight,
                                    ),
                                    Image(
                                      image: _blockColor == 'blue'
                                          ? pillBlue
                                          : pillRed,
                                      width: spawnPillWidth,
                                      height: spawnPillHeight,
                                    ),
                                  ],
                                )
                                    : Image(
                                  image: _blockColor == 'blue'
                                      ? pillBlue
                                      : pillRed,
                                  width: spawnPillWidth,
                                  height: spawnPillHeight,
                                ),
                              ),
                              child: gameState.currentLevel == 1
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image(
                                    image: _blockColor == 'blue'
                                        ? pillBlue
                                        : pillRed,
                                    width: spawnPillWidth,
                                    height: spawnPillHeight,
                                  ),
                                  Image(
                                    image: _blockColor == 'blue'
                                        ? pillBlue
                                        : pillRed,
                                    width: spawnPillWidth,
                                    height: spawnPillHeight,
                                  ),
                                ],
                              )
                                  : Image(
                                image: _blockColor == 'blue'
                                    ? pillBlue
                                    : pillRed,
                                width: spawnPillWidth,
                                height: spawnPillHeight,
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
            Positioned(
              left: leftDropZonePosition1.dx,
              // Dynamically calculated x-position
              top: leftDropZonePosition1.dy,
              // Dynamically calculated y-position
              child: DragTarget<String>(
                onAccept: (data) {
                  setState(() {
                    if (_droppedBlockFirst.length < 2) {
                      if (gameState.currentLevel > 1) {
                        // Allow up to 2 blocks
                        _droppedBlockFirst.add(
                            data); // Add the new block to the list
                        _blockColor = null; // Clear the draggable block's state
                      } else {
                        _droppedBlockFirst.add(
                            data); // Add the new block to the list twice
                        _droppedBlockFirst.add(data);
                        _blockColor = null; // Clear the draggable block's state
                      }
                    }
                    checkIfValid(); // Validate the current arrangement
                  });
                },
                builder: (context, accepted, rejected) {
                  return Container(
                    width: dropZoneWidth, // Width accommodates up to two blocks
                    height: dropZoneHeight, // Maintain consistent height
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
                            image: block == 'blue' ? pillBlue : pillRed,
                            width: spawnPillWidth,
                            height: spawnPillHeight,
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),

// Second drop zone (beside the first one)
            Positioned(
              left: rightDropZonePosition1.dx,
              // Dynamically calculated x-position
              top: rightDropZonePosition1.dy,
              // Dynamically calculated y-position
              child: DragTarget<String>(
                onAccept: (data) {
                  setState(() {
                    if (_droppedBlockSecond.length < 2) {
                      if (gameState.currentLevel > 1) {
                        // Allow up to 2 blocks
                        _droppedBlockSecond.add(
                            data); // Add the new block to the list
                        _blockColor = null; // Clear the draggable block's state
                      } else {
                        _droppedBlockSecond.add(
                            data); // Add the new block to the list twice
                        _droppedBlockSecond.add(data);
                        _blockColor = null; // Clear the draggable block's state
                      }
                    }

                    checkIfValid(); // Validate the current arrangement
                  });
                },
                builder: (context, accepted, rejected) {
                  return Container(
                    width: dropZoneWidth, // Width accommodates up to two blocks
                    height: dropZoneHeight, // Maintain consistent height
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
                            image: block == 'blue' ? pillBlue : pillRed,
                            width: spawnPillWidth,
                            height: spawnPillHeight,
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (gameState.currentLevel >= 3)
              Positioned(
                left: leftDropZonePosition2.dx,
                // Dynamically calculated x-position
                top: leftDropZonePosition2.dy,
                // Dynamically calculated y-position
                child: DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      // Allow up to 2 blocks
                      if (_droppedBlockThird.length < 2) {
                        _droppedBlockThird.add(
                            data); // Add the new block to the list
                        _blockColor = null; // Clear the draggable block's state
                      }
                      checkIfValid(); // Validate the current arrangement
                    });
                  },
                  builder: (context, accepted, rejected) {
                    return Container(
                      width: dropZoneWidth,
                      // Width accommodates up to two blocks
                      height: dropZoneHeight,
                      // Maintain consistent height
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // Outline color
                          width: 3.0, // Outline thickness
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _droppedBlockThird.map((block) {
                            return Image(
                              image: block == 'blue' ? pillBlue : pillRed,
                              width: spawnPillWidth,
                              height: spawnPillHeight,
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (gameState.currentLevel >= 3)
              Positioned(
                left: rightDropZonePosition2.dx,
                // Dynamically calculated x-position
                top: rightDropZonePosition2.dy,
                // Dynamically calculated y-position
                child: DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      if (_droppedBlockFourth.length < 2) {
                        _droppedBlockFourth.add(
                            data); // Add the new block to the list
                        _blockColor = null;
                      }
                      checkIfValid(); // Validate the current arrangement
                    });
                  },
                  builder: (context, accepted, rejected) {
                    return Container(
                      width: dropZoneWidth,
                      // Width accommodates up to two blocks
                      height: dropZoneHeight,
                      // Maintain consistent height
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // Outline color
                          width: 3.0, // Outline thickness
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _droppedBlockFourth.map((block) {
                            return Image(
                              image: block == 'blue' ? pillBlue : pillRed,
                              width: spawnPillWidth,
                              height: spawnPillHeight,
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (gameState.currentLevel >= 4)
              Positioned(
                left: leftDropZonePosition3.dx,
                // Dynamically calculated x-position
                top: leftDropZonePosition3.dy,
                // Dynamically calculated y-position
                child: DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      if (_droppedBlockFifth.length < 2) {
                        _droppedBlockFifth.add(
                            data); // Add the new block to the list
                        _blockColor = null;
                      }
                      checkIfValid(); // Validate the current arrangement
                    });
                  },
                  builder: (context, accepted, rejected) {
                    return Container(
                      width: dropZoneWidth,
                      // Width accommodates up to two blocks
                      height: dropZoneHeight,
                      // Maintain consistent height
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // Outline color
                          width: 3.0, // Outline thickness
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _droppedBlockFifth.map((block) {
                            return Image(
                              image: block == 'blue' ? pillBlue : pillRed,
                              width: spawnPillWidth,
                              height: spawnPillHeight,
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (gameState.currentLevel >= 4)
              Positioned(
                left: rightDropZonePosition3.dx,
                // Dynamically calculated x-position
                top: rightDropZonePosition3.dy,
                // Dynamically calculated y-position
                child: DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      if (_droppedBlockSixth.length < 2) {
                        _droppedBlockSixth.add(
                            data); // Add the new block to the list
                        _blockColor = null;
                      }
                      checkIfValid(); // Validate the current arrangement
                    });
                  },
                  builder: (context, accepted, rejected) {
                    return Container(
                      width: dropZoneWidth,
                      // Width accommodates up to two blocks
                      height: dropZoneHeight,
                      // Maintain consistent height
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // Outline color
                          width: 3.0, // Outline thickness
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _droppedBlockSixth.map((block) {
                            return Image(
                              image: block == 'blue' ? pillBlue : pillRed,
                              width: spawnPillWidth,
                              height: spawnPillHeight,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateDropZonePositions(); // Calculate chromatid position
    });
  }

  int _currentDialogIndex = 0; // Tracks the current dialog

  List<String> dialogContents = [
    "Welcome to the minigame! Here's how to play...",
    "Tap on the red button to generate an allele. \n"
        "Colors are determined randomly.",
    "Drag the allele to place them in the rectangle boxes.",
    "If both blocks are the same color in the chromosome, a trait will be generated, if not the the trait will be generated randomly.",
    "In the following levels, this will be the same mechanics \n"
        "but the number of blocks generated will increase as well as the number of rectangle boxes.",
    "If ever you make a mistake, you can tap on the reset button to clear everything and start over."
  ];

  List<String> imageContent = [
    "",
    "assets/images/red_button.png",
    "assets/images/drag_tutorial.png",
    "assets/images/dropzone_tutorial.png",
    "assets/images/difficulty_tutorial.png",
    "assets/images/button_reset.png"
  ];

  void _showMultiStepDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("How to play"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ensures dialog fits content size
            children: [
              Text(dialogContents[_currentDialogIndex]), // Text content
              const SizedBox(height: 10), // Adds spacing
              if (imageContent[_currentDialogIndex]
                  .isNotEmpty) // Conditional image display
                Expanded( // Makes the image fill available space
                  child: Image.asset(
                      imageContent[_currentDialogIndex], fit: BoxFit.fitHeight),
                ),
            ],
          ),
          actions: [
            // Previous button (disabled if at the first dialog)
            TextButton(
              onPressed: _currentDialogIndex > 0
                  ? () {
                _currentDialogIndex--;
                Navigator.pop(context);
                _showMultiStepDialog(context);
              }
                  : null,
              child: Text("Previous"),
            ),
            // Next button (disabled if at the last dialog)
            TextButton(
              onPressed: _currentDialogIndex < dialogContents.length - 1
                  ? () {
                _currentDialogIndex++;
                Navigator.pop(context);
                _showMultiStepDialog(context);
              }
                  : null,
              child: Text("Next"),
            ),
            // Close button
            TextButton(
              onPressed: () {
                _currentDialogIndex = 0;
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void updateDropZonePositions() {
    final RenderBox chromatidBox =
    chromatidKey.currentContext?.findRenderObject() as RenderBox;
    final Offset position = chromatidBox.localToGlobal(Offset.zero);
    final Size size = chromatidBox.size;

    setState(() {
      leftDropZonePosition1 =
          Offset(position.dx, position.dy + (size.height / 2));
      rightDropZonePosition1 = Offset(
          position.dx + (size.width / 2), position.dy + (size.height / 2));

      leftDropZonePosition2 =
          Offset(position.dx, position.dy + (spawnPillHeight * 1.5));
      rightDropZonePosition2 = Offset(position.dx + (size.width / 2),
          position.dy + (spawnPillHeight * 1.5));
      leftDropZonePosition3 =
          Offset(position.dx, position.dy + (spawnPillHeight / 2));
      rightDropZonePosition3 = Offset(
          position.dx + (size.width / 2), position.dy + (spawnPillHeight / 2));
    });
  }

}