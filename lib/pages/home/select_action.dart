enum MyActionType {
  openDrawer,
  openView,
}

class MySelectAction {
  const MySelectAction({required this.what, this.data});
  final MyActionType what;
  final dynamic data;
}
