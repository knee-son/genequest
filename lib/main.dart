import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Ensure this import is present
import 'screens/title_screen.dart'; // Import your title screen

void main() {
  // Ensure Flutter bindings are initialized before using system services
  WidgetsFlutterBinding.ensureInitialized();

  // Set the app to only allow landscape mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TitleScreen(),  // Your home screen widget
    );
  }
}
