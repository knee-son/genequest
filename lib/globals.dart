import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int traitState = 0;
  int currentLevel = 0; // depends on game
  int _maxLevelReached = kDebugMode ? 4 : 0; // 4 in debug mode, 0 otherwise

  static const int _minLevel = 0;
  static const int _maxLevel = 4;

  /// Load saved state from shared_preferences
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _maxLevelReached = prefs.getInt('_maxLevelReached') ?? _maxLevelReached;
    traitState = prefs.getInt('traitState') ?? traitState;
  }

  /// Save current state to shared_preferences
  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('_maxLevelReached', _maxLevelReached);
    await prefs.setInt('traitState', traitState);
  }

  final Map<int, String> _levelNames = {
    0: "Level0.tmx",
    1: "Level1.tmx",
    2: "Level2.tmx",
    3: "Level3.tmx",
    4: "Level4.tmx",
  };

  final List<Trait> traits = List.unmodifiable([
    Trait(
      name: 'Gender',
      options: ['Male', 'Female'],
    ),
    Trait(
      name: 'Skin',
      options: ['Fair', 'Brown'],
    ),
    Trait(
      name: 'Eyes',
      options: ['Round', 'Almond'],
    ),
    Trait(
      name: 'Height',
      options: ['Average', 'Tall'],
    ),
    Trait(
      name: 'Hair',
      options: ['Black', 'Blonde'],
    ),
  ]);

  int get level => _maxLevelReached;
  String get levelName => _levelNames[currentLevel] ?? "Unknown Level";

  String getLevelName(int levelNum) {
    return _levelNames[levelNum] ?? "Unknown Level";
  }

  void setLevel(int newLevel) {
    _maxLevelReached =
        newLevel.clamp(_minLevel, _maxLevel); // Ensures level stays in range
    saveState();
  }

  void incrementLevel() {
    if (_maxLevelReached == currentLevel) {
      setLevel(_maxLevelReached + 1); // Use the setter method
    }
  }

  void setTraitState({required bool isDominant}) {
    traitState &= ~(1 << currentLevel); // Clear bit
    traitState |= (isDominant ? 1 : 0) << currentLevel; // Set new value
    saveState();
  }

  String getTrait([int? level]) {
    int lvl = level ?? currentLevel;
    String name = traits[lvl].options[(traitState >> lvl) & 1];

    if (lvl != 0) {
      name += " ${traits[lvl].name}";
    }

    return name;
  }

  String getTraitDescription() {
    String name = "";

    for (int i = 0; i < 5; i++) {
      name += getTrait(i);

      if (i != 4) {
        name += ", ";
      }
    }

    return name;
  }

  String getTraitPath() {
    String path = "";

    for (int i = 0; i < 5; i++) {
      path += getTrait(i);

      if (i != 4) {
        path += " ";
      }
    }

    path = path.replaceAll(' ', '_');

    return "assets/images/portraits/$path.png";
  }
}

class Trait {
  final String name;
  final List<String> options;

  Trait({
    required this.name,
    required this.options,
  });
}

final gameState = GameState(); // Global instance
