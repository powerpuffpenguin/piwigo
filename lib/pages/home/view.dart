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

  _getPage(int page) async {
    setState(() => disabled = true);
    try {
      final images = await client.getCategoriesImages(
        parent: categorie.id,
        page: page,
        cancelToken: _cancelToken,
      );
      checkAlive();

      final pageinfo = images.pageInfo;
      _completed = pageinfo.completed();
      _pageinfo = pageinfo;
      aliveSetState(() {
        _source.addAll(images.list);
        disabled = false;
      });
    } catch (e) {
      if (isNotClosed) {
        BotToast.showText(text: '$e');
        setState(() => disabled = false);
      }
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
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCategories(context, size),
          _buildImages(context, size),
        ],
      ),
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
      padding: _source.list.isEmpty
          ? const EdgeInsets.only(top: spacing)
          : const EdgeInsets.only(bottom: spacing),
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

  Widget _buildImages(BuildContext context, Size size) {
    if (_source.list.isEmpty) {
      return Container();
    }
    const spacing = 8.0;
    final width = MyImage.calculateWidth(size.width - spacing * 2);
    final height = MyImage.calculateHeight(width);
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: spacing, bottom: spacing),
      child: Wrap(
        children: _source.list
            .map<Widget>((node) => MyImage(
                  image: node,
                  width: width,
                  height: height,
                ))
            .toList(),
      ),
    );
  }
}
