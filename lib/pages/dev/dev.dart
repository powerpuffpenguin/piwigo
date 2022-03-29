import 'package:flutter/material.dart';

class MyDevPage extends StatefulWidget {
  const MyDevPage({
    Key? key,
  }) : super(key: key);
  @override
  _MyDevPageState createState() => _MyDevPageState();
}

class _MyDevPageState extends State<MyDevPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('測試頁面'),
      ),
      body: ListView(),
    );
  }
}
