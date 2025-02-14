import 'dart:async';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:piwigo/db/play.dart';
import 'package:piwigo/db/quality.dart';
import 'package:piwigo/db/video.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/swiper/swiper.dart';
import 'package:piwigo/pages/widget/video/player_manage.dart';
import 'package:piwigo/pages/widget/video_controller.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/utils/path.dart';
import 'package:ppg_ui/ppg_ui.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_share_me/flutter_share_me.dart';

class MyPhotoView extends StatefulWidget {
  const MyPhotoView({
    Key? key,
    required this.image,
    required this.controller,
    required this.count,
    required this.swipe,
    required this.showController,
    required this.autoplayController,
    required this.isVideo,
    required this.stream,
    required this.sink,
    required this.index,
  }) : super(key: key);
  final int index;
  final Stream<KeyEvent> stream;
  final PageImage image;
  final SwiperController controller;
  final int count;
  final bool swipe;
  final ValueNotifier<bool> showController;
  final ValueNotifier<bool> autoplayController;
  final bool isVideo;
  final StreamSink<int> sink;
  @override
  _MyPhotoViewState createState() => _MyPhotoViewState();
}

typedef _PhotoQuality = List<Tuple2<String, Derivative>>;

class _MyPhotoViewState extends UIState<MyPhotoView> {
  bool _showController = false;
  bool _autoPlay = false;
  Player? _player;
  bool _playButton = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _showController = widget.showController.value;
    widget.showController.addListener(_showControllerListener);

    if (!widget.swipe) {
      _autoPlay = widget.autoplayController.value;
      widget.autoplayController.addListener(_autoplayControllerListener);
    }
    if (!widget.isVideo) {
      if (!widget.swipe) {
        PlayerManage.instance.pause();
      }
    } else if (isSupportedVideo()) {
      addSubscription(PlayerManage.instance.stream.listen((event) {
        if (event == _player) {
          setState(() {
            _player = null;
            _playButton = true;
          });
        }
      }));
      final player = PlayerManage.instance.getInitialized(widget.image.url);
      if (player != null) {
        _playButton = false;
        _player = player;
        if (isClosed) {
          return;
        }
        player.controller.addListener(_playerListener);
        if (!player.controller.value.isPlaying) {
          player.controller.play();
        }
      } else if (!widget.swipe) {
        _initPlayer();
      }
    }

