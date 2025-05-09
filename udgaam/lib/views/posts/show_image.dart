import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:udgaam/utils/helper.dart';

class ShowImage extends StatefulWidget {
  final String image = Get.arguments;
  ShowImage({super.key});

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  late Future<String> mediaType;

  Future<String> getMediaType(String url) async {
    try {
      final response = await http.head(Uri.parse(url));

      final contentType = response.headers['content-type'];
      if (contentType != null) {
        if (contentType.contains('video')) {
          return 'video';
        } else if (contentType.contains('image')) {
          return 'image';
        }
      }
    } catch (e) {
      print('Error checking media type: $e');
    }
    return 'unknown'; // Default to unknown if media type can't be determined
  }

  @override
  void initState() {
    super.initState();
    mediaType = getMediaType(getS3Url(widget.image));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Media"),
      ),
      body: FutureBuilder<String>(
        future: mediaType,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == 'unknown') {
            return const Center(child: Text('Unable to load media.'));
          }

          if (snapshot.data == 'video') {
            return Center(
              child: VideoPlayerWidget(url: getS3Url(widget.image)),
            );
          } else {
            return Center(
              child: Image.network(
                getS3Url(widget.image),
                fit: BoxFit.contain,
              ),
            );
          }
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool isPlaying = false;
  double _currentPosition = 0.0;
  double _totalDuration = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _totalDuration = _controller.value.duration.inSeconds.toDouble();
          _controller.play(); // Auto-start video playback
          isPlaying = true;
        });
      })
      ..addListener(() {
        if (_controller.value.isInitialized) {
          setState(() {
            _currentPosition = _controller.value.position.inSeconds.toDouble();
            if (_currentPosition == _totalDuration) {
              _controller.seekTo(Duration.zero);
              _controller.play();
            }
          });
        }
      });
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      isPlaying = !isPlaying;
    });
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _controller.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      Slider(
                        value: _currentPosition,
                        min: 0.0,
                        max: _totalDuration,
                        onChanged: (value) {
                          _seekTo(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
