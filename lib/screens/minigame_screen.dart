import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genequest_app/globals.dart';
import 'package:genequest_app/screens/game_over_transition_screen.dart';
import 'level_selector_screen.dart';

// Asset cache to prevent reloading
final _imageCache = <String, ImageProvider>{};

ImageProvider _getCachedAsset(String path) {
  return _imageCache.putIfAbsent(path, () => AssetImage(path));
}

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
  // Cached assets
  late final ImageProvider combinedChromatid =
      _getCachedAsset('assets/images/combined_chromatid_new.png');
  late final ImageProvider redButton =
      _getCachedAsset('assets/images/red_button.png');
  late final ImageProvider resetButton =
      _getCachedAsset('assets/images/button_reset.png');
  late final ImageProvider pillBlue =
      _getCachedAsset('assets/images/pill_blue.png');
  late final ImageProvider pillRed =
      _getCachedAsset('assets/images/pill_red.png');

  // Game state
  String? _blockColor;
  final List<List<String?>> _droppedBlocks = List.generate(6, (_) => []);

  // UI constants
  static const double spawnPillWidth = 70;
  static const double spawnPillHeight = 60;
  static const double dropZoneWidth = 150;
  static const double dropZoneHeight = 50;

  // Layout tracking
  final GlobalKey chromatidKey = GlobalKey();
  final List<Offset> dropZonePositions = List.filled(6, Offset.zero);

  @override
  void dispose() {
    // Clear image cache when screen is disposed
    for (final provider in _imageCache.values) {
      (provider as AssetImage).evict();
    }
    _imageCache.clear();
    super.dispose();
  }

  void onButtonPressed() {
    setState(() {
      _blockColor = Random().nextBool() ? 'blue' : 'red';
    });
  }

  void onResetPressed() {
    setState(() {
      _blockColor = null;
      for (var blockList in _droppedBlocks) {
        blockList.clear();
      }
    });
  }

  void checkIfValid() {
    int isFinishFlags = 0;
    int totalBlueCount = 0;
    int totalRedCount = 0;

    final List<String> traitFilePathList = [
      "Almond_Eyes_Trait.png",
      "Round_Eyes_Trait.png",
      "Black_Hair_Trait.png",
      "Blonde_Hair_Trait.png",
      "Fair_Skin_Trait.png",
      "Brown_Skin_Trait.png",
      "Short_Height_Trait.png",
      "Tall_Height_Trait.png",
      "Male_Trait.png",
      "Female_Trait.png"
    ];

    // Check completion for each level
    final levelChecks = [
      [0, 1], // Level 1 checks
      [0, 1], // Level 2 checks
      [2, 3], // Level 3 checks
      [4, 5], // Level 4 checks
    ];

    final currentLevel = gameState.currentLevel;
    final checksToPerform = levelChecks.sublist(0, currentLevel.clamp(1, 4));

    for (final pair in checksToPerform) {
      final first = _droppedBlocks[pair[0]];
      final second = _droppedBlocks[pair[1]];
      if (first.length == 2 && second.length == 2) {
        final blueCount = first.where((e) => e == "blue").length +
            second.where((e) => e == "blue").length;
        final redCount = 4 - blueCount;
        totalBlueCount += blueCount;
        totalRedCount += redCount;
        isFinishFlags++;
      }
    }
    if (currentLevel == isFinishFlags) {
      _showTraitDialog(totalBlueCount, totalRedCount, traitFilePathList);
    }
  }

  void _showTraitDialog(int blueCount, int redCount, List<String> traitFiles) {
    gameState.setTraitState(isDominant: blueCount >= redCount);
    final fullImagePath = AssetImage(
        "assets/images/portraits/${gameState.getTrait().replaceAll(' ', '_')}_Trait.png");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trait Acquired'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Acquired Trait: ${gameState.getTrait()}'),
              const SizedBox(height: 10),
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30), // Apply rounded corners with a radius of 30
                  child: Image(
                    image: fullImagePath,
                    fit: BoxFit.cover, // Ensures the image scales properly within the available space
                    errorBuilder: (_, __, ___) => const Text('Image not available'),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (gameState.currentLevel == 4) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameOverTransitionScreen()),
                    (Route<dynamic> route) => false,
                  );
                } else {
                  gameState.incrementLevel();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LevelSelectorScreen()),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: kDebugMode
              ? Text('Mini Game - ${gameState.levelName}')
              : const SizedBox(),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showMultiStepDialog(context),
            ),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  Row(
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: onResetPressed,
                                child: Image(
                                  image: resetButton,
                                  width: 80,
                                  height: 100,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: onButtonPressed,
                                child: Image(
                                  image: redButton,
                                  width: 100,
                                  height: 150,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_blockColor != null)
                            Draggable(
                              data: _blockColor,
                              feedback: _buildPillRow(_blockColor!),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: _buildPillRow(_blockColor!),
                              ),
                              child: _buildPillRow(_blockColor!),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ..._buildDropZones(),
          ],
        ),
      ),
    );
  }

  Widget _buildPillRow(String color) {
    final image = color == 'blue' ? pillBlue : pillRed;
    return gameState.currentLevel == 1
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: image,
                width: spawnPillWidth,
                height: spawnPillHeight,
              ),
              Image(
                image: image,
                width: spawnPillWidth,
                height: spawnPillHeight,
              ),
            ],
          )
        : Image(
            image: image,
            width: spawnPillWidth,
            height: spawnPillHeight,
          );
  }

  List<Widget> _buildDropZones() {
    return List.generate(6, (index) {
      if (gameState.currentLevel < 3 && index > 1) return const SizedBox();
      if (gameState.currentLevel < 4 && index > 3) return const SizedBox();

      return Positioned(
        left: dropZonePositions[index].dx,
        top: dropZonePositions[index].dy,
        child: DragTarget<String>(
          onAccept: (data) {
            setState(() {
              if (_droppedBlocks[index].length < 2) {
                final count = gameState.currentLevel == 1 ? 2 : 1;
                for (int i = 0; i < count; i++) {
                  _droppedBlocks[index].add(data);
                }
                _blockColor = null;
              }
              checkIfValid();
            });
          },
          builder: (context, accepted, rejected) {
            return Container(
              width: dropZoneWidth,
              height: dropZoneHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3.0),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _droppedBlocks[index].map((block) {
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
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateDropZonePositions();
    });
  }

  int _currentDialogIndex = 0;
  List<String> _dialogContents = [
    "Welcome to the minigame! Here's how to play...",
    "Tap on the red button to generate an allele. \n"
        "Colors are determined randomly.",
    "Drag the allele to place them in the rectangle boxes.",
    "If both blocks are the same color in the chromosome, a trait will be generated, if not the the trait will be generated randomly.",
    "In the following levels, this will be the same mechanics \n"
        "but the number of blocks generated will increase as well as the number of rectangle boxes.",
    "If ever you make a mistake, you can tap on the reset button to clear everything and start over."
  ];
  List<String> _imageContent = [
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
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("How to play"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_dialogContents[_currentDialogIndex]),
                  const SizedBox(height: 10),
                  if (_imageContent[_currentDialogIndex].isNotEmpty)
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30), // Rounded corners
                        child: Image.asset(
                          _imageContent[_currentDialogIndex],
                          fit: BoxFit.cover, // Ensures proper scaling
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _currentDialogIndex > 0
                      ? () => setState(() => _currentDialogIndex--)
                      : null,
                  child: const Text("Previous"),
                ),
                TextButton(
                  onPressed: _currentDialogIndex < _dialogContents.length - 1
                      ? () => setState(() => _currentDialogIndex++)
                      : null,
                  child: const Text("Next"),
                ),
                TextButton(
                  onPressed: () {
                    _currentDialogIndex = 0;
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updateDropZonePositions() {
    final chromatidBox =
        chromatidKey.currentContext?.findRenderObject() as RenderBox?;
    if (chromatidBox == null) return;

    final position = chromatidBox.localToGlobal(Offset.zero);
    final size = chromatidBox.size;

    setState(() {
      // First pair of drop zones
      dropZonePositions[0] =
          Offset(position.dx, position.dy + (size.height / 2));
      dropZonePositions[1] = Offset(
          position.dx + (size.width / 2), position.dy + (size.height / 2));

      // Second pair (levels 3+)
      dropZonePositions[2] =
          Offset(position.dx, position.dy + (spawnPillHeight * 1.5));
      dropZonePositions[3] = Offset(position.dx + (size.width / 2),
          position.dy + (spawnPillHeight * 1.5));

      // Third pair (level 4)
      dropZonePositions[4] =
          Offset(position.dx, position.dy + (spawnPillHeight / 2));
      dropZonePositions[5] = Offset(
          position.dx + (size.width / 2), position.dy + (spawnPillHeight / 2));
    });
  }
}
