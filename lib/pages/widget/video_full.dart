import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/video_controller.dart';
import 'package:video_player/video_player.dart';

class MyVideoFull extends StatefulWidget {
  const MyVideoFull({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final VideoPlayerController controller;
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoFull> {
  bool _showController = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.black,
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.of(context).pop();
            },
            onTap: () {
              setState(() {
                _showController = !_showController;
              });
            },
            child: Stack(
              children: <Widget>[
                Center(
                  child: Hero(
                    tag: "player",
                    child: AspectRatio(
                      aspectRatio: widget.controller.value.aspectRatio,
                      child: VideoPlayer(widget.controller),
                    ),
                  ),
                ),
                _buildController(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildController(BuildContext context) {
    if (_showController) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.bottomLeft,
      child: MyVideoController(
        controller: widget.controller,
        fullscreen: true,
        onFullscreen: (_) {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