    _autonext();
  }

  bool _cannext = true;
  bool _isautoplaying = false;
  _autonext() async {
    if (_isautoplaying || widget.swipe || widget.isVideo) {
      return;
    }
    _isautoplaying = true;
    _doAutoNext().whenComplete(() {
      _isautoplaying = false;
    });
  }

  Future<void> _doAutoNext() async {
    var total = MyPlay.instance.data.seconds;
    if (total < 1) {
      total = 5;
    } else {
      total *= 5;
    }
    var count = 0;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (isClosed) {
        break;
      } else if (!_cannext) {
        count = 0;
        _cannext = true;
      } else {
        count++;
        if (count >= total) {
          widget.sink.add(widget.index);
          break;
        }
      }
    }
  }

  bool _create = false;

  @override
  void dispose() {
    widget.autoplayController.removeListener(_autoplayControllerListener);
    widget.showController.removeListener(_showControllerListener);
    if (_create && (_player?.controller.value.isInitialized ?? false)) {
      _player!.controller.pause();
    }
    _player?.controller.removeListener(_playerListener);
    _timer?.cancel();
    super.dispose();
  }

  _autoplayControllerListener() {
    if (isClosed) {
      return;
    }
    final val = widget.autoplayController.value;
    if (val != _autoPlay) {
      setState(() {
        _autoPlay = val;
        if (val) {
          _autonext();
        }
      });
    }
  }

  _showControllerListener() {
    if (isClosed) {
      return;
    }
    final val = widget.showController.value;
    if (val != _showController) {
      setState(() {
        _showController = val;
      });
    }
  }

  _initPlayer() async {
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
        _create = true;
      });
      await player.initialize();
      checkAlive();
      player.controller.addListener(_playerListener);
      aliveSetState(() {
        player.controller.play();
      });
    } catch (e) {
      aliveSetState(() {});
    }
  }

  _playerListener() {
    final controller = _player?.controller;
    if (controller == null) {
      return;
    }
    final value = controller.value;
    if (!value.isPlaying &&
        value.position.inSeconds >= value.duration.inSeconds) {
      if (widget.autoplayController.value) {
        widget.sink.add(widget.index);
      } else {
        _replay(controller);
      }
    }
  }

  _replay(VideoPlayerController controller) async {
    try {
      await controller.seekTo(const Duration(seconds: 0));
      checkAlive();
      await Future.delayed(const Duration(milliseconds: 100));
      checkAlive();
      await controller.play();
    } catch (e) {
      debugPrint('replay: $e');
    }
  }

  final _keys = <int, int>{};
  _PhotoQuality? _quality;
  _PhotoQuality get quality {
    if (_quality == null) {
      _quality = <Tuple2<String, Derivative>>[];
      final image = widget.image;
      final derivatives = image.derivatives;
      final photo = S.of(context).photo;
      _add(photo.smallXX, derivatives.smallXX);
      _add(photo.smallX, derivatives.smallX);
      _add(photo.small, derivatives.small);
      _add(photo.medium, derivatives.medium);
      _add(photo.large, derivatives.large);
      _add(photo.largeX, derivatives.largeX);
      _add(photo.largeXX, derivatives.largeXX);
      if (!widget.isVideo) {
        _quality!.add(
          Tuple2(
            '${photo.original} (${image.width} x ${image.height})',
            Derivative(
              url: widget.image.url,
              width: image.width,
              height: image.height,
            ),
          ),
        );
      }
    }
    return _quality!;
  }

  void _add(String name, Derivative derivative) {
    if (_keys[derivative.width] == derivative.height) {
      return;
    }
    _keys[derivative.width] = derivative.height;
    _quality!.add(Tuple2(
        '$name (${derivative.width} x ${derivative.height})', derivative));
  }

  int? _value;
  int _getValue(BuildContext context) {
    if (_value == null) {
      final qual = quality;
      switch (MyQuality.instance.data) {
        case qualityRaw:
          _value = qual.length - 1;
          return _value!;
      }
      final mediaQuery = MediaQuery.of(context);
      var size = mediaQuery.size;
      var and = false;
      switch (MyQuality.instance.data) {
        case qualityFast:
          break;
        case qualityNormal:
          size *= mediaQuery.devicePixelRatio;
          break;
        default:
          size *= mediaQuery.devicePixelRatio;
          and = true;
          break;
      }
      if (and) {
        for (var i = 0; i < qual.length - 1; i++) {
          final derivative = qual[i].item2;
          if (derivative.width >= size.width &&
              derivative.height >= size.height) {
            _value = i;
            return i;
          }
        }
      } else {
        for (var i = 0; i < qual.length - 1; i++) {
          final derivative = qual[i].item2;
          if (derivative.width >= size.width ||
              derivative.height >= size.height) {
            _value = i;
            return i;
          }
        }
      }
      _value = qual.length - 1;
    }
    return _value!;
  }

  @override
  Widget build(BuildContext context) {
    final value = _getValue(context);
    final qual = quality;
    if (widget.isVideo && (_player?.controller.value.isInitialized ?? false)) {
      return _buildVideo(context, qual, value, _player!.controller);
    }
    return GestureDetector(
      onTap: () {
        widget.showController.value = !widget.showController.value;
      },
      onDoubleTap: () {
        Navigator.of(context).pop();
      },
      child: Stack(
        children: [
          PhotoView(
            heroAttributes: PhotoViewHeroAttributes(
              tag: "photoView_${widget.image.id}",
            ),
            imageProvider: NetworkImage(qual[value].item2.url),
            loadingBuilder: (context, evt) {
              // 標記未就緒
              _cannext = false;

              final expected = evt?.expectedTotalBytes ?? 0;
              double value = 0;
              if (expected != 0) {
                final cumulative = evt?.cumulativeBytesLoaded ?? 0;
                if (cumulative == expected) {
                  value = 1;
                } else {
                  value = cumulative / expected;
                }
              }
              return Center(
                child: CircularProgressIndicator(
                  value: value,
                ),
              );
            },
          ),
          widget.isVideo ? _buildVideoFlag(context) : Container(),
          _buildFullscreenControllerBackground(context),
          _buildFullscreenController(context, qual, value),
        ],
      ),
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
          height: 64,
          child: FittedBox(
            child: CupertinoActivityIndicator(),
          ),
        ),
      );
    }
    return Center(
      child: IconButton(
        iconSize: 64,
        onPressed: isSupportedVideo()
            ? (_playButton ? _initPlayer : null)
            : () {
                launch(widget.image.url);
              },
        icon: const Icon(Icons.video_collection_rounded),
      ),
    );
  }

  Widget _buildVideo(
    BuildContext context,
    _PhotoQuality quality,
    int value,
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        widget.showController.value = !widget.showController.value;
      },
      onDoubleTap: () {
        Navigator.of(context).pop();
      },
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: Hero(
              tag: "photoView_${widget.image.id}",
              child: _VideoPlayer(
                image: widget.image,
                controller: controller,
                stream: widget.stream,
                showController: _showController,
              ),
              // child: AspectRatio(
              //   aspectRatio: controller.value.aspectRatio,
              //   child: VideoPlayer(controller),
              // ),
            ),
          ),
          _buildFullscreenControllerBackground(context),
          _buildFullscreenController(context, quality, value),
          _buildVideoController(context, controller),
          Center(
            child: MyVideoWakelock(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoController(
      BuildContext context, VideoPlayerController controller) {
    if (widget.swipe || !_showController) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomLeft,
      child: MyVideoController(
        controller: controller,
      ),
    );
  }

  Widget _buildFullscreenControllerBackground(BuildContext context) {
    if (widget.swipe || !_showController) {
      return Container();
    }
    return Container(
      height: 50,
      color: const Color.fromARGB(200, 0, 0, 0),
    );
  }

  Widget _buildFullscreenController(
      BuildContext context, _PhotoQuality quality, int value) {
    if (widget.swipe || !_showController) {
      return Container();
    }
    return _MyPhotoController(
      image: widget.image,
      controller: widget.controller,
      count: widget.count,
      quality: quality,
      value: value,
      autoplayController: widget.autoplayController,
      onChanged: (v) {
        setState(() {
          _value = v;
        });
      },
    );
  }
}

