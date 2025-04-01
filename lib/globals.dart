class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int currentLevel = 0; // depends on game
  int _level = 0; // levels unlocked

  int maxLevelReached = 0;
  static const int _minLevel = 0;
  static const int _maxLevel = 4;

  List<Trait> savedTraits = [];

  final Map<int, String> _levelNames = {
    0: "Level0.tmx",
    1: "Level1.tmx",
    2: "Level2.tmx",
    3: "Level3.tmx",
    4: "Level4.tmx",
  };

  final List<Trait> traits = List.unmodifiable([
    Trait(
      name: 'gender',
      traits: ['Male', 'Female'],
      difficulty: 'peaceful',
      level: 0,
      selectedTrait: ""
    ),
    Trait(
      name: 'skin',
      traits: ['Fair', 'Brown'],
      difficulty: 'easy',
      level: 1,
      selectedTrait: ""
    ),
    Trait(
      name: 'eyes',
      traits: ['Round', 'Almond'],
      difficulty: 'medium',
      level: 2,
      selectedTrait: ""
    ),
    Trait(
      name: 'height',
      traits: ['Average', 'Tall'],
      difficulty: 'hard',
      level: 3,
      selectedTrait: ""
    ),
    Trait(
      name: 'hair',
      traits: ['Black', 'Blonde'],
      difficulty: 'expert',
      level: 4,
      selectedTrait: ""
    ),
  ]);

  int get level => _level;
  String get levelName => _levelNames[_level] ?? "Unknown Level";

  String getLevelName(int levelNum) {
    return _levelNames[levelNum] ?? "Unknown Level";
  }
  // hard coded for testing purposes
  final List<Trait> randomTraits = List.unmodifiable([
    Trait(
        name: 'gender',
        traits: ['Male', 'Female'],
        difficulty: 'peaceful',
        level: 0,
        selectedTrait: "Female"
    ),
    Trait(
        name: 'skin',
        traits: ['Fair', 'Brown'],
        difficulty: 'easy',
        level: 1,
        selectedTrait: "Brown"
    ),
    Trait(
        name: 'eyes',
        traits: ['Round', 'Almond'],
        difficulty: 'medium',
        level: 2,
        selectedTrait: "Round"
    ),
    Trait(
        name: 'height',
        traits: ['Average', 'Tall'],
        difficulty: 'hard',
        level: 3,
        selectedTrait: "Average"
    ),
    Trait(
        name: 'hair',
        traits: ['Black', 'Blonde'],
        difficulty: 'expert',
        level: 4,
        selectedTrait: "Black"
    ),
  ]);

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

class Trait {
  final String name;
  final List<String> traits;
  final String difficulty;
  final int level;
  String selectedTrait;

  Trait({
    required this.name,
    required this.traits,
    required this.difficulty,
    required this.level,
    this.selectedTrait = ""
  });

  // Method to get the default trait
  String get defaultTrait {
    if (name == "gender") {
      return "Male";
    }
    return traits.isNotEmpty ? traits.first : "No traits available";
  }

  @override
  String toString() {
    return 'Level: $level, '
        'Traits: $traits, '
        'Difficulty: $difficulty,'
        'selectedTrait: $selectedTrait';
  }

}

final gameState = GameState(); // Global instance
