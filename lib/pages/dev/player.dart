import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyTestPlayerPage extends StatefulWidget {
  const MyTestPlayerPage({
    Key? key,
  }) : super(key: key);
  @override
  _MyTestPlayerPageState createState() => _MyTestPlayerPageState();
}

class _MyTestPlayerPageState extends State<MyTestPlayerPage> {
  final controller = VideoPlayerController.network(
      'http://photo.king011.com/upload/2022/04/01/20220401223833-3149acc0.mp4')
    ..setLooping(true);
  @override
  void initState() {
    super.initState();
    controller.addListener(_listener);
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    controller.dispose();
    super.dispose();
  }

  _listener() {
    debugPrint('========= $controller');
  }

  _initialize() async {
    debugPrint('-------- initialize');
    try {
      await controller.initialize();
    } catch (e) {
      debugPrint('-------- initialize: $e');
    }
  }

  _get() {
    debugPrint('------$controller');
  }

  _dispose() async {
    try {
      debugPrint('-------- dispose');
      await controller.dispose();
    } catch (e) {
      debugPrint('-------- dispose: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Player"),
      ),
      body: ListView(
        children: [
          TextButton(
            child: const Text('initialize'),
            onPressed: _initialize,
          ),
          TextButton(
            child: const Text('play'),
            onPressed: () {
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
          ),
          TextButton(
            child: const Text('get'),
            onPressed: _get,
          ),
          TextButton(
            child: const Text('dispose'),
            onPressed: _dispose,
          ),
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ],
      ),
    );
  }
}
