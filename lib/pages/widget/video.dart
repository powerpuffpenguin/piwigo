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

  @override
  void initState() {
    super.initState();

    if (isSupportedVideo()) {
      addSubscription(PlayerManage.instance.stream.listen((event) {
        if (event == _player) {
          setState(() {
            _player = null;
            _playButton = true;
          });
        }
      }));
    }
  }

  @override
  void dispose() {
    if (_player?.controller.value.isInitialized ?? false) {
      _player?.controller.pause();
    }
    super.dispose();
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
      player.controller.play();
      setState(() {});
    } catch (e) {
      aliveSetState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    if (player?.controller.value.isInitialized ?? false) {
      final controller = player!.controller;
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
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: MyVideoController(
            controller: controller,
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

class MyVideoController extends StatefulWidget {
  const MyVideoController({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final VideoPlayerController controller;

  @override
  _MyVideoControllerState createState() => _MyVideoControllerState();
}

class _MyVideoControllerState extends UIState<MyVideoController> {
  VideoPlayerController get controller => widget.controller;
  bool _playing = false;
  String _text = '0:0';
  @override
  void initState() {
    super.initState();
    if (controller.value.isInitialized) {
      _text = getDuration(controller.value.position);
    }
    _playing = controller.value.isPlaying;
    controller.addListener(_videoListener);
  }

  @override
  void dispose() {
    controller.removeListener(_videoListener);
    super.dispose();
  }

  String getDuration(Duration duration) {
    return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  void _videoListener() {
    if (!controller.value.isInitialized) {
      return;
    }
    if (controller.value.isPlaying != _playing) {
      setState(() {
        _playing = controller.value.isPlaying;
      });
    }
    final text = getDuration(controller.value.position);
    if (text != _text) {
      setState(() {
        _text = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    if (!value.isInitialized) {
      return Container();
    }
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Text(
            '$_text / ${getDuration(value.duration)}',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.white),
          ),
        ),
        _playing
            ? Container()
            : const Center(
                child: IconButton(
                  iconSize: 32,
                  onPressed: null,
                  icon: Icon(Icons.video_collection_rounded),
                ),
              ),
      ],
    );
  }
}
