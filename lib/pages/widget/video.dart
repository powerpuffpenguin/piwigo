import 'dart:io';

import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/fullscreen/fullscreen.dart';
import 'package:piwigo/pages/widget/video_full.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:ppg_ui/state/state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class MyVideo extends StatefulWidget {
  const MyVideo({
    Key? key,
    required this.image,
    required this.width,
    required this.height,
    required this.fullscreenState,
    required this.offset,
  }) : super(key: key);
  final int offset;
  final PageImage image;
  final double width;
  final double height;
  final FullscreenState<PageImage> fullscreenState;
  @override
  _MyVideoState createState() => _MyVideoState();
}

class _MyVideoState extends UIState<MyVideo> {
  PageImage get image => widget.image;
  double get width => widget.width;
  double get height => widget.height;
  VideoPlayerController? _controller;
  bool _playing = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }

    super.dispose();
  }

  void _videoListener() {
    if (_controller == null) {
      return;
    }
    final controller = _controller!;
    if (controller.value.isPlaying != _playing) {
      setState(() {
        _playing = controller.value.isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      return _buildAndroid(context, _controller!);
    }
    return _buildInit(context);
  }

  Widget _buildAndroid(context, VideoPlayerController controller) {
    if (!controller.value.isInitialized) {
      return _buildInit(context, disabled: true);
    }
    final duration = controller.value.duration;
    final text =
        '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return GestureDetector(
      onDoubleTap: () {
        widget.fullscreenState.offset = widget.offset;
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return MyVideoFull(
            fullscreenState: widget.fullscreenState,
            controller: controller,
          );
        }));
      },
      child: Stack(
        children: [
          Container(
            color: const Color.fromARGB(255, 0, 0, 0),
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            child: Hero(
              tag: "player",
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          _playing
              ? Container()
              : Container(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  width: widget.width,
                  height: widget.height,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(color: Colors.white),
                  ),
                ),
          _playing
              ? Container()
              : Container(
                  alignment: Alignment.center,
                  width: widget.width,
                  height: widget.height,
                  child: IconButton(
                    icon: const Icon(Icons.video_collection_rounded),
                    onPressed: () {
                      _controller?.play().then((_) {
                        _videoListener();
                      });
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInit(BuildContext context, {bool disabled = false}) {
    return Stack(
      children: [
        Image.network(
          image.derivatives.smallXX.url,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
        Container(
          alignment: Alignment.center,
          width: width,
          height: height,
          child: IconButton(
            icon: const Icon(Icons.video_collection_rounded),
            onPressed: disabled
                ? null
                : () {
                    if (Platform.isAndroid || Platform.isIOS) {
                      setState(() {
                        _controller = VideoPlayerController.network(image.url)
                          ..initialize().then((_) {
                            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                            aliveSetState(() {
                              _controller!.play();
                            });
                          });
                        _controller!.addListener(_videoListener);
                      });
                    } else {
                      launch(image.url);
                    }
                  },
          ),
        ),
      ],
    );
  }
}
