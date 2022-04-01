import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/fullscreen/fullscreen.dart';
import 'package:piwigo/rpc/webapi/categories.dart';

class MyViewController extends StatefulWidget {
  const MyViewController({
    Key? key,
    required this.fullscreenState,
  }) : super(key: key);
  final FullscreenState<PageImage> fullscreenState;
  @override
  _MyViewControllerState createState() => _MyViewControllerState();
}

class _MyViewControllerState extends State<MyViewController> {
  FullscreenState<PageImage> get fullscreenState => widget.fullscreenState;
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
                color: Colors.white,
                icon: const Icon(Icons.navigate_before),
                onPressed: fullscreenState.offset < 1
                    ? null
                    : () {
                        fullscreenState.onChanged(context,
                            fullscreenState.source, fullscreenState.offset - 1);
                      },
              ),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.navigate_next),
                onPressed:
                    fullscreenState.offset + 1 >= fullscreenState.source.length
                        ? null
                        : () {
                            fullscreenState.onChanged(
                                context,
                                fullscreenState.source,
                                fullscreenState.offset + 1);
                          },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
