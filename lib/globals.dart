class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int _level = 2; // Default level
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

  void setLevel(int newLevel) {
    _level =
        newLevel.clamp(_minLevel, _maxLevel); // Ensures level stays in range
  }

  String getLevelName(int levelNum) {
    return _levelNames[levelNum] ?? "Unknown Level";
  }
}

final gameState = GameState(); // Global instance
