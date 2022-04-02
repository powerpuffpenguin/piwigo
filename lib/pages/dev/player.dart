import 'package:flutter/material.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:video_player/video_player.dart';

class MyTestPlayerPage extends StatefulWidget {
  const MyTestPlayerPage({
    Key? key,
  }) : super(key: key);
  @override
  _MyTestPlayerPageState createState() => _MyTestPlayerPageState();
}

class _MyTestPlayerPageState extends State<MyTestPlayerPage> {
  _play() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Player"),
      ),
      body: ListView(
        children: [
          TextButton(
            child: const Text('play'),
            onPressed: _play,
          ),
        ],
      ),
    );
  }
}
