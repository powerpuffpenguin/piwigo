import 'package:flutter/material.dart';
import 'package:piwigo/utils/wrap.dart';

class MyCover extends StatelessWidget {
  const MyCover({
    Key? key,
    required this.src,
    required this.title,
    this.text = '',
    required this.width,
    required this.height,
    this.onTap,
    this.focusNode,
    this.focusColor,
  }) : super(key: key);
  final String src;
  final String title;
  final String text;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final Color? focusColor;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Ink(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        image: DecorationImage(
          image: NetworkImage(src),
          fit: BoxFit.cover,
        ),
      ),
      child: InkWell(
        focusNode: focusNode,
        focusColor: focusColor,
        onTap: onTap,
        child: Container(
          alignment: Alignment.bottomLeft,
          child: IntrinsicHeight(
            child: Container(
              color: theme.colorScheme.surface.withOpacity(0.75),
              width: width,
              padding: const EdgeInsets.all(8),
              child: RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '$title\n',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                    TextSpan(
                      text: text,
                      style: theme.textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 傳入佈局寬度，返回組件適合的寬度
  static double calculateWidth(double w, double spacing) {
    const min = 260.0;
    const max = 290.0;
    late double width; //[110,130]
    if (w <= max) {
      width = w;
    } else if (w < min * 2 + spacing) {
      width = max;
    } else if (w < max * 2 + spacing) {
      width = (w - spacing) / 2;
    } else if (w < min * 3 + spacing * 2) {
      width = max;
    } else if (w < max * 3 + spacing * 2) {
      width = (w - spacing * 2) / 3;
    } else {
      width = max;
    }
    return width.toInt().toDouble();
  }

  static double calculateHeight(double width) => (width * 9 ~/ 16).toDouble();
  static MyWrap calculateWrap(
    Size size,
    double spacing,
    int count,
  ) {
    if (count == 0) {
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
    final width = calculateWidth(w, spacing);
    final height = calculateHeight(width);
    final cols = 1 + (w - width) ~/ width;
    final viewWidth = (cols - 1) * (width + spacing) + width;
    final rows = (count + cols - 1) ~/ cols;
    return MyWrap(
      spacing: spacing,
      viewWidth: viewWidth,
      width: width,
      height: height,
      cols: cols,
      rows: rows,
      fit: 0,
    );
  }
}
