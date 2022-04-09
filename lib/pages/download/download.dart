import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/download/source.dart';
import 'package:piwigo/pages/widget/listener/keyboard_listener.dart';
import 'package:piwigo/pages/widget/state.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:piwigo/service/download_service.dart';

class MyDownloadPage extends StatefulWidget {
  const MyDownloadPage({
    Key? key,
    required this.client,
    required this.source,
    required this.downloadService,
    required this.categorie,
    required this.pageinfo,
    required this.scrollController,
  }) : super(key: key);
  final Client client;
  final DownloadService downloadService;
  final Source? source;
  final Categorie? categorie;
  final PageInfo? pageinfo;
  final ScrollController? scrollController;
  @override
  _MyDownloadPageState createState() => _MyDownloadPageState();
}

abstract class _DownloadPageState extends MyState<MyDownloadPage> {
  Client get client => widget.client;
  Source? get source => widget.source;
  Categorie? get categorie => widget.categorie;
  PageInfo? get pageinfo => widget.pageinfo;
  ScrollController? get scrollController => widget.scrollController;
  bool get canDownload =>
      source != null &&
      categorie != null &&
      pageinfo != null &&
      scrollController != null;

  /// 瀏覽下載進度
  _browseProgress() {
    debugPrint("browseProgress");
  }

  /// 下載整個相冊
  _downloadCategorie() {
    debugPrint("downloadCategorie");
  }

  /// 下載選定照片
  _downloadPhoto() {
    debugPrint("downloadPhoto");
  }
}

class _MyDownloadPageState extends _DownloadPageState with _KeyboardComponent {
  @override
  Widget build(BuildContext context) {
    return MyKeyboardListener(
      focusNode: createFocusNode('MyKeyboardListener'),
      child: _build(context),
      onKeyTab: disabled ? null : _onKeyTab,
    );
  }

  Widget _build(BuildContext context) {
    final ok = canDownload;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).photo.download),
        leading: backOfAppBar(
          context,
        ),
      ),
      body: ListView(
        children: <Widget>[
          FocusScope(
            node: focusScopeNode,
            child: ListTile(
              focusNode: createFocusNode('browse_progress'),
              leading: const Icon(Icons.view_list),
              title: Text(S.of(context).download.browseProgress),
              onTap: disabled ? null : _browseProgress,
            ),
          ),
          ok
              ? FocusScope(
                  node: focusScopeNode,
                  child: ListTile(
                    focusNode: createFocusNode('download_categorie'),
                    leading: const Icon(Icons.photo),
                    title: Text(S.of(context).download.categorie),
                    onTap: disabled ? null : _downloadCategorie,
                  ),
                )
              : Container(),
          ok
              ? FocusScope(
                  node: focusScopeNode,
                  child: ListTile(
                    focusNode: createFocusNode('download_photo'),
                    leading: const Icon(Icons.add_photo_alternate),
                    title: Text(S.of(context).download.photo),
                    onTap: disabled ? null : _downloadPhoto,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

mixin _KeyboardComponent on _DownloadPageState {
  void _onKeyTab(KeyEvent evt) {
    if (evt.logicalKey == LogicalKeyboardKey.select) {
      final focused = focusedNode();
      switch (focused?.id ?? '') {
        case 'browse_progress':
          _browseProgress();
          break;
        case 'download_categorie':
          _downloadCategorie();
          break;
        case 'download_photo':
          _downloadPhoto();
          break;
      }
    }
  }
}
