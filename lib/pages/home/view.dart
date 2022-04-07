import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/download/download.dart';
import 'package:piwigo/pages/download/source.dart';
import 'package:piwigo/pages/home/fullscreen.dart';
import 'package:piwigo/pages/home/select_action.dart';
import 'package:piwigo/pages/widget/builder/row_builder.dart';
import 'package:piwigo/pages/widget/cover.dart';
import 'package:piwigo/pages/widget/image.dart';
import 'package:piwigo/pages/widget/listener/keyboard_listener.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/state.dart';
import 'package:piwigo/pages/widget/swiper/swiper.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:piwigo/utils/wrap.dart';

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

abstract class _ViewPageState extends MyState<MyViewPage> {
  final toolbarHeight = 50.0;
  final spacing = 8.0;
  Client get client => widget.client;
  Categorie get categorie => widget.categorie;
  dynamic _error;

  final _swiperController = SwiperController();
  bool _ready = true;
  void _resetReady() {
    if (_ready) {
      _ready = false;
      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        if (isNotClosed) {
          _ready = true;
        }
      });
    }
  }

  /// 是否已經獲取完整頁面數據
  bool _completed = false;

  /// 是否正在請求頁面數據
  bool _request = false;

  /// 已獲取的頁面數據
  PageInfo? _pageinfo;

  /// 圖像數據
  final _source = Source();

  /// 相冊數據
  final _categories = <Categorie>[];

  /// 網路請求取消標記
  final _cancelToken = CancelToken();

  /// 滾動條控制器
  final _scrollController = ScrollController();

  String getCategorieID(String id) => 'categorie_of_$id';
  String getImageID(String id) => 'image_of_$id';

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  /// 計算 圖像 佈局
  MyWrap _calculateImageWrap(Size size) {
    bool portrait = size.width < size.height;
    return portrait
        ? MyImage.calculateWrap(size, spacing, _source.list.length, count: 3)
        : MyImage.calculateWrap(size, spacing, _source.list.length, count: 6);
  }

  /// 計算相冊佈局
  MyWrap _calculateCategorieWrap(Size size) {
    return MyCover.calculateWrap(size, spacing, _categories.length);
  }

  _scrollTo(int i) {
    debugPrint('scrollTo $i');
    final size = MediaQuery.of(context).size;
    double jumpTo = 0;
    if (_categories.isNotEmpty) {
      final wrap = _calculateCategorieWrap(size);
      jumpTo = wrap.rows * (wrap.height + spacing);
    }
    final wrap = _calculateImageWrap(size);

    final row = wrap.calculateRow(i);
    final max = jumpTo + wrap.height * row;
    final height = size.height - toolbarHeight - 20; // - appbar
    final rows = height / wrap.height; // rows of screen
    var min = max - wrap.height * (rows - 1);
    if (min < 0) {
      min = 0;
    }
    var offset = _scrollController.offset;
    if (offset < min) {
      _scrollController.jumpTo(min);
    } else if (offset > max) {
      _scrollController.jumpTo(max);
    }
  }

  void _openView(int i) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => MyViewPage(
          client: client,
          categorie: _categories[i],
        ),
      ),
    )
        .then((value) {
      if (isNotClosed) {
        _resetReady();
      }
    });
  }

  void _openFullscreen(int i) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          _swiperController.value = i;
          return MyFullscreenPage(
            controller: _swiperController,
            source: _source.list,
          );
        },
      ),
    ).then((value) {
      if (isNotClosed) {
        _resetReady();
        final i = _swiperController.value;
        if (i >= 0 && i < _source.list.length) {
          final node = _source.list[i];
          final focus = getFocusNode(getImageID(node.id))?.focusNode;
          if (focus?.canRequestFocus ?? false) {
            _scrollTo(i);
            focus!.requestFocus();
          }
        }
      }
    });
  }

  _openUpload() {
    debugPrint("upload");
  }

  _openDownload() {
    final length = _source.list.length;
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => MyDownloadPage(
          client: client,
          source: categorie.images < 1 ? null : _source,
        ),
      ),
    )
        .then((value) {
      if (isNotClosed) {
        _resetReady();
        if (length != _source.list.length) {
          setState(() {});
        }
      }
    });
  }
}

