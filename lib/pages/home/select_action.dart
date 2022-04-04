enum MyActionType {
  openDrawer,
  openView,
  openFullscreen,
  arrowBack,
}

class MySelectAction {
  const MySelectAction({required this.what, this.data});
  final MyActionType what;
  final dynamic data;
}
