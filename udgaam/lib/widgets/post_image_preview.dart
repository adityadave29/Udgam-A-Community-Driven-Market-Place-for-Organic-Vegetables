import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/post_controller.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class PostImagePreview extends StatelessWidget {
  PostImagePreview({super.key});
  final PostController controller = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    // Check if the file is an image or video
    final file = controller.image.value!;
    final isVideo = file.path.endsWith('.mp4') ||
        file.path.endsWith('.mov'); // or use MIME type checking

    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isVideo
              ? VideoPlayerWidget(file: file) // Video preview widget
              : Image.file(
                  // Image preview widget
                  file,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: CircleAvatar(
            backgroundColor: Colors.white38,
            child: IconButton(
              onPressed: () {
                controller.image.value = null;
                controller.content.value = '';
              },
              icon: Icon(Icons.close),
            ),
          ),
        ),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File file;
  const VideoPlayerWidget({super.key, required this.file});

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
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {
          _totalDuration = _controller.value.duration.inSeconds.toDouble();
        });
      })
      ..addListener(() {
        if (_controller.value.isInitialized) {
          setState(() {
            _currentPosition = _controller.value.position.inSeconds.toDouble();
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
                Row(
                  children: [
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 10,
                      right: 10,
                      child: Slider(
                        value: _currentPosition,
                        min: 0.0,
                        max: _totalDuration,
                        onChanged: (value) {
                          _seekTo(value);
                        },
                      ),
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
