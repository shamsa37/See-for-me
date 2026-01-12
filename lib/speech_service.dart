// speech_service.dart

import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef SpeechTextCallback = void Function(String words);

class SpeechService {
  // ---- Singleton (only one instance) ----
  SpeechService._internal();
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;

  final stt.SpeechToText _speech = stt.SpeechToText();
  SpeechTextCallback? _onResult;

  bool _isInitialized = false;

  // ---- Initialize + set callback ----
  Future<void> init(SpeechTextCallback callback) async {
    _onResult = callback;

    if (!_isInitialized) {
      bool available = await _speech.initialize(
        onError: (e) => print("Speech error: $e"),
        onStatus: (s) => print("Speech status: $s"),
      );

      _isInitialized = available;
      print("Speech initialized: $_isInitialized");
    }
  }

  // ---- Start listening ----
  void startListening() {
    if (!_isInitialized) return;

    _speech.listen(
      onResult: (result) {
        if (_onResult != null) {
          _onResult!(result.recognizedWords);
        }
      },
    );
  }

  // ---- Stop listening ----
  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
}
