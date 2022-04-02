import 'dart:io';

import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/video/video_manage.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/utils/path.dart';
import 'package:ppg_ui/state/state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class MyVideo extends StatefulWidget {
  const MyVideo({
    Key? key,
    required this.image,
    required this.width,
    required this.height,
    required this.onFullscreen,
  }) : super(key: key);
  final PageImage image;
  final double width;
  final double height;
  final VoidCallback onFullscreen;
  @override
  _MyVideoState createState() => _MyVideoState();
}

class _MyVideoState extends UIState<MyVideo> {
  PageImage get image => widget.image;
  double get width => widget.width;
  double get height => widget.height;
  MyPlayerController? _player;
  VideoPlayerController? _videoPlayerController;
  bool _playing = false;
  _load() {
    if (_player != null) {
      return;
    }
    _player = MyVideoPlayerManage.get(image.url);
    _initVideoPlayerController(_player!);
  }

  _initVideoPlayerController(MyPlayerController player) async {
    try {
      final controller = await player.initialize();
      checkAlive();
      await controller.play();
      checkAlive();
      if (_player != null) {
        setState(() {
          _videoPlayerController = controller;

          _playing = controller.value.isPlaying;
          controller.addListener(_videoListener);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    final player = _player;
    if (player != null) {
      _player = null;
      _videoPlayerController?.removeListener(_videoListener);
      MyVideoPlayerManage.put(player);
    }
    super.dispose();
  }

  void _videoListener() {
    if (_videoPlayerController == null) {
      return;
    }
    final controller = _videoPlayerController!;
    if (controller.value.isPlaying != _playing) {
      setState(() {
        _playing = controller.value.isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_videoPlayerController != null) {
      final controller = _videoPlayerController!;
      return GestureDetector(
        onDoubleTap: widget.onFullscreen,
        onTap: () {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        },
        child: _buildVideo(context, _videoPlayerController!),
      );
    }
    return GestureDetector(
      onTap: widget.onFullscreen,
      child: _buildInit(context),
    );
  }

  Widget _buildVideo(
    BuildContext context,
    VideoPlayerController controller,
  ) {
    final duration = controller.value.duration;
    final text =
        '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Stack(
      children: [
        Hero(
          tag: "photoView_${widget.image.id}",
          child: Container(
            color: Colors.black,
            alignment: Alignment.center,
            width: widget.width,
            height: widget.height,
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
      ],
    );
  }

  Widget _buildInit(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: "photoView_${widget.image.id}",
          child: Image.network(
            image.derivatives.smallXX.url,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: width,
          height: height,
          child: IconButton(
            icon: const Icon(Icons.video_collection_rounded),
            onPressed: _player != null
                ? null
                : () {
                    if (isSupportedVideo()) {
                      _load();
                    } else {
                      launch(widget.image.url);
                    }
                  },
          ),
        ),
      ],
    );
  }
}
