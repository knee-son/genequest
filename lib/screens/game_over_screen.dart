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
  AssetImage fullImagePath = AssetImage('assets/images/portrait');
  // AssetImage forwardButtonImage = const AssetImage('assets/images/portrait/');
  @override
  void initState() {
    super.initState();

    // Extract all selectedTrait values from randomTraits
    if (gameState.savedTraits.length == 4){
      selectedTraits =
          gameState.savedTraits.map((trait) => trait.selectedTrait).toList();
    } else {
      selectedTraits =
          gameState.randomTraits.map((trait) => trait.selectedTrait).toList();
    }
    selectedTraits =
        gameState.randomTraits.map((trait) => trait.selectedTrait).toList();
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
      appBar: AppBar(
        title: const Text('Game Over'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wrap Image.asset in Flexible to adjust to the screen dynamically
            Flexible(
              child: fullImagePath != null
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
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TitleScreen(),
                  ),
                );
              },
              child: const Text('Back to Main Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