class _MyViewPageState extends _ViewPageState
    with _NetComponent, _KeyboardComponent {
  @override
  void initState() {
    super.initState();
    _swiperController.addListener(_swiperControllerListener);
    Future.value().then((_) {
      if (isNotClosed) {
        _init();
      }
    });
  }

  @override
  void dispose() {
    _swiperController.removeListener(_swiperControllerListener);
    super.dispose();
  }

  _swiperControllerListener() {
    final index = _swiperController.value;

    if (!_request && !_completed) {
      final size = MediaQuery.of(context).size;
      final wrap = _calculateImageWrap(size);

      final rows = (index + wrap.cols - 1) ~/ wrap.cols;
      final start = rows * wrap.cols;
      var end = start + wrap.cols;
      if (end > _source.list.length) {
        end = _source.list.length;
      }
      debugPrint(
          "swipe to index=$index start=$start end=$end length=${_source.list.length} fit=${wrap.fit} cols=${wrap.cols}");
      if (end >= _source.list.length - wrap.fit) {
        _request = true;
        final page = _pageinfo!.page + 1;
        Future.value(page).then((page) {
          if (isNotClosed) {
            _getPage(page, force: true);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: toolbarHeight,
        leading: backOfAppBar(
          context,
          data: const MySelectAction(what: MyActionType.arrowBack),
        ),
        actions: [
          FocusScope(
            node: focusScopeNode,
            child: IconButton(
              focusNode: createFocusNode('download'),
              tooltip: S.of(context).photo.download,
              onPressed: disabled ? null : _openDownload,
              icon: const Icon(Icons.cloud_download),
            ),
          ),
          FocusScope(
            node: focusScopeNode,
            child: IconButton(
              focusNode: createFocusNode('upload'),
              tooltip: S.of(context).photo.upload,
              onPressed: disabled ? null : _openUpload,
              icon: const Icon(Icons.cloud_upload),
            ),
          ),
        ],
        title: Text(categorie.name),
      ),
      body: MyKeyboardListener(
        onKeyEvent: disabled ? null : _onKeyEvent,
        focusNode: createFocusNode('KeyboardListener'),
        child: _error == null
            ? _buildBody(context)
            : Text(
                "$_error",
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
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

  Widget _buildBody(BuildContext context) {
    if (_source.list.isEmpty && _categories.isEmpty) {
      return Container();
    }
    return OrientationBuilder(builder: (context, orientation) {
      final size = MediaQuery.of(context).size;
      bool portrait = size.width < size.height;
      final wrapImages = portrait
          ? MyImage.calculateWrap(size, spacing, _source.list.length, count: 3)
          : MyImage.calculateWrap(size, spacing, _source.list.length, count: 6);
      final wrapCategories =
          MyCover.calculateWrap(size, spacing, _categories.length);
      var count = wrapImages.rows + wrapCategories.rows + 1;
      return ListView.builder(
        controller: _scrollController,
        itemCount: count,
        itemBuilder: (context, index) {
          if (count == index + 1) {
            // bottom
            return SizedBox(
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
    return Container(
      padding: EdgeInsets.only(left: wrap.spacing, right: wrap.spacing),
      alignment: Alignment.topCenter,
      child: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(top: wrap.spacing),
        width: wrap.viewWidth,
        child: RowBuilder(
          start: start,
          end: end,
          itemBuilder: (context, i) {
            final node = _categories[i];
            var text = S.of(context).home.countPhoto(node.images);
            if (node.categories > 0 && node.totalImages >= node.images) {
              text += S
                  .of(context)
                  .home
                  .countPhotoInSub(node.totalImages - node.images);
            }
            final padding =
                start == i ? null : EdgeInsets.only(left: wrap.spacing);
            return FocusScope(
              autofocus: true,
              node: focusScopeNode,
              child: Container(
                padding: padding,
                child: MyCover(
                  focusNode: createFocusNode(
                    getCategorieID(node.id),
                    data: MySelectAction(
                      what: MyActionType.openView,
                      data: i,
                    ),
                  ),
                  onTap: disabled ? null : () => _openView(i),
                  url: node.cover,
                  title: node.name,
                  text: text,
                  width: wrap.width,
                  height: wrap.height,
                ),
              ),
            );
          },
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
    return Container(
      padding: EdgeInsets.only(left: wrap.spacing, right: wrap.spacing),
      alignment: Alignment.topCenter,
      child: Container(
        alignment: Alignment.topLeft,
        padding: padding,
        width: wrap.viewWidth,
        child: RowBuilder(
            start: start,
            end: end,
            itemBuilder: (context, i) {
              final node = _source.list[i];
              return FocusScope(
                autofocus: true,
                node: focusScopeNode,
                child: MyImage(
                  image: node,
                  width: wrap.width,
                  height: wrap.height,
                  focusNode: createFocusNode(
                    getImageID(node.id),
                    data: MySelectAction(
                      what: MyActionType.openFullscreen,
                      data: i,
                    ),
                  ),
                  onTap: () {
                    _openFullscreen(i);
                  },
                ),
              );
            }),
      ),
    );
  }
}

mixin _NetComponent on _ViewPageState {
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

  /// 請求頁面
  Future<void> _getPage(int page, {bool force = false}) async {
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
        // pageCount: 30,
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
}
mixin _KeyboardComponent on _ViewPageState {
  LogicalKeyboardKey? _lastKey;
  MyFocusNode? _lastLeft;
  MyFocusNode? _lastRight;
  _onKeyEvent(KeyEvent evt) {
    if (!_ready) {
      return;
    }
    if (evt is KeyDownEvent) {
      _lastKey = evt.logicalKey;
      if (evt.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _lastLeft = focusedNode();
      } else if (evt.logicalKey == LogicalKeyboardKey.arrowRight) {
        _lastRight = focusedNode();
      }
    } else if (evt is KeyUpEvent) {
      if (_lastKey == evt.logicalKey) {
        _onKeyTab(evt);
      }
      _lastKey = null;
      _lastLeft = null;
      _lastRight = null;
    } else {
      _lastKey = null;
    }
  }

  _onKeyTab(KeyEvent evt) {
    if (evt.logicalKey == LogicalKeyboardKey.select ||
        evt.logicalKey == LogicalKeyboardKey.enter) {
      _onSelected(evt);
    } else if (evt.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_lastLeft != null && _lastLeft == focusedNode()) {
        _focusLeft(_lastLeft!);
      }
    } else if (evt.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_lastRight != null && _lastRight == focusedNode()) {
        _focusRight(_lastRight!);
      }
    }
  }

  _focusLeft(MyFocusNode focused) {
    final data = focused.data;
    if (data is MySelectAction) {
      if (data.what == MyActionType.openFullscreen) {
        _focusImages(data.data, true);
      } else if (data.what == MyActionType.openView) {
        _focusCategories(data.data, true);
      }
    }
  }

  _focusRight(MyFocusNode focused) {
    final data = focused.data;
    if (data is MySelectAction) {
      if (data.what == MyActionType.openFullscreen) {
        _focusImages(data.data, false);
      } else if (data.what == MyActionType.openView) {
        _focusCategories(data.data, false);
      }
    }
  }

  _focusCategories(int i, bool left) {
    final size = MediaQuery.of(context).size;
    final wrap = _calculateCategorieWrap(size);
    _focusCols(i, left, wrap.cols);
  }

  _focusImages(int i, bool left) {
    final size = MediaQuery.of(context).size;
    final wrap = _calculateImageWrap(size);
    _focusCols(i, left, wrap.cols);
  }

  _focusCols(int i, bool left, int cols) {
    if (i % cols == 0) {
      final focusNode = getFocusNode(MyFocusNode.arrowBack)?.focusNode;
      if (focusNode?.canRequestFocus ?? false) {
        focusNode!.requestFocus();
      }
    } else if ((i + 1) % cols == 0) {
      final focusNode = getFocusNode('upload')?.focusNode;
      if (focusNode?.canRequestFocus ?? false) {
        focusNode!.requestFocus();
      }
    }
  }

  _onSelected(KeyEvent evt) {
    final focused = focusedNode();
    if (focused == null) {
      return;
    } else if (focused.id == "download") {
      if (evt.logicalKey == LogicalKeyboardKey.select) {
        _openDownload();
      }
      return;
    } else if (focused.id == "upload") {
      if (evt.logicalKey == LogicalKeyboardKey.select) {
        _openUpload();
      }
      return;
    }
    final data = focused.data;
    if (data is MySelectAction) {
      switch (data.what) {
        // case MyActionType.openDrawer:
        //   Scaffold.of(context).openDrawer();
        //   break;
        case MyActionType.openView:
          _openView(data.data);
          break;
        case MyActionType.arrowBack:
          if (evt.logicalKey == LogicalKeyboardKey.select) {
            Navigator.of(context).pop();
          }
          break;
        case MyActionType.openFullscreen:
          _openFullscreen(data.data);
          break;
        default:
      }
    }
  }
}