class _MyPhotoController extends StatefulWidget {
  const _MyPhotoController({
    Key? key,
    required this.image,
    required this.controller,
    required this.count,
    required this.quality,
    required this.value,
    required this.onChanged,
    required this.autoplayController,
  }) : super(key: key);
  final PageImage image;
  final SwiperController controller;
  final int count;
  final _PhotoQuality quality;
  final int value;
  final ValueChanged<int> onChanged;
  final ValueNotifier<bool> autoplayController;
  @override
  _MyPhotoControllerState createState() => _MyPhotoControllerState();
}

class _MyPhotoControllerState extends State<_MyPhotoController> {
  int _value = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
    _value = widget.controller.value;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    final value = widget.controller.value;
    if (value != _value) {
      setState(() {
        _value = value;
      });
    }
  }

  _share() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).app.share),
          content: SingleChildScrollView(
            child: _MyShare(
              image: widget.image,
              quality: widget.quality,
              value: widget.value,
              video: isVideoFile(widget.image.url),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  color: Colors.white,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  widget.autoplayController.value =
                      !widget.autoplayController.value;
                },
                tooltip: 'autoplay',
                color: Colors.white,
                icon: widget.autoplayController.value
                    ? const Icon(Icons.check_box_outlined)
                    : const Icon(Icons.check_box_outline_blank),
              ),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.share),
                tooltip: S.of(context).app.share,
                onPressed: _share,
              ),
              _buildMenu(context),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.navigate_before),
                tooltip: S.of(context).photo.before,
                onPressed: _value < 1
                    ? null
                    : () {
                        if (_value > 0) {
                          widget.controller.swipeTo(_value - 1);
                        }
                      },
              ),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.navigate_next),
                tooltip: S.of(context).photo.next,
                onPressed: _value + 1 >= widget.count
                    ? null
                    : () {
                        final value = _value + 1;
                        if (value < widget.count) {
                          widget.controller.swipeTo(value);
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (v) {
        if (v != widget.value) {
          widget.onChanged(v);
        }
      },
      initialValue: widget.value,
      tooltip: S.of(context).photo.resize,
      icon: const Icon(
        Icons.photo_size_select_actual,
        color: Colors.white,
      ),
      itemBuilder: (context) {
        final menu = <PopupMenuItem<int>>[];
        for (var i = 0; i < widget.quality.length; i++) {
          final quality = widget.quality[i];
          menu.add(
            PopupMenuItem<int>(
              value: i,
              child: Text(quality.item1),
            ),
          );
        }
        return menu;
      },
    );
  }
}

class _MyShare extends StatefulWidget {
  const _MyShare({
    Key? key,
    required this.image,
    required this.quality,
    required this.value,
    required this.video,
  }) : super(key: key);
  final PageImage image;
  final _PhotoQuality quality;
  final int value;
  final bool video;
  @override
  _MyShareState createState() => _MyShareState();
}

