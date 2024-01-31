import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reconocimiento Voz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 27, 0, 74)),
        useMaterial3: true,
      ),
      home: Speech(),
    );
  }
}

class Speech extends StatefulWidget {
  Speech({Key? key}) : super(key: key);

  @override
  State<Speech> createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  SpeechToText _speech = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  bool _isListening = false;
  String _text = 'Presiona para hablar';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }

            // No llamamos a la función de TTS aquí, solo en el botón
          }),
          localeId: 'es-Es',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage('es-ES');
    await flutterTts.speak(text);
  }

  void _startTTS() {
    speak(_text);
  }

  void _stopTTS() {
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voz a audio'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _listen,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: _isListening ? Colors.red : Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: _isListening ? Colors.red : Colors.transparent,
                    spreadRadius: 10,
                    blurRadius: 18,
                    offset: Offset(0, 0),
                  )
                ],
              ),
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ),
          FloatingActionButton(
            onPressed: _startTTS,
            child: Icon(Icons.volume_up),
          ),
          FloatingActionButton(
            onPressed: _stopTTS,
            child: Icon(Icons.stop),
          ),
        ],
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text("[$_text]"),
        ),
      ),
    );
  }
}
