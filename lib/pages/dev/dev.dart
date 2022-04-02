import 'package:flutter/material.dart';
import 'package:piwigo/pages/dev/rpc.dart';
import 'package:piwigo/pages/dev/swiper.dart';
import 'package:piwigo/rpc/webapi/client.dart';

class MyDevPage extends StatefulWidget {
  const MyDevPage({
    Key? key,
    required this.client,
  }) : super(key: key);
  final Client client;
  @override
  _MyDevPageState createState() => _MyDevPageState();
}

class _MyDevPageState extends State<MyDevPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('測試頁面'),
      ),
      body: ListView(
        children: [
          TextButton(
            child: const Text('RPC'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyTestRPCPage(
                    client: widget.client,
                  ),
                ),
              );
            },
          ),
          TextButton(
            child: const Text('horizontal swiper'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyTestSwiperPage(
                    direction: Axis.horizontal,
                  ),
                ),
              );
            },
          ),
          TextButton(
            child: const Text('vertical swiper'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyTestSwiperPage(
                    direction: Axis.vertical,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
