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
    'AFTER COMPLETING the gene codes, YOUR GENETICAL TRAITS ARE INHERITED.',
    'YOU ARE NOW BORN.'
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
          // Ensures the Container fills the screen
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Text(
            stages[currentStage],
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
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
