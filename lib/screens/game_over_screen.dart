import 'package:flutter/material.dart';
import 'package:genequest_app/globals.dart';
import 'package:genequest_app/screens/MusicManagerClass.dart';
import 'package:genequest_app/screens/title_screen.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  GameOverScreenState createState() => GameOverScreenState();
}

class GameOverScreenState extends State<GameOverScreen> {
  AssetImage fullImagePath = AssetImage(gameState.getTraitPath());
  AssetImage backgroundImagePath =
      const AssetImage('assets/images/congratulations_game_over.png');

  @override
  void initState() {
    super.initState();
    MusicManager.tadaSound.start();
  }

  @override
  void dispose() {
    // Clear the cached images
    backgroundImagePath.evict();
    fullImagePath.evict();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: backgroundImagePath,
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stack to layer the image and the overlay text
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // The image background
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          30), // Adjust the value for desired roundness
                      child: Image(
                        image: fullImagePath,
                        width: 200,
                        height: 200,
                        fit: BoxFit
                            .cover, // Ensures the image fits within the rounded area
                      ),
                    )
                  ],
                ),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Ribeye',
                    // Adding a shadow or background will improve readability if needed:
                    // shadows: [Shadow(blurRadius: 3, color: Colors.black45, offset: Offset(2, 2))],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5), // Adds spacing between texts
                Text(
                  'Acquired Traits: ${gameState.getTraitDescription()}', // Converts list into comma-separated string
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TitleScreen()),
                    );
                  },
                  child: const Text('Back to Main Menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
