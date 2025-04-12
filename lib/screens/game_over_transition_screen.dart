import 'package:flutter/material.dart';
import 'package:genequest_app/screens/game_over_screen.dart';

class GameOverTransitionScreen extends StatefulWidget {
  @override
  _GameOverTransitionScreenState createState() =>
      _GameOverTransitionScreenState();
}

class _GameOverTransitionScreenState extends State<GameOverTransitionScreen> {
  int currentStage = 0;

  final List<String> stages = [
    'The chromatid has now finally been merged with its sister.',
    'The chromatid\'s great adventure has come to an end. All its traits have been acquired.',
    'You are now born!'
  ];

  void goToNextStage() {
    setState(() {
      if (currentStage + 1 < stages.length) {
        currentStage++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameOverScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: goToNextStage,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          // Ensures the Container fills the screen
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Text(
            stages[currentStage],
            style: const TextStyle(
              fontSize: 36,
              fontFamily: 'OpenSans'
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GameOverTransitionScreen(),
  ));
}
