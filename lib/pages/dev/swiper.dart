import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/swiper/swiper.dart';

class MyTestSwiperPage extends StatefulWidget {
  const MyTestSwiperPage({
    Key? key,
    required this.direction,
  }) : super(key: key);
  final Axis direction;
  @override
  _MyTestSwiperPageState createState() => _MyTestSwiperPageState();
}

class _MyTestSwiperPageState extends State<MyTestSwiperPage> {
  final _controller = SwiperController();
  final urls = <String>[
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fexcitedcats.com%2Fwp-content%2Fuploads%2F2020%2F08%2FSiberian-cat_Shutterstock_Pavel-Sepi.jpg&refer=http%3A%2F%2Fexcitedcats.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1651379320&t=21313c1306576f8894eaf4cf90d67eaf',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpicjumbo.com%2Fwp-content%2Fuploads%2FDSC04834-1-2210x1473.jpg&refer=http%3A%2F%2Fpicjumbo.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1651379314&t=93008d7624225ac2b1308d0c1ed30c66',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fhbimg.b0.upaiyun.com%2F6724ab4872c507b6e6ff833415fd73875234fd3611d85-hwREbL_fw658&refer=http%3A%2F%2Fhbimg.b0.upaiyun.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1651379314&t=a0876fefbdb8fd2b973cb1f321a61ddd'
  ];
  bool before = false;
  bool next = true;
  _check() {
    final b = _controller.value > 0;
    final n = _controller.value + 1 < urls.length;
    if (b != before || n != next) {
      setState(() {
        before = b;
        next = n;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('測試頁面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: !before
                ? null
                : () {
                    _controller.swipeTo(_controller.value - 1);
                  },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: !next
                ? null
                : () {
                    _controller.swipeTo(_controller.value + 1);
                  },
          ),
        ],
      ),
      body: GestureDetector(
        onDoubleTap: () {
          Navigator.of(context).pop();
        },
        child: Swiper(
          initOffset: 1,
          controller: _controller,
          direction: widget.direction,
          itemCount: urls.length,
          itemBuilder: (context, i) {
            return Image.network(
              urls[i],
              fit: BoxFit.fill,
            );
          },
          onChanged: (v) {
            debugPrint('changed: $v');

            _check();
          },
        ),
      ),
    );
  }
}
