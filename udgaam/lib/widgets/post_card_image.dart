import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:udgaam/utils/helper.dart';

class ImagePostCard extends StatefulWidget {
  final String url;

  const ImagePostCard({super.key, required this.url});

  @override
  _ImagePostCardState createState() => _ImagePostCardState();
}

class _ImagePostCardState extends State<ImagePostCard> {
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
    return 'unknown'; // Default to unknown if we can't determine
  }

  @override
  void initState() {
    super.initState();
    mediaType = getMediaType(getS3Url(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: mediaType,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == 'unknown') {
          return Center(child: Text('Unable to load media.'));
        }

        // Based on the media type, either display an image or a video
        if (snapshot.data == 'video') {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: context.height * 0.60,
              maxWidth: context.width * 0.80,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: VideoPlayerWidget(url: getS3Url(widget.url)),
            ),
          );
        } else {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: context.height * 0.60,
              maxWidth: context.width * 0.80,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                getS3Url(widget.url),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          );
        }
      },
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
          isPlaying = true; // Set the video to "playing" state
        });
      })
      ..addListener(() {
        if (_controller.value.isInitialized) {
          setState(() {
            _currentPosition = _controller.value.position.inSeconds.toDouble();
            // If video reaches the end, restart
            if (_currentPosition == _totalDuration) {
              _controller.seekTo(Duration.zero); // Seek to the start
              _controller.play(); // Play the video again
            }
          });
        }
      });
  }

  // Play/Pause functionality
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

  // Seek functionality
  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _controller.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align controls at the bottom
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        // SizedBox(width: 5.0),
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
            ),
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
