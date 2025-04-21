import 'package:flame_audio/flame_audio.dart';

class MusicManager {
  static bool _isAudioInitialized = false;
  static Future<void> initialize() async {
    if (!_isAudioInitialized) {
      await FlameAudio.bgm.initialize(); // Initialize BGM system
      await FlameAudio.audioCache.loadAll([
        'music1.mp3',
        'jump.wav',
        'oof.mp3',
        'slash.wav',
        'tada.mp3'
      ]);
      _isAudioInitialized = true;
    }
  }


  static void play(String asset, {double volume = 0.5}) {
    if (!_isAudioInitialized){
      initialize();
    }
    FlameAudio.bgm.play(asset, volume: volume);
  }

  static void stop() {
    if (!_isAudioInitialized){
      initialize();
    }
    FlameAudio.bgm.stop();
  }

  static void dispose() {
    if (!_isAudioInitialized){
      initialize();
    }
    FlameAudio.bgm.dispose();
  }
}