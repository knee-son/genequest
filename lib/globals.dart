class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int currentLevel = 0; // depends on game
  int _level = 0; // levels unlocked
  static const int _minLevel = 0;
  static const int _maxLevel = 4;

  final Map<int, String> _levelNames = {
    0: "Level0.tmx",
    1: "Level1.tmx",
    2: "Level2.tmx",
    3: "Level3.tmx",
    4: "Level4.tmx",
  };
  int get level => _level;
  String get levelName => _levelNames[_level] ?? "Unknown Level";

  String getLevelName(int levelNum) {
    return _levelNames[levelNum] ?? "Unknown Level";
  }

  void setLevel(int newLevel) {
    _level =
        newLevel.clamp(_minLevel, _maxLevel); // Ensures level stays in range
  }

  void incrementLevel() {
    if (_level == currentLevel) {
      setLevel(_level + 1); // Use the setter method
    }
  }
}

final gameState = GameState(); // Global instance
