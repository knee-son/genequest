import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'level_selector_screen.dart';
import 'package:collection/collection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.images.loadAll([
    'assets/images/chromatid.png',
    'assets/images/sister_chromatid.png',
    'assets/images/combined_chromatid.png',
    'assets/images/red_button.png',
    'assets/images/block_blue.png',
    'assets/images/block_red.png'
  ]);
  runApp(MiniGameScreen("Level1.tmx")); // Pass levelName when initializing the screen
}

class MiniGameScreen extends StatefulWidget {
  final String levelName; // Accept levelName as a parameter

  const MiniGameScreen(this.levelName, {super.key}); // Constructor to initialize levelName

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  String? _blockColor; // Tracks the color of the block to spawn
  List<String?> _droppedBlockFirst = [];
  List<String?> _droppedBlockSecond = []; // Tracks the block dropped into the first drop zone// Tracks the block dropped into the second drop zone

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
    final listEquality = const ListEquality().equals;
    if (_droppedBlockFirst.length == 2 &&
        _droppedBlockSecond.length == 2 &&
        listEquality(_droppedBlockFirst, _droppedBlockSecond.reversed.toList())) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LevelSelectorScreen(widget.levelName)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Mini Game - ${widget.levelName}'), // Display levelName dynamically
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
                      Image.asset(
                        'assets/images/combined_chromatid.png',
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
                                  Image.asset(
                                    _blockColor == 'blue'
                                        ? 'assets/images/block_blue.png'
                                        : 'assets/images/block_red.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                  Image.asset(
                                    _blockColor == 'blue'
                                        ? 'assets/images/block_blue.png'
                                        : 'assets/images/block_red.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                ],
                              )
                                  : Image.asset(
                                _blockColor == 'blue'
                                    ? 'assets/images/block_blue.png'
                                    : 'assets/images/block_red.png',
                                width: 100,
                                height: 100,
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: widget.levelName == "Level1.tmx"
                                    ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      _blockColor == 'blue'
                                          ? 'assets/images/block_blue.png'
                                          : 'assets/images/block_red.png',
                                      width: 100,
                                      height: 100,
                                    ),
                                    Image.asset(
                                      _blockColor == 'blue'
                                          ? 'assets/images/block_blue.png'
                                          : 'assets/images/block_red.png',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ],
                                )
                                    : Image.asset(
                                  _blockColor == 'blue'
                                      ? 'assets/images/block_blue.png'
                                      : 'assets/images/block_red.png',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              child: widget.levelName == "Level1.tmx"
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    _blockColor == 'blue'
                                        ? 'assets/images/block_blue.png'
                                        : 'assets/images/block_red.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                  Image.asset(
                                    _blockColor == 'blue'
                                        ? 'assets/images/block_blue.png'
                                        : 'assets/images/block_red.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                ],
                              )
                                  : Image.asset(
                                _blockColor == 'blue'
                                    ? 'assets/images/block_blue.png'
                                    : 'assets/images/block_red.png',
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
                            onTap: onButtonPressed, // Trigger the logic to spawn a block
                            child: Image.asset(
                              'assets/images/red_button.png',
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
                    if (_droppedBlockFirst.length < 2 && widget.levelName != 'Level1.tmx') { // Allow up to 2 blocks
                      _droppedBlockFirst.add(data); // Add the new block to the list
                      _blockColor = null; // Clear the draggable block's state
                    } else {
                      _droppedBlockFirst.add(data); // Add the new block to the list
                      _droppedBlockFirst.add(data); // Add the new block to the list
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
                          return Image.asset(
                            block == 'blue'
                                ? 'assets/images/block_blue.png'
                                : 'assets/images/block_red.png',
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
                    if (_droppedBlockSecond.length < 2 && widget.levelName != 'Level1.tmx') { // Allow up to 2 blocks
                      _droppedBlockSecond.add(data); // Add the new block to the list
                      _blockColor = null; // Clear the draggable block's state
                    } else {
                      _droppedBlockSecond.add(data); // Add the new block to the list
                      _droppedBlockSecond.add(data); // Add the new block to the list
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
                          return Image.asset(
                            block == 'blue'
                                ? 'assets/images/block_blue.png'
                                : 'assets/images/block_red.png',
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