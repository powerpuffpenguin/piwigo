import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayerHero extends StatelessWidget {
  const MyVideoPlayerHero({
    Key? key,
    required this.tag,
    required this.controller,
  }) : super(key: key);
  final String tag;
  final VideoPlayerController controller;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }
}
