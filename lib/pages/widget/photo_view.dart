import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/swiper/swiper.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:tuple/tuple.dart';

class MyPhotoView extends StatefulWidget {
  const MyPhotoView({
    Key? key,
    required this.image,
    required this.controller,
    required this.count,
    required this.swipe,
    required this.initShowController,
    required this.onShowController,
  }) : super(key: key);
  final PageImage image;
  final SwiperController controller;
  final int count;
  final bool swipe;
  final bool initShowController;
  final ValueChanged<bool> onShowController;
  @override
  _MyPhotoViewState createState() => _MyPhotoViewState();
}

typedef _PhotoQuality = List<Tuple2<String, Derivative>>;

class _MyPhotoViewState extends State<MyPhotoView> {
  bool _showController = false;
  @override
  void initState() {
    _showController = widget.initShowController;
    super.initState();
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
      _quality!.add(Tuple2(
          '${photo.original} (${image.width} x ${image.height})',
          Derivative(
            url: widget.image.url,
            width: image.width,
            height: image.height,
          )));
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
      final size = MediaQuery.of(context).size;
      for (var i = 0; i < qual.length - 1; i++) {
        final derivative = qual[i].item2;
        if (derivative.width >= size.width ||
            derivative.height >= size.height) {
          _value = i;
          return i;
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _showController = !_showController;
          widget.onShowController(_showController);
        });
      },
      child: Stack(
        children: [
          PhotoView(
            heroAttributes: PhotoViewHeroAttributes(
              tag: "imageView_${widget.image.id}",
            ),
            imageProvider: NetworkImage(qual[value].item2.url),
          ),
          _buildFullscreenControllerBackground(context),
          _buildFullscreenController(context, qual, value),
        ],
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
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: _MyPhotoController(
          controller: widget.controller,
          count: widget.count,
          quality: quality,
          value: value,
          onChanged: (v) {
            setState(() {
              _value = v;
            });
          }),
    );
  }
}

class _MyPhotoController extends StatefulWidget {
  const _MyPhotoController({
    Key? key,
    required this.controller,
    required this.count,
    required this.quality,
    required this.value,
    required this.onChanged,
  }) : super(key: key);
  final SwiperController controller;
  final int count;
  final _PhotoQuality quality;
  final int value;
  final ValueChanged<int> onChanged;
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
