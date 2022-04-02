import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/home/fullscreen.dart';
import 'package:piwigo/pages/widget/cover.dart';
import 'package:piwigo/pages/widget/fullscreen/fullscreen.dart';
import 'package:piwigo/pages/widget/image.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/swiper/swiper.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:piwigo/utils/wrap.dart';
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
  final _swiperController = SwiperController();
  FullscreenState<PageImage>? _fullscreenState;
  FullscreenState<PageImage> get fullscreenState => _fullscreenState ??=
      FullscreenState<PageImage>(source: _source.list, onChanged: _onChanged);
  void _onChanged(
      BuildContext context, FullscreenState<PageImage> fullscreenState) {}

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

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
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
        if (widget.categorie.images > 0) {
          _getPage(0);
        } else {
          _completed = true;
        }
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
    if (_source.list.isEmpty && _categories.isEmpty) {
      return null;
    }
    return OrientationBuilder(builder: (context, orientation) {
      final size = MediaQuery.of(context).size;
      const spacing = 8.0;
      bool portrait = orientation == Orientation.portrait;
      final wrapImages = portrait
          ? MyImage.calculateWrap(size, spacing, _source.list.length, count: 3)
          : MyImage.calculateWrap(size, spacing, _source.list.length, count: 6);
      final wrapCategories =
          MyCover.calculateWrap(size, spacing, _categories.length);
      var count = wrapImages.rows + wrapCategories.rows + 1;
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
          if (index < wrapCategories.rows) {
            return _buildCategories(
              context,
              wrap: wrapCategories,
              index: index,
            );
          }
          // images
          index -= wrapCategories.rows;
          return _buildImages(
            context,
            wrap: wrapImages,
            index: index,
          );
        },
      );
    });
  }

  Widget _buildCategories(
    BuildContext context, {
    required MyWrap wrap,
    required int index,
  }) {
    final start = index * wrap.cols;
    var end = start + wrap.cols;
    if (end > _categories.length) {
      end = _categories.length;
    }
    final range = _categories.getRange(start, end);
    var first = true;
    return Container(
      padding: EdgeInsets.only(left: wrap.spacing, right: wrap.spacing),
      alignment: Alignment.topCenter,
      child: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(top: wrap.spacing),
        width: wrap.viewWidth,
        child: Row(
          children: range.map<Widget>((node) {
            var text = S.of(context).home.countPhoto(node.images);
            if (node.categories > 0 && node.categories >= node.images) {
              text += S
                  .of(context)
                  .home
                  .countPhotoInSub(node.categories - node.images);
            }
            EdgeInsetsGeometry? padding;
            if (first) {
              first = false;
            } else {
              padding = EdgeInsets.only(left: wrap.spacing);
            }
            return Container(
              padding: padding,
              child: GestureDetector(
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
                  width: wrap.width,
                  height: wrap.height,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildImages(
    BuildContext context, {
    required MyWrap wrap,
    required int index,
  }) {
    EdgeInsetsGeometry? padding;
    if (index == 0) {
      padding = EdgeInsets.only(top: wrap.spacing);
    }
    final start = index * wrap.cols;
    var end = start + wrap.cols;
    if (end > _source.list.length) {
      end = _source.list.length;
    }
    if (!_request && !_completed && end >= _source.list.length - wrap.fit) {
      _request = true;
      final page = _pageinfo!.page + 1;
      Future.value(page).then((page) {
        if (isNotClosed) {
          _getPage(page, force: true);
        }
      });
    }
    final children = <Widget>[];
    for (var i = start; i < end; i++) {
      final node = _source.list[i];
      children.add(
        MyImage(
          fullscreenState: fullscreenState,
          image: node,
          width: wrap.width,
          height: wrap.height,
          offset: i,
          onFullscreen: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              _swiperController.value = i;
              return MyFullscreenPage(
                controller: _swiperController,
                source: _source.list,
              );
            }));
          },
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(left: wrap.spacing, right: wrap.spacing),
      alignment: Alignment.topCenter,
      child: Container(
        alignment: Alignment.topLeft,
        padding: padding,
        width: wrap.viewWidth,
        child: Row(
          children: children,
        ),
      ),
    );
  }
}
