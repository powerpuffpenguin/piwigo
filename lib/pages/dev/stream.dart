import 'dart:async';

import 'package:flutter/material.dart';

class MyTestStreamPage extends StatefulWidget {
  const MyTestStreamPage({
    Key? key,
  }) : super(key: key);
  @override
  _MyTestStreamPageState createState() => _MyTestStreamPageState();
}

class _MyTestStreamPageState extends State<MyTestStreamPage> {
  final _streamController = StreamController<DateTime>();

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  _write() {
    _streamController.sink.add(DateTime.now());
  }

  _read() {
    // _streamController.stream.take(1)
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stream"),
      ),
      body: ListView(
        children: [
          TextButton(
            child: const Text('write'),
            onPressed: _write,
          ),
          TextButton(
            child: const Text('read'),
            onPressed: _read,
          ),
        ],
      ),
    );
  }
}
