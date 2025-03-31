import 'package:flame_audio/flame_audio.dart';
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

class TitleScreenState extends State<TitleScreen> {
  @override
  void initState() {
    super.initState();
    _playMusic();
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
    FlameAudio.bgm.stop(); // Stop music when leaving the screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GENEQUEST',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 32,
                fontWeight: FontWeight.bold,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Play'),
            ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Hot-load Level'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => MiniGameScreen(1)),
                // );

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameOverScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Mini game'),
            ),
          ],
        ),
      ),
    );
  }
}
