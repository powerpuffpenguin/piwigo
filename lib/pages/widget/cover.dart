import 'package:flutter/material.dart';

class MyCover extends StatelessWidget {
  const MyCover({
    Key? key,
    required this.src,
    required this.title,
    this.text = '',
  }) : super(key: key);
  final String src;
  final String title;
  final String text;
  static const width = 280.0;
  static const height = width * 9 / 16;
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
