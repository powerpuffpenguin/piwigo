import 'dart:io';

import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/fullscreen/fullscreen.dart';
import 'package:piwigo/pages/widget/fullscreen/view_controller.dart';
import 'package:piwigo/pages/widget/video_controller.dart';
import 'package:piwigo/pages/widget/video_player_hero.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:ppg_ui/ppg_ui.dart';
import 'package:video_player/video_player.dart';

class MyVideoFull extends StatefulWidget {
  const MyVideoFull({
    Key? key,
    this.controller,
    required this.fullscreenState,
    required this.image,
  }) : super(key: key);
  final PageImage image;
  final VideoPlayerController? controller;
  final FullscreenState<PageImage> fullscreenState;
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends UIState<MyVideoFull> {
  bool _showController = false;
  VideoPlayerController? _controller;
  VideoPlayerController? getController() {
    if (_controller == null) {
      _controller = widget.controller;
      if (_controller == null) {
        if (Platform.isAndroid || Platform.isIOS) {
          _controller = VideoPlayerController.network(widget.image.url)
            ..setLooping(true)
            ..initialize().then((_) {
              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
              aliveSetState(() {
                _controller!.play();
              });
            });
        }
      }
    }
    return _controller!;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = getController();
    if (controller == null) {
      return Container();
    }

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showController = !_showController;
            });
          },
          child: Stack(
            children: <Widget>[
              Center(
                child: MyVideoPlayerHero(
                  tag: "player",
                  controller: controller,
                ),
              ),
              _buildFullscreenController(context),
              _buildController(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenController(BuildContext context) {
    if (_showController) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: MyViewController(
        fullscreenState: widget.fullscreenState,
      ),
    );
  }

  Widget _buildController(
      BuildContext context, VideoPlayerController controller) {
    if (_showController) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.bottomLeft,
      child: MyVideoController(
        controller: controller,
        fullscreen: true,
        onFullscreen: (_) {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
