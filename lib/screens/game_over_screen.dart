import 'package:flutter/material.dart';
import 'package:genequest_app/globals.dart';

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
  String? imageFilePath;

  @override
  void initState() {
    super.initState();

    // Extract all selectedTrait values from randomTraits
    selectedTraits = gameState.randomTraits
        .map((trait) => trait.selectedTrait)
        .toList();
    List<String> imageFiles = [
      "Almond_Eyes_Trait.png",
      "Black_Hair_Trait.png",
      "Cartoon_Network_style_character_tall_and_large_body.png",
      "Fair_Skin_Trait.png",
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
    imageFilePath = findMatchingImage(selectedTraits, imageFiles );
  }

  String? findMatchingImage(List<String> selectedTraits, List<String> imageFiles) {
    // Iterate through all image file names
    for (String fileName in imageFiles) {
      // Check if the file name contains all selected traits
      bool matchesAllTraits = selectedTraits.every((trait) => fileName.contains(trait));
      if (matchesAllTraits) {
        return fileName; // Return the matching file name
      }
    }
    return null; // Return null if no match is found
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wrap Image.asset in Flexible to adjust to the screen dynamically
            Flexible(
              child: Image.asset(
                "/images/portraits/$imageFilePath",
                fit: BoxFit.contain, // Adjust the image to fit within the available space
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Image not found!',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Return to the previous screen
              },
              child: const Text('Back to Main Menu'),
            ),
          ],
        ),
      ),
    );
  }
}