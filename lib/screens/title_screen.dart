import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genequest_app/screens/game_over_screen.dart';
import 'game_screen.dart';
import 'level_selector_screen.dart';
import 'minigame_screen.dart'; // Import the GameScreen

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  TitleScreenState createState() => TitleScreenState();
}

class TitleScreenState extends State<TitleScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _growController;
  late Animation<double> _growAnimation;

  @override
  void initState() {
    super.initState();
    _playMusic();

    // Initialize the first controller (for movement)
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10), // Speed of movement
    )..repeat(reverse: true); // Makes it move back and forth
    _animation = Tween<double>(begin: -50, end: 50).animate(_controller);

    // Initialize the second controller (for growth)
    _growController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _growAnimation = Tween<double>(begin: 40, end: 64).animate(
      CurvedAnimation(
        parent: _growController,
        curve: Curves.easeInOut, // Smooth growth and shrink
      ),
    );
  }

  void _playMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play(
      'music2.mp3',
      volume: 0.5,
    );
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Backdrop
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    _animation.value, _animation.value), // Move horizontally
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/backdrop.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          // Animated Title and Buttons
          AnimatedBuilder(
            animation: _growAnimation,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'GENE',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: _growAnimation.value *
                                  1.4, // Adjust font size with _growAnimation
                              fontFamily: 'WinkySans',
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'QUEST!',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: _growAnimation
                                  .value, // Adjust font size with _growAnimation
                              fontFamily: 'WinkySans',
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LevelSelectorScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      foregroundColor: Color.fromARGB(255, 0, 0, 0),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Times New Roman',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Play'),
                  ),
                  if (kDebugMode) ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  GameScreen(0, levelName: "Level.tmx")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Hot-load Level'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MiniGameScreen(1)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Mini game'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GameOverScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Game Over Screen'),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
