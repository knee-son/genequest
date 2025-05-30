import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:genequest_app/screens/level_selector_screen.dart';
import 'package:genequest_app/screens/minigame_screen.dart';

class MiniGameScreenTransition extends StatefulWidget {
  final int levelNum;

  const MiniGameScreenTransition({required this.levelNum, super.key});

  @override
  State<MiniGameScreenTransition> createState() =>
      _MiniGameScreenTransitionState();
}

class _MiniGameScreenTransitionState extends State<MiniGameScreenTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomAnimation;
  late Animation<double> _whiteOutAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Zoom-in effect
    _zoomAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // White-out effect
    _whiteOutAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Start animation
    _controller.forward().then((_) {
      // Play transition sound and navigate
      if (widget.levelNum == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LevelSelectorScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MiniGameScreen(widget.levelNum)),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 0),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Zoom & Shake
                Transform.scale(
                  scale: _zoomAnimation.value,
                  child: child,
                ),

                // White-Out Overlay
                Opacity(
                  opacity: _whiteOutAnimation.value,
                  child: Container(color: Colors.white),
                ),
              ],
            );
          },
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.all(16), // Adds some spacing around the text
              color: Colors.white, // White background
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Allele",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'WinkySans',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Mix and Match!",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'WinkySans',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
