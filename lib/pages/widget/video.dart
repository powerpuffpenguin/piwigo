import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/video/player_manage.dart';
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
  Player? _player;
  bool _playButton = true;
  String getDuration(Duration duration) {
    return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  _initPlayer() async {
    if (_player != null) {
      return;
    }
    try {
      if (_playButton) {
        setState(() {
          _playButton = false;
        });
      }
      final player = await PlayerManage.instance.get(widget.image.url);
      checkAlive();
      setState(() {
        _player = player;
      });
      await player.initialize();
      checkAlive();
      setState(() {});
    } catch (e) {
      aliveSetState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_player?.controller.value.isInitialized ?? false) {
      final controller = _player!.controller;
      return GestureDetector(
        onDoubleTap: widget.onFullscreen,
        onTap: () {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        },
        child: _buildVideo(context, controller),
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
    final text = getDuration(duration);

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
        Container(
          padding: const EdgeInsets.only(top: 4, left: 4),
          width: widget.width,
          height: widget.height,
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.white),
          ),
        )
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
          child: _buildVideoFlag(context),
        ),
      ],
    );
  }

  Widget _buildVideoFlag(BuildContext context) {
    final player = _player;
    if (player != null) {
      if (player.controller.value.hasError) {
        return Center(
          child: IntrinsicHeight(
            child: Container(
              color: const Color.fromARGB(200, 0, 0, 0),
              child: buildError(
                context,
                player.controller.value.errorDescription,
              ),
            ),
          ),
        );
      }
      return const Center(
        child: SizedBox(
          height: 32,
          child: FittedBox(
            child: CupertinoActivityIndicator(),
          ),
        ),
      );
    }
    return Center(
      child: IconButton(
        iconSize: 32,
        onPressed: isSupportedVideo()
            ? (_playButton ? _initPlayer : null)
            : () {
                launch(widget.image.url);
              },
        icon: const Icon(Icons.video_collection_rounded),
      ),
    );
  }
}
