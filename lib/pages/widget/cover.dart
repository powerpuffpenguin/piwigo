import 'package:flutter/material.dart';

class MyCover extends StatelessWidget {
  const MyCover({
    Key? key,
    required this.src,
    required this.title,
    this.text = '',
    required this.width,
    required this.height,
  }) : super(key: key);
  final String src;
  final String title;
  final String text;
  final double width;
  final double height;

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
      width = w / 2;
    } else if (w < min * 3 + spacing * 2) {
      width = max;
    } else if (w < max * 3) {
      width = w / 3;
    } else {
      width = max;
    }
    return width;
  }

  static double calculateHeight(double width) => width * 9 / 16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          color: theme.colorScheme.surface,
          width: width,
          height: height,
        ),
        Image.network(
          src,
          fit: BoxFit.cover,
          width: width,
          height: height,
        ),
        _buildText(
          context,
          theme,
          Opacity(
            opacity: 0.75,
            child: Container(
              color: theme.colorScheme.surface,
            ),
          ),
        ),
        _buildText(
          context,
          theme,
          Container(
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
      ],
    );
  }

  Widget _buildText(BuildContext context, ThemeData theme, Widget child) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.bottomLeft,
      child: SizedBox(
        width: width,
        height: 60,
        child: child,
      ),
    );
  }
}
