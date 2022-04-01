import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/fullscreen/fullscreen.dart';
import 'package:piwigo/pages/widget/fullscreen/view_controller.dart';
import 'package:piwigo/pages/widget/video_controller.dart';
import 'package:piwigo/pages/widget/video_player_hero.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:video_player/video_player.dart';

class MyVideoFull extends StatefulWidget {
  const MyVideoFull({
    Key? key,
    required this.controller,
    required this.fullscreenState,
  }) : super(key: key);
  final VideoPlayerController controller;
  final FullscreenState<PageImage> fullscreenState;
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoFull> {
  bool _showController = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showController = !_showController;
            });
          },
          child: Stack(
            children: <Widget>[
              Center(
                child: MyVideoPlayerHero(
                  tag: "player",
                  controller: widget.controller,
                ),
              ),
              _buildFullscreenController(context),
              _buildController(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenController(BuildContext context) {
    if (_showController) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: MyViewController(
        fullscreenState: widget.fullscreenState,
      ),
    );
  }

  Widget _buildController(BuildContext context) {
    if (_showController) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.bottomLeft,
      child: MyVideoController(
        controller: widget.controller,
        fullscreen: true,
        onFullscreen: (_) {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
