import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:udgaam/utils/env.dart';

class VideoGeneratorInput extends StatefulWidget {
  const VideoGeneratorInput({super.key});

  @override
  State<VideoGeneratorInput> createState() => _VideoGeneratorInputState();
}

class _VideoGeneratorInputState extends State<VideoGeneratorInput> {
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  // final String apiKey = Env.elevenlabs;

  Future<void> generateAudio() async {
    String text = _textController.text.trim();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Text to Speech")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: "Enter text"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateAudio,
              child: Text("Generate"),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'dart:convert';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:audioplayers/audioplayers.dart';
// import 'package:udgaam/utils/env.dart';

// class VideoGeneratorInput extends StatefulWidget {
//   const VideoGeneratorInput({super.key});

//   @override
//   State<VideoGeneratorInput> createState() => _VideoGeneratorInputState();
// }

// class _VideoGeneratorInputState extends State<VideoGeneratorInput> {
//   final TextEditingController _textController = TextEditingController();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final String apiKey = Env.elevenlabs;

//   String? _audioPath;
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();

//     _audioPlayer.onDurationChanged.listen((Duration d) {
//       setState(() {
//         _duration = d;
//       });
//     });

//     _audioPlayer.onPositionChanged.listen((Duration p) {
//       setState(() {
//         _position = p;
//       });
//     });

//     _audioPlayer.onPlayerComplete.listen((_) {
//       setState(() {
//         _isPlaying = false;
//         _position = Duration.zero;
//       });
//     });
//   }

//   Future<void> generateAudio() async {
//     String text = _textController.text.trim();
//     if (text.isEmpty) return;

//     final url = Uri.parse(
//         "https://api.elevenlabs.io/v1/text-to-speech/JBFqnCBsd6RMkjVDRZzb");
//     final headers = {
//       "Content-Type": "application/json",
//       "xi-api-key": apiKey,
//     };
//     final body = jsonEncode({
//       "text": text,
//       "model_id": "eleven_multilingual_v2",
//       "voice_id": "JBFqnCBsd6RMkjVDRZzb",
//       "output_format": "mp3_44100_128",
//     });

//     final response = await http.post(url, headers: headers, body: body);

//     if (response.statusCode == 200) {
//       final bytes = response.bodyBytes;

//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/generated_audio.mp3';

//       final file = File(filePath);
//       await file.writeAsBytes(bytes);

//       print("Audio file saved at: $filePath");

//       setState(() {
//         _audioPath = filePath;
//       });

//       _playAudio();
//     } else {
//       print("Error: ${response.body}");
//     }
//   }

//   Future<void> _playAudio() async {
//     if (_audioPath == null) return;

//     if (_isPlaying) {
//       await _audioPlayer.pause();
//     } else {
//       await _audioPlayer.play(DeviceFileSource(_audioPath!));
//     }

//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   void _seekAudio(double value) {
//     final newPosition = Duration(seconds: value.toInt());
//     _audioPlayer.seek(newPosition);
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Text to Speech")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _textController,
//               decoration: InputDecoration(labelText: "Enter text"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: generateAudio,
//               child: Text("Generate"),
//             ),
//             if (_audioPath != null) ...[
//               SizedBox(height: 20),
//               Slider(
//                 value: _position.inSeconds.toDouble(),
//                 min: 0,
//                 max: _duration.inSeconds.toDouble(),
//                 onChanged: _seekAudio,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
//                   ),
//                   Text(
//                     "${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}",
//                   ),
//                 ],
//               ),
//               IconButton(
//                 icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//                 iconSize: 40,
//                 onPressed: _playAudio,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:udgaam/utils/env.dart';

// class VideoGeneratorInput extends StatefulWidget {
//   const VideoGeneratorInput({super.key});

//   @override
//   State<VideoGeneratorInput> createState() => _VideoGeneratorInputState();
// }

// class _VideoGeneratorInputState extends State<VideoGeneratorInput> {
//   final TextEditingController _textController = TextEditingController();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
//   String? _videoPath;
//   bool _isProcessing = false;
//   String apiKey = Env.elevenlabs;

//   Future<String?> generateAudio() async {
//     String text = _textController.text.trim();
//     if (text.isEmpty) return null;

//     final url = Uri.parse(
//         "https://api.elevenlabs.io/v1/text-to-speech/JBFqnCBsd6RMkjVDRZzb");
//     final headers = {
//       "Content-Type": "application/json",
//       "xi-api-key": apiKey,
//     };
//     final body = jsonEncode({
//       "text": text,
//       "model_id": "eleven_multilingual_v2",
//       "voice_id": "JBFqnCBsd6RMkjVDRZzb",
//       "output_format": "mp3_44100_128",
//     });

//     final response = await http.post(url, headers: headers, body: body);

//     if (response.statusCode == 200) {
//       final bytes = response.bodyBytes;
//       final dir = await getApplicationDocumentsDirectory();
//       String audioPath = "${dir.path}/generated_audio.mp3";
//       File audioFile = File(audioPath);
//       await audioFile.writeAsBytes(bytes);
//       return audioPath;
//     } else {
//       print("Error generating audio: ${response.body}");
//       return null;
//     }
//   }

//   Future<void> generateVideo() async {
//     setState(() => _isProcessing = true);

//     if (await Permission.storage.request().isGranted) {
//       String? audioPath = await generateAudio();
//       if (audioPath == null) {
//         setState(() => _isProcessing = false);
//         return;
//       }

//       final dir = await getApplicationDocumentsDirectory();
//       String videoPath = "${dir.path}/generated_video.mp4";

//       String commandToExecute =
//           "-loop 1 -i assets/farmer.png -i $audioPath -c:v libx264 -c:a aac -strict experimental -b:a 192k -pix_fmt yuv420p -shortest -y $videoPath";

//       await _flutterFFmpeg.execute(commandToExecute).then((rc) {
//         print('FFmpeg process exited with rc: $rc');
//         if (rc == 0) {
//           setState(() => _videoPath = videoPath);
//         }
//       });
//     }
//     setState(() => _isProcessing = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Text to Video Generator")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _textController,
//               decoration: InputDecoration(labelText: "Enter text"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isProcessing ? null : generateVideo,
//               child: _isProcessing
//                   ? CircularProgressIndicator()
//                   : Text("Generate Video"),
//             ),
//             SizedBox(height: 20),
//             _videoPath != null
//                 ? Column(
//                     children: [
//                       Text("Preview"),
//                       SizedBox(height: 10),
//                       Container(
//                         height: 200,
//                         width: double.infinity,
//                         child: VideoPlayerWidget(videoPath: _videoPath!),
//                       ),
//                     ],
//                   )
//                 : Container(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class VideoPlayerWidget extends StatelessWidget {
//   final String videoPath;
//   const VideoPlayerWidget({required this.videoPath, Key? key})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text("Video saved at: $videoPath"),
//     );
//   }
// }