class _MyShareState extends UIState<_MyShare> {
  PageImage get image => widget.image;
  _PhotoQuality get quality => widget.quality;
  int get value => widget.value;
  bool get video => widget.video;

  bool _launcher = !isSupportedShare();
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (isSupportedShare()) {
      children.add(
        SwitchListTile(
            title: Text(_launcher
                ? S.of(context).app.openInBrowser
                : S.of(context).app.shareTo),
            value: _launcher,
            onChanged: disabled
                ? null
                : (v) {
                    setState(() {
                      _launcher = v;
                    });
                  }),
      );
    }
    if (widget.video) {
      children.add(_buildItem(
        '${S.of(context).photo.video} (${widget.image.width} x ${widget.image.height})',
        widget.image.url,
      ));
    }
    children.add(_buildItem(
      widget.quality[widget.value].item1,
      widget.quality[widget.value].item2.url,
    ));
    for (var i = 0; i < widget.quality.length; i++) {
      final item = widget.quality[i];
      if (i == widget.value) {
        continue;
      }
      children.add(_buildItem(
        item.item1,
        item.item2.url,
      ));
    }
    return Column(
      children: children,
    );
  }

  Widget _buildItem(String name, String url) {
    return ListTile(
      title: Text(name),
      onTap: disabled
          ? null
          : () async {
              try {
                if (_launcher) {
                  await launch(url);
                } else {
                  final flutterShareMe = FlutterShareMe();
                  await flutterShareMe.shareToSystem(msg: url);
                }
                aliveSetState(() => disabled = false);
              } catch (e) {
                aliveSetState(() {
                  disabled = false;
                  BotToast.showText(text: '$e');
                });
              }
            },
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  const _VideoPlayer({
    Key? key,
    required this.image,
    required this.stream,
    required this.controller,
    required this.showController,
  }) : super(key: key);
  final PageImage image;
  final Stream<KeyEvent> stream;
  final VideoPlayerController controller;
  final bool showController;
  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends UIState<_VideoPlayer> {
  @override
  void initState() {
    super.initState();

    final data = MyVideo.instance.data;
    if (widget.image.width < widget.image.height) {
      _rotate = data.rotate;
      _scaled = data.scale;
      _aspectRatio = data.reverse;
    } else if (widget.image.width > widget.image.height) {
      _rotate = data.rotate1;
      _scaled = data.scale1;
      _aspectRatio = data.reverse1;
    }

    addSubscription(widget.stream.listen((evt) {
      if (!widget.showController) {
        return;
      }
      if (evt.logicalKey == LogicalKeyboardKey.select ||
          evt.logicalKey == LogicalKeyboardKey.enter) {
        final controller = widget.controller;
        if (controller.value.isInitialized) {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        }
      } else if (evt.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (_scaled < 50) {
          aliveSetState(() {
            _scaled++;
          });
        }
      } else if (evt.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_scaled > -50) {
          aliveSetState(() {
            _scaled--;
          });
        }
      } else if (evt.logicalKey == LogicalKeyboardKey.arrowUp) {
        aliveSetState(() {
          _aspectRatio = !_aspectRatio;
        });
      } else if (evt.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_rotate < 3) {
          aliveSetState(() {
            _rotate++;
          });
        } else {
          aliveSetState(() {
            _rotate = 0;
          });
        }
      }
    }));
  }

  int _rotate = 0;
  int _scaled = 0;
  bool _aspectRatio = false;
  @override
  Widget build(BuildContext context) {
    return _buildScale(context);
  }

  Widget _buildScale(BuildContext context) {
    final scaled = _scaled;
    if (scaled == 0) {
      return _buildRotate(context);
    }
    return Transform.scale(
      scale: (100 + scaled) / 100,
      child: _buildRotate(context),
    );
  }

  Widget _buildRotate(BuildContext context) {
    final rotate = _rotate;
    if (rotate == 0) {
      return _buildVideo(context);
    }
    return Transform.rotate(
      angle: pi / 2 * rotate,
      child: _buildVideo(context),
    );
  }

  Widget _buildVideo(BuildContext context) {
    final aspectRatio = _aspectRatio
        ? 1 / widget.controller.value.aspectRatio
        : widget.controller.value.aspectRatio;
    // debugPrint('${widget.controller.value.aspectRatio} $aspectRatio');
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: VideoPlayer(widget.controller),
    );
  }
}
