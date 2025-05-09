import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:udgaam/utils/env.dart';

class TexttoSpeech {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> generateAudio(String text) async {
    if (text.isEmpty) return;

    final url = Uri.parse(
        "https://api.elevenlabs.io/v1/text-to-speech/JBFqnCBsd6RMkjVDRZzb");
    final headers = {
      "Content-Type": "application/json",
      "xi-api-key": Env.elevenlabs,
    };
    final body = jsonEncode({
      "text": text,
      "model_id": "eleven_multilingual_v2",
      "voice_id": "JBFqnCBsd6RMkjVDRZzb",
      "output_format": "mp3_44100_128",
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      await _audioPlayer.play(BytesSource(bytes));
    } else {
      print("Error: ${response.body}");
    }
  }
}
