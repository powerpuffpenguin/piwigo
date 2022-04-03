import 'package:flutter/material.dart';
import 'package:piwigo/service/wakelock_service.dart';
import 'package:ppg_ui/ppg_ui.dart';
import 'package:video_player/video_player.dart';

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
  bool _volume = true;
  @override
  void initState() {
    super.initState();
    if (controller.value.isInitialized) {
      _playing = controller.value.isPlaying;
      _text = getDuration(controller.value.position);
      _volume = controller.value.volume > 0.1;
    }
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
    final volume = controller.value.volume > 0.1;
    if (_volume != volume) {
      setState(() {
        _volume = volume;
      });
    }
  }

  _play() async {
    if (disabled) {
      return;
    }
    final value = controller.value;
    if (value.isPlaying) {
      return;
    }
    disabled = true;
    try {
      await controller.play();
    } catch (e) {
      debugPrint('video play error: $e');
    } finally {
      disabled = false;
    }
  }

  _pause() async {
    if (disabled) {
      return;
    }
    final value = controller.value;
    if (!value.isPlaying) {
      return;
    }
    disabled = true;
    try {
      await controller.pause();
    } catch (e) {
      debugPrint('video play error: $e');
    } finally {
      disabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    if (!value.isInitialized) {
      return Container();
    }
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Column(
          children: [
            _buildButtons(context),
            _buildSlider(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final value = controller.value;
    return Slider(
      max: value.duration.inSeconds.toDouble(),
      value: value.position.inSeconds.toDouble(),
      onChanged: (v) {
        controller.seekTo(Duration(seconds: v.toInt()));
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    final value = controller.value;
    const color = Colors.white;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _playing
                  ? IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: _pause,
                      color: color,
                    )
                  : IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: _play,
                      color: color,
                    ),
              Text(
                '$_text / ${getDuration(value.duration)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              color: color,
              icon: _volume
                  ? const Icon(Icons.volume_up_outlined)
                  : const Icon(Icons.volume_off_outlined),
              onPressed: () {
                setState(() {
                  _volume = !_volume;
                  if (_volume) {
                    controller.setVolume(1);
                  } else {
                    controller.setVolume(0);
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class MyVideoWakelock extends StatefulWidget {
  const MyVideoWakelock({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final VideoPlayerController controller;

  @override
  _MyVideoWakelockState createState() => _MyVideoWakelockState();
}

class _MyVideoWakelockState extends UIState<MyVideoWakelock> {
  VideoPlayerController get controller => widget.controller;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    if (controller.value.isInitialized) {
      _playing = controller.value.isPlaying;
      WakelockService.instance.enable();
    }
    controller.addListener(_videoListener);
  }

  @override
  void dispose() {
    controller.removeListener(_videoListener);
    WakelockService.instance.disable();
    super.dispose();
  }

  void _videoListener() {
    if (!controller.value.isInitialized) {
      return;
    }
    if (controller.value.isPlaying != _playing) {
      setState(() {
        _playing = controller.value.isPlaying;
        if (_playing) {
          WakelockService.instance.enable();
        }
      });
    }
  }

  _play() async {
    if (disabled) {
      return;
    }
    final value = controller.value;
    if (value.isPlaying) {
      return;
    }
    disabled = true;
    try {
      await controller.play();
    } catch (e) {
      debugPrint('video play error: $e');
    } finally {
      disabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    if (!value.isInitialized || _playing) {
      return Container();
    }
    return IconButton(
      iconSize: 64,
      onPressed: disabled ? null : _play,
      icon: const Icon(Icons.video_collection_rounded),
    );
  }
}
