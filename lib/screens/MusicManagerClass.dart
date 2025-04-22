import 'package:flame_audio/flame_audio.dart';

class MusicManager {
  static bool _isAudioInitialized = false;
  static bool _isMinigameAudioInitialized = false;

  static late AudioPool jumpSound;
  static late AudioPool oofSound;
  static late AudioPool bubbleUpSound;
  static late AudioPool tadaSound;
  static late AudioPool slashSound;
  static late AudioPool thudSound;

  static late AudioPool clickSound;
  static late AudioPool confirmSound;

  static Future<void> initialize() async {
    if (!_isAudioInitialized) {
      await FlameAudio.bgm.initialize(); // Initialize BGM system

      // Load background music only (pool not needed)
      await FlameAudio.audioCache.loadAll([
        'music1.mp3',
      ]);

      // Create sound effect pools
      jumpSound = await AudioPool.create(
        source: AssetSource('audio/jump.wav'),
        maxPlayers: 3,
      );

      oofSound = await AudioPool.create(
        source: AssetSource('audio/oof.mp3'),
        maxPlayers: 3,
      );

      bubbleUpSound = await AudioPool.create(
        source: AssetSource('audio/bubble_up.wav'),
        maxPlayers: 3,
      );

      tadaSound = await AudioPool.create(
        source: AssetSource('audio/tada.mp3'),
        maxPlayers: 3,
      );

      slashSound = await AudioPool.create(
        source: AssetSource('audio/slash.wav'),
        maxPlayers: 3,
      );

      thudSound = await AudioPool.create(
        source: AssetSource('audio/thud.wav'),
        maxPlayers: 3,
      );

      _isAudioInitialized = true;
    }
  }

  static Future<void> initializeForMinigame() async {
    if (!_isMinigameAudioInitialized) {
      await FlameAudio.bgm.initialize(); // Initialize BGM system

      // Load background music only (pool not needed)
      await FlameAudio.audioCache.loadAll([
        'music5.mp3',
      ]);

      // Create sound effect pools
      clickSound = await AudioPool.create(
        source: AssetSource('audio/click.mp3'),
        maxPlayers: 3,
      );

      confirmSound = await AudioPool.create(
        source: AssetSource('audio/confirm.wav'),
        maxPlayers: 3,
      );

      tadaSound = await AudioPool.create(
        source: AssetSource('audio/tada.mp3'),
        maxPlayers: 3,
      );

      _isMinigameAudioInitialized = true;
    }
  }

  static void play(String asset, {double volume = 0.5}) {
    if (!_isAudioInitialized || !_isMinigameAudioInitialized) {
      initialize();
    }
    FlameAudio.bgm.play(asset, volume: volume);
  }

  static void stop() {
    if (!_isAudioInitialized || !_isMinigameAudioInitialized) {
      initialize();
    }
    FlameAudio.bgm.stop();
  }

  static void dispose() {
    if (!_isAudioInitialized || !_isMinigameAudioInitialized) {
      initialize();
    }
    FlameAudio.bgm.dispose();
  }
}
