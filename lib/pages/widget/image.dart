import 'package:flutter/material.dart';
import 'package:piwigo/db/quality.dart';
import 'package:piwigo/pages/widget/video.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/utils/path.dart';
import 'package:piwigo/utils/wrap.dart';

class MyImage extends StatelessWidget {
  const MyImage({
    Key? key,
    required this.image,
    required this.width,
    required this.height,
    this.onTap,
    this.focusNode,
  }) : super(key: key);
  final double width;
  final double height;
  final PageImage image;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) {
    if (isVideoFile(image.file)) {
      return MyVideo(
        width: width,
        height: height,
        image: image,
        onTap: onTap,
        focusNode: focusNode,
      );
    }
    var w = width;
    var h = height;
    var quality = false;
    switch (MyQuality.instance.data) {
      case qualityFast:
        break;
      case qualityNormal:
        w *= MediaQuery.of(context).devicePixelRatio;
        h *= MediaQuery.of(context).devicePixelRatio;
        break;
      default:
        quality = true;
        w *= MediaQuery.of(context).devicePixelRatio;
        h *= MediaQuery.of(context).devicePixelRatio;
        break;
    }
    return _ImageView(
      tag: "photoView_${image.id}",
      onTap: onTap,
      focusNode: focusNode,
      width: width,
      height: height,
      url: image.getDerivative(w.toInt(), h.toInt(), quality).url,
    );
  }

  /// 傳入佈局寬度，返回組件適合的寬度
  static double calculateWidth(
    double w, {
    double min = 100,
    double max = 116,
    double fit = 220,
    int count = 3,
  }) {
    assert(count > 0);
    assert(min > 1);
    assert(max >= min);
    assert(fit >= max);
    var v = _calculateWidth(w, min: min, max: max, fit: fit, count: count);
    return v.toInt().toDouble();
  }

  static double _calculateWidth(
    double w, {
    double min = 100,
    double max = 116,
    double fit = 220,
    int count = 3,
  }) {
    if (w <= max) {
      return w;
    }
    for (var i = 1; i < count; i++) {
      final n = i + 1;
      if (w < min * n) {
        return max;
      } else if (w < max * n) {
        return w / n;
      }
    }
    if (w <= fit * count) {
      return w / count;
    }
    return fit;
  }

  static double calculateHeight(double width) => (width * 9 ~/ 16).toDouble();

  static MyWrap calculateWrap(
    Size size,
    double spacing,
    int length, {
    double min = 100,
    double max = 115,
    double fit = 220,
    int count = 3,
  }) {
    if (length == 0) {
      return const MyWrap(
          spacing: 0,
          viewWidth: 0,
          width: 0,
          height: 0,
          cols: 0,
          rows: 0,
          fit: 0);
    }
    final w = size.width - spacing * 2;
    final width = calculateWidth(
      w,
      min: min,
      max: max,
      fit: fit,
      count: count,
    );
    final height = calculateHeight(width);
    final cols = w ~/ width;
    final viewWidth = cols * width;
    final fitHeight = cols * size.height ~/ height;
    final rows = (length + cols - 1) ~/ cols;
    return MyWrap(
      spacing: spacing,
      viewWidth: viewWidth,
      width: width,
      height: height,
      cols: cols,
      rows: rows,
      fit: fitHeight,
    );
  }
}

class _ImageView extends StatefulWidget {
  const _ImageView({
    Key? key,
    this.tag,
    required this.width,
    required this.height,
    required this.url,
    this.onTap,
    this.focusNode,
  }) : super(key: key);
  final String? tag;
  final double width;
  final double height;
  final String url;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<_ImageView> {
  String get url => widget.url;
  double get width => widget.width;
  double get height => widget.height;
  VoidCallback? get onTap => widget.onTap;
  FocusNode? get focusNode => widget.focusNode;
  @override
  void initState() {
    super.initState();
    if (focusNode != null) {
      FocusManager.instance.addListener(_listener);
    }
  }

  @override
  void dispose() {
    if (focusNode != null) {
      FocusManager.instance.removeListener(_listener);
    }
    super.dispose();
  }

  void _listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Ink(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        image: url.startsWith('http://') || url.startsWith('https://')
            ? DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: InkWell(
        focusNode: focusNode,
        onTap: onTap,
        child: widget.tag == null
            ? _buildBody(context)
            : Hero(
                tag: widget.tag!,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: _buildBody(context),
                ),
              ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (focusNode?.hasFocus ?? false) {
      return Container(
        width: width,
        height: height,
        alignment: Alignment.topRight,
        child: Icon(
          Icons.check_circle_outline,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return Container();
  }
}
