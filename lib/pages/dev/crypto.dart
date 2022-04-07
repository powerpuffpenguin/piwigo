import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class MyTestCryptoPage extends StatefulWidget {
  const MyTestCryptoPage({
    Key? key,
  }) : super(key: key);
  @override
  _MyTestCryptoPageState createState() => _MyTestCryptoPageState();
}

class _MyTestCryptoPageState extends State<MyTestCryptoPage> {
  _md5() {
    var bytes = utf8.encode("cerberus is an idea");
    final digest = sha1.convert(bytes);
    debugPrint("Digest as bytes: ${digest.bytes}");
    debugPrint("Digest as hex string: $digest");
  }

  _md5Sink() {
    var output = AccumulatorSink<Digest>();
    var input = sha1.startChunkedConversion(output);
    input.add(utf8.encode("cerberus i"));
    input.add(
        utf8.encode("s an idea")); // call `add` for every chunk of input data
    input.close();
    var digest = output.events.single;
    debugPrint("Digest as bytes: ${digest.bytes}");
    debugPrint("Digest as hex string: $digest");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("crypto"),
      ),
      body: ListView(
        children: [
          TextButton(
            child: const Text('md5'),
            onPressed: _md5,
          ),
          TextButton(
            child: const Text('md5 sink'),
            onPressed: _md5Sink,
          ),
        ],
      ),
    );
  }
}
