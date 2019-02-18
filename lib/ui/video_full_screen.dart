import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoFullScreen extends StatefulWidget {
  final String dataSource;

  VideoFullScreen({this.dataSource});

  @override
  State<StatefulWidget> createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
  VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset(widget.dataSource)
      ..initialize().then((void result) {
        controller.setLooping(true);
        controller.setVolume(1.0);
        controller.play();
      });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: 3 / 2,
          child: Hero(tag: controller, child: VideoPlayer(controller)),
        ),
      ),
    ));
  }
}
