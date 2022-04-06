class MyWrap {
  /// 元素間距
  final double spacing;

  /// 視圖寬度
  final double viewWidth;

  /// 元素寬度
  final double width;

  /// 元素高度
  final double height;

  /// 每行多少個元素
  final int cols;

  /// 差多少個元素時向後端請求數據
  final int fit;

  /// 元素行數
  final int rows;

  const MyWrap({
    required this.spacing,
    required this.viewWidth,
    required this.width,
    required this.height,
    required this.cols,
    required this.rows,
    required this.fit,
  });

  int calculateRow(int index) {
    assert(index >= 0);
    return (index /*+1*/ + cols /*-1*/) ~/ cols - 1;
  }
}
