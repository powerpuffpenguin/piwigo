import 'package:flutter/material.dart';
import 'package:piwigo/rpc/webapi/client.dart';

class MyTestRPCPage extends StatefulWidget {
  const MyTestRPCPage({
    Key? key,
    required this.client,
  }) : super(key: key);
  final Client client;
  @override
  _MyTestRPCPageState createState() => _MyTestRPCPageState();
}

class _MyTestRPCPageState extends State<MyTestRPCPage> {
  Client get client => widget.client;
  _getStatus() async {
    try {
      final status = await client.getStatus();
      debugPrint('$status');
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RPC"),
      ),
      body: ListView(
        children: [
          TextButton(
            child: const Text('getStatus'),
            onPressed: _getStatus,
          ),
        ],
      ),
    );
  }
}
