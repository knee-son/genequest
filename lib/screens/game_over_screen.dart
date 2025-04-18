import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:genequest_app/globals.dart';
import 'package:genequest_app/screens/title_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: GameOverScreen(),
  ));
}

class GameOverScreen extends StatefulWidget {
  GameOverScreen({super.key});

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  List<String> selectedTraits = [];

  List<String> mSelectedTraits = [];
  AssetImage fullImagePath = AssetImage('assets/images/portraits');
  @override
  void initState() {
    super.initState();

    // Extract all selectedTrait values from randomTraits
    if (gameState.savedTraits.length == 5){
      selectedTraits =
          gameState.savedTraits.map((trait) => trait.selectedTrait).toList();
      mSelectedTraits = List.from(selectedTraits);

    } else {
      // default portrait for testing purposes
      selectedTraits =
          gameState.randomTraits.map((trait) => trait.selectedTrait).toList();
      mSelectedTraits = List.from(selectedTraits);
    }

    // Append the trait descriptions
    mSelectedTraits.asMap().forEach((index, element) {
      mSelectedTraits[index] = "$element ${gameState.traits[index].name[0].toUpperCase()}${gameState.traits[index].name.substring(1)}";
    });

    List<String> imageFiles = [
      "Female_Brown_Skin_Almond_Eyes_Average_Height_Black_Hair.png",
      "Female_Brown_Skin_Almond_Eyes_Tall_Height_Black_Hair.png",
      "Female_Brown_Skin_Almond_Eyes_Tall_Height_Blonde_Hair.png",
      "Female_Brown_Skin_Round_Eyes_Average_Height_Black_Hair.png",
      "Female_Brown_Skin_Round_Eyes_Average_Height_Blonde_Hair.png",
      "Female_Fair_Skin_Round_Eyes_Average_Height_Black_Hair.png",
      "Female_Fair_Skin_Round_Eyes_Average_Height_Blonde_Hair.png",
      "Female_Fair_Skin_Round_Eyes_Tall_Height_Black_Hair.png",
      "Female_Fair_Skin_Round_Eyes_Tall_Height_Blonde_Hair.png",
      "Male_Brown_Skin_Almond_Eyes_Average_Height_Black_Hair.png",
      "Male_Brown_Skin_Almond_Eyes_Tall_Height_Black_Hair.png",
      "Male_Brown_Skin_Almond_Eyes_Tall_Height_Blonde_Hair.png",
      "Male_Brown_Skin_Round_Eyes_Average_Height_Black_Hair.png",
      "Male_Brown_Skin_Round_Eyes_Average_Height_Blonde_Hair.png",
      "Male_Fair_Skin_Almond_Eyes_Average_Height_Black_Hair.png",
      "Male_Fair_Skin_Almond_Eyes_Average_Height_Blonde_Hair.png",
      "Male_Fair_Skin_Almond_Eyes_Tall_Height_Black_Hair.png",
      "Male_Fair_Skin_Almond_Eyes_Tall_Height_Blonde_Hair.png",
      "Male_Fair_Skin_Round_Eyes_Average_Height_Black_Hair.png",
      "Male_Fair_Skin_Round_Eyes_Average_Height_Blonde_Hair.png",
      "Male_Fair_Skin_Round_Eyes_Tall_Height_Black_Hair.png",
      "Male_Fair_Skin_Round_Eyes_Tall_Height_Blonde_Hair.png",
    ];
    // Find the matching image based on selectedTraits
    String? imageFilePath = findMatchingImage(selectedTraits, imageFiles);
    fullImagePath = AssetImage("assets/images/portraits/$imageFilePath");
  }

  String? findMatchingImage(
      List<String> selectedTraits, List<String> imageFiles) {
    // Iterate through all image file names
    for (String fileName in imageFiles) {
      // Check if the file name contains all selected traits
      bool matchesAllTraits =
          selectedTraits.every((trait) => fileName.contains(trait));
      if (matchesAllTraits) {
        return fileName; // Return the matching file name
      }
    }
    return null; // Return null if no match is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/congratulations_game_over.png'),
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stack to layer the image and the overlay text
              Stack(
                alignment: Alignment.center,
                children: [
                  // The image background
                  fullImagePath != null
                      ? Image(
                    image: fullImagePath,
                    width: 200,
                    height: 200,
                  )
                      : const Center(
                    child: Text(
                      'Error: Image not available',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
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
                'Acquired Traits: ${mSelectedTraits.join(', ')}', // Converts list into comma-separated string
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
    );
  }
}
