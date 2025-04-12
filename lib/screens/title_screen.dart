import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genequest_app/screens/game_over_screen.dart';
import 'game_over_transition_screen.dart';
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
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _growAnimation = Tween<double>(begin: 50, end: 64).animate(
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
    _growController.dispose();
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
              return Transform(
                transform: Matrix4.identity()
                  ..translate(_animation.value,
                      _animation.value) // Move horizontally and vertically
                  ..scale(1.4), // Scale based on animation value
                alignment: Alignment.center,
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
                    child: SizedBox(
                      width: 480, // Fixed width
                      height: 180, // Fixed height
                      child: Center(
                        child: Container(
                          width: _growAnimation.value * 6.6,
                          height: _growAnimation.value * 2.2,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 223, 215, 235),
                            border: Border.all(
                              color: const Color.fromARGB(
                                  255, 4, 1, 19), // Border color
                              width: 10, // Border thickness
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'GENE',
                                      style: TextStyle(
                                        color:
                                            const Color.fromARGB(255, 47, 9, 2),
                                        fontSize: _growAnimation.value * 1.3,
                                        fontFamily: 'WinkySans',
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    Text(
                                      'QUEST!',
                                      style: TextStyle(
                                        color:
                                            const Color.fromARGB(255, 47, 9, 2),
                                        fontSize: _growAnimation.value,
                                        fontFamily: 'WinkySans',
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(-35, -25),
                                child: Image.asset(
                                  'assets/images/chromosome_art.png', // Replace with your image path
                                  fit: BoxFit.contain, // Adjust as needed
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LevelSelectorScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 255, 145, 2), // Background color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'WinkySans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Play!'),
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
                              builder: (context) => GameOverTransitionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'WinkySans',
                        ),
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
