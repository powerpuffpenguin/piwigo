import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/cover.dart';
import 'package:piwigo/pages/widget/image.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:ppg_ui/ppg_ui.dart';

class MyViewPage extends StatefulWidget {
  const MyViewPage({
    Key? key,
    required this.client,
    required this.categorie,
  }) : super(key: key);
  final Client client;
  final Categorie categorie;
  @override
  _MyViewPageState createState() => _MyViewPageState();
}

class Source {
  final list = <PageImage>[];
  final keys = <String, PageImage>{};
  void add(PageImage value) {
    if (keys.containsKey(value.id)) {
      return;
    }
    keys[value.id] = value;
    list.add(value);
  }

  void addAll(Iterable<PageImage> iterable) {
    for (var item in iterable) {
      add(item);
    }
  }
}

class _MyViewPageState extends UIState<MyViewPage> {
  Client get client => widget.client;
  Categorie get categorie => widget.categorie;
  dynamic _error;
  final _categories = <Categorie>[];
  bool _completed = false;
  PageInfo? _pageinfo;
  bool _request = false;
  final _source = Source();
  final _cancelToken = CancelToken();
  @override
  void initState() {
    super.initState();
    Future.value().then((_) {
      if (isNotClosed) {
        _init();
      }
    });
  }

  _init() async {
    setState(() {
      _error = null;
      disabled = true;
    });
    try {
      final list = await client.getCategoriesList(
        parent: categorie.id,
        cancelToken: _cancelToken,
      );
      aliveSetState(() {
        _categories
          ..clear()
          ..addAll(list);
        disabled = false;
        _getPage(0);
      });
    } catch (e) {
      aliveSetState(() {
        _error = e;
        disabled = false;
      });
    }
  }

  _getPage(int page, {bool force = false}) async {
    if (_request && !force) {
      return;
    }
    debugPrint('get page: $page');
    _request = true;
    try {
      final images = await client.getCategoriesImages(
        parent: categorie.id,
        page: page,
        cancelToken: _cancelToken,
      );
      checkAlive();

      final pageinfo = images.pageInfo;
      debugPrint(
          'page result: page=${pageinfo.page} count=${pageinfo.count} images=${images.list.length}');
      _completed = pageinfo.completed();
      _pageinfo = pageinfo;
      aliveSetState(() {
        _source.addAll(images.list);
        disabled = false;
      });
    } catch (e) {
      if (isNotClosed) {
        BotToast.showText(text: '$e');
      }
    } finally {
      _request = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categorie.name),
      ),
      body: _error == null
          ? _buildBody(context)
          : Text(
              "$_error",
              style: TextStyle(color: Theme.of(context).errorColor),
            ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (disabled) {
      return createSpinFloating();
    } else if (_error != null) {
      return FloatingActionButton(
        child: const Icon(Icons.refresh),
        tooltip: S.of(context).app.refresh,
        onPressed: _init,
      );
    }
    return null;
  }

  Widget? _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const spacing = 8.0;
    final w = size.width - spacing * 2;
    final width = MyImage.calculateWidth(w);
    final height = MyImage.calculateHeight(width);
    final cols = w ~/ width;
    final viewWidth = cols * width;
    final fix = cols * size.height ~/ height;
    var count = (_source.list.length + cols - 1) ~/ cols + 1; // +1 bottom
    if (_categories.isNotEmpty) {
      count++; // +1 top of _categories
    }
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        if (count == index + 1) {
          // bottom

          return const SizedBox(
            height: spacing,
          );
        }
        // categories
        if (_categories.isNotEmpty) {
          if (index == 0) {
            return _buildCategories(context, size);
          } else {
            index--;
          }
        }
        // images
        EdgeInsetsGeometry? padding;
        if (index == 0) {
          padding = const EdgeInsets.only(top: spacing);
        }
        final start = index * cols;
        var end = start + cols;
        if (end > _source.list.length) {
          end = _source.list.length;
        }
        final range = _source.list.getRange(start, end);
        if (!_request && !_completed && end >= _source.list.length - fix) {
          _request = true;
          final page = _pageinfo!.page + 1;
          Future.value(page).then((page) {
            if (isNotClosed) {
              _getPage(page, force: true);
            }
          });
        }
        return Container(
          padding: const EdgeInsets.only(left: spacing, right: spacing),
          alignment: Alignment.topCenter,
          child: Container(
            alignment: Alignment.topLeft,
            padding: padding,
            width: viewWidth,
            child: Row(
              children: range
                  .map<Widget>(
                    (node) => MyImage(
                      image: node,
                      width: width,
                      height: height,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategories(BuildContext context, Size size) {
    if (_categories.isEmpty) {
      return Container();
    }
    const spacing = 8.0;
    final width = MyCover.calculateWidth(size.width - spacing * 2, spacing);
    final height = MyCover.calculateHeight(width);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: spacing),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: _categories.map<Widget>((node) {
          var text = S.of(context).home.countPhoto(node.images);
          if (node.categories > 0 && node.categories >= node.images) {
            text += S
                .of(context)
                .home
                .countPhotoInSub(node.categories - node.images);
          }
          return GestureDetector(
            onTap: disabled
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MyViewPage(
                          client: client,
                          categorie: node,
                        ),
                      ),
                    );
                  },
            child: MyCover(
              src: node.cover,
              title: node.name,
              text: text,
              width: width,
              height: height,
            ),
          );
        }).toList(),
      ),
    );
  }
}
