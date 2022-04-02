import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SwiperController extends ValueNotifier<int> {
  SwiperController({int offset = 0}) : super(offset);
  void swipeTo(int offset) {
    if (_swipeTo != null) {
      _swipeTo!(offset);
    }
  }

  ValueChanged<int>? _swipeTo;
  void setSwipeTo(ValueChanged<int>? f) {
    _swipeTo = f;
  }
}

enum GestureMode {
  none,
  listener,
  gesture,
}

class BuildDetails {
  /// 構建元素索引
  final int index;

  /// 是否處於滑動中
  final bool swipe;
  const BuildDetails({
    required this.index,
    required this.swipe,
  });
}

typedef SwiperBuilder = Widget Function(
    BuildContext context, BuildDetails details);

class Swiper extends StatefulWidget {
  const Swiper({
    Key? key,
    this.direction = Axis.horizontal,
    required this.itemCount,
    required this.itemBuilder,
    this.initOffset,
    this.controller,
    this.width,
    this.height,
    this.onChanged,
    this.gestureMode = GestureMode.listener,
  }) : super(key: key);
  final Axis direction;
  final int itemCount;
  final SwiperBuilder itemBuilder;
  final int? initOffset;
  final SwiperController? controller;
  final double? width;
  final double? height;
  final ValueChanged<int>? onChanged;
  final GestureMode gestureMode;
  @override
  _SwiperState createState() => _SwiperState();
}

enum _State {
  normal,
  swipe,
  cancel,
  submit,
  swipeTo,
}

class _SwiperState extends State<Swiper> {
  Axis get direction => widget.direction;
  int get itemCount => widget.itemCount;
  SwiperBuilder get itemBuilder => widget.itemBuilder;
  SwiperController? _controller;
  SwiperController get controller {
    if (_controller == null) {
      _controller = widget.controller;
      _controller ??= SwiperController(offset: widget.initOffset ?? 0);
      _controller!.setSwipeTo(_swipeTo);
    }
    return _controller!;
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.setSwipeTo(null);
      if (widget.controller == null) {
        _controller!.dispose();
      }
    }
    super.dispose();
  }

  int _swipeOffset = 0;
  void _swipeTo(int offset) {
    if (_state != _State.normal || offset == controller.value) {
      return;
    }
    setState(() {
      _swipeOffset = offset;
      _state = _State.swipeTo;
    });
  }

  var _state = _State.normal;
  double _offset = 0;
  _cancel(double width, double height) {
    if (_state != _State.swipe) {
      return;
    }
    final other = _getOther(width, height);
    if (other == null) {
      setState(() {
        _state = _State.normal;
        _offset = 0;
      });
    } else {
      setState(() {
        _state = _State.cancel;
      });
    }
  }

  _submit(double width, double height) {
    if (_state != _State.swipe) {
      return;
    }
    final other = _getOther(width, height);
    if (other == null) {
      setState(() {
        _state = _State.normal;
        _offset = 0;
      });
    } else {
      final offet =
          direction == Axis.horizontal ? other.item1.dx : other.item1.dy;
      if (offet > 0.01 || offet < -0.01) {
        setState(() {
          _state = _State.submit;
        });
      } else {
        setState(() {
          _state = _State.normal;
          _offset = 0;
          if (controller.value != other.item2) {
            controller.value = other.item2;
            if (widget.onChanged != null) {
              widget.onChanged!(other.item2);
            }
          }
        });
      }
    }
  }

  _onUpdate(double width, double height, Offset delta) {
    if (_state == _State.normal) {
      final moveBy = direction == Axis.horizontal ? delta.dx : delta.dy;
      const short = 5.0;
      if (moveBy > -short && moveBy < short) {
        return;
      }
      setState(() {
        _state = _State.swipe;
      });
    } else if (_state != _State.swipe) {
      return;
    }
    setState(() {
      if (direction == Axis.horizontal) {
        _offset += delta.dx;
        if (_offset > width) {
          _offset = width;
        } else if (_offset < -width) {
          _offset = -width;
        }
      } else {
        _offset += delta.dy;
        if (_offset > height) {
          _offset = height;
        } else if (_offset < -height) {
          _offset = -height;
        }
      }
    });
  }

  _onEnd(double width, double height) {
    if (direction == Axis.horizontal) {
      if (_offset.abs() > width / 3) {
        _submit(width, height);
      } else {
        _cancel(width, height);
      }
    } else {
      if (_offset.abs() > height / 3) {
        _submit(width, height);
      } else {
        _cancel(width, height);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    final width = widget.width ?? size.width;
    final height = widget.height ?? size.height;
    switch (widget.gestureMode) {
      case GestureMode.listener:
        return Listener(
          // onPointerDown: (evt) {
          //   debugPrint('onPointerDown ${evt.delta}');
          // },
          onPointerMove: (evt) {
            // debugPrint('onPointerMove ${evt.delta}');
            _onUpdate(width, height, evt.delta);
          },
          onPointerUp: (evt) {
            _onEnd(width, height);
            // debugPrint('onPointerUp ${evt.delta}');
          },
          // onPointerHover: (evt) {
          //   debugPrint('onPointerHover $evt');
          // },
          onPointerCancel: (evt) {
            _cancel(width, height);
          },
          // onPointerSignal: (evt) {
          //   debugPrint('onPointerSignal $evt');
          // },
          child: _buildBody(context, width, height),
        );
      case GestureMode.gesture:
        return GestureDetector(
          // onPanStart: (details) {
          //   debugPrint('onPanStart $details');
          // },
          onPanEnd: (details) {
            _onEnd(width, height);
          },
          onPanUpdate: (details) {
            _onUpdate(width, height, details.delta);
          },
          onPanCancel: () {
            _cancel(width, height);
          },
          child: _buildBody(context, width, height),
        );
      default:
        return _buildBody(context, width, height);
    }
  }

  Widget _buildBody(BuildContext context, double width, double height) {
    switch (_state) {
      case _State.normal:
        return _buildItem(
          context,
          width,
          height,
          BuildDetails(
            index: controller.value,
            swipe: false,
          ),
        );
      case _State.cancel:
        return _buildCancel(context, width, height);
      case _State.submit:
        return _buildSubmit(context, width, height);
      case _State.swipeTo:
        return _buildSwipeTo(context, width, height);
      default: // _State.swipe
    }
    final offset =
        direction == Axis.horizontal ? Offset(_offset, 0) : Offset(0, _offset);
    final other = _getOther(width, height);
    if (other == null) {
      return _buildItem(
        context,
        width,
        height,
        BuildDetails(
          index: controller.value,
          swipe: false,
        ),
      );
    }
    return Stack(
      children: [
        Transform.translate(
          offset: other.item1,
          child: _buildItem(
            context,
            width,
            height,
            BuildDetails(
              index: other.item2,
              swipe: true,
            ),
          ),
        ),
        Transform.translate(
          offset: offset,
          child: _buildItem(
            context,
            width,
            height,
            BuildDetails(
              index: controller.value,
              swipe: true,
            ),
          ),
        ),
      ],
    );
  }

  static const min = Duration(milliseconds: 100);
  static const max = Duration(milliseconds: 800);
  Widget _buildCancel(BuildContext context, double width, double height) {
    final offset =
        direction == Axis.horizontal ? Offset(_offset, 0) : Offset(0, _offset);
    final other = _getOther(width, height);
    var durantion = Duration(milliseconds: _offset.toInt().abs());
    if (durantion < min) {
      durantion = min;
    } else if (durantion > max) {
      durantion = max;
    }
    if (other != null) {
      return _SwiperAnimation(
        duration: durantion,
        onCompleted: () {
          setState(() {
            _state = _State.normal;
            _offset = 0;
          });
        },
        src: offset,
        target: const Offset(0, 0),
        builder: (context) => _buildItem(
          context,
          width,
          height,
          BuildDetails(
            index: controller.value,
            swipe: true,
          ),
        ),
        otherSrc: other.item1,
        otherTarget: _getOut(other.item1, width, height),
        otherBuilder: (context) => _buildItem(
          context,
          width,
          height,
          BuildDetails(
            index: other.item2,
            swipe: true,
          ),
        ),
      );
    }
    return _SwiperAnimation(
      duration: durantion,
      onCompleted: () {
        setState(() {
          _state = _State.normal;
          _offset = 0;
        });
      },
      src: offset,
      target: const Offset(0, 0),
      builder: (context) => _buildItem(
        context,
        width,
        height,
        BuildDetails(
          index: controller.value,
          swipe: true,
        ),
      ),
    );
  }

  Widget _buildSwipeTo(BuildContext context, double width, double height) {
    final offset =
        direction == Axis.horizontal ? Offset(_offset, 0) : Offset(0, _offset);
    final other = _getSwipeTo(width, height, _swipeOffset);
    if (other == null) {
      _state = _State.cancel;
      return _buildCancel(context, width, height);
    }
    final sub = direction == Axis.horizontal ? width : height;
    var durantion =
        Duration(milliseconds: (sub.toInt() - (_offset).toInt().abs()).abs());
    if (durantion < min) {
      durantion = min;
    } else if (durantion > max) {
      durantion = max;
    }
    var out = _getOut(offset, width, height);
    return _SwiperAnimation(
      duration: durantion,
      onCompleted: () {
        setState(() {
          _state = _State.normal;
          _offset = 0;
          if (controller.value != other.item2) {
            controller.value = other.item2;
            if (widget.onChanged != null) {
              widget.onChanged!(other.item2);
            }
          }
        });
      },
      src: other.item1,
      target: const Offset(0, 0),
      builder: (context) => _buildItem(
        context,
        width,
        height,
        BuildDetails(
          index: other.item2,
          swipe: true,
        ),
      ),
      otherSrc: offset,
      otherTarget: other.item2 > controller.value ? -out : out,
      otherBuilder: (context) => _buildItem(
        context,
        width,
        height,
        BuildDetails(
          index: controller.value,
          swipe: true,
        ),
      ),
    );
  }

  Widget _buildSubmit(BuildContext context, double width, double height) {
    final offset =
        direction == Axis.horizontal ? Offset(_offset, 0) : Offset(0, _offset);
    final other = _getOther(width, height);
    if (other == null) {
      _state = _State.cancel;
      return _buildCancel(context, width, height);
    }
    final sub = direction == Axis.horizontal ? width : height;
    var durantion = Duration(
        milliseconds:
            (sub.toInt() - (_offset).toInt().abs()).abs() * 100 ~/ 80);
    if (durantion < min) {
      durantion = min;
    } else if (durantion > max) {
      durantion = max;
    }
    return _SwiperAnimation(
      duration: durantion,
      onCompleted: () {
        setState(() {
          _state = _State.normal;
          _offset = 0;
          if (controller.value != other.item2) {
            controller.value = other.item2;
            if (widget.onChanged != null) {
              widget.onChanged!(other.item2);
            }
          }
        });
      },
      src: other.item1,
      target: const Offset(0, 0),
      builder: (context) => _buildItem(
        context,
        width,
        height,
        BuildDetails(
          index: other.item2,
          swipe: true,
        ),
      ),
      otherSrc: offset,
      otherTarget: _getOut(offset, width, height),
      otherBuilder: (context) => _buildItem(
        context,
        width,
        height,
        BuildDetails(
          index: controller.value,
          swipe: true,
        ),
      ),
    );
  }

  Offset _getOut(Offset offset, double width, double height) {
    if (direction == Axis.horizontal) {
      if (offset.dx < 0) {
        return Offset(-width, 0);
      } else {
        return Offset(width, 0);
      }
    } else {
      if (offset.dy < 0) {
        return Offset(0, -height);
      } else {
        return Offset(0, height);
      }
    }
  }

  Tuple2<Offset, int>? _getOther(double width, double height) {
    if (_offset > 0.01) {
      return _getPrevious(width, height);
    } else if (_offset < -0.01) {
      return _getNext(width, height);
    } else {
      // 滑動距離不夠忽略
      return null;
    }
  }

  Tuple2<Offset, int>? _getSwipeTo(double width, double height, int i) {
    if (i < controller.value) {
      final offet = direction == Axis.horizontal
          ? Offset(_offset - width, 0)
          : Offset(0, _offset - height);
      return Tuple2(offet, i);
    }
    final offet = direction == Axis.horizontal
        ? Offset(_offset + width, 0)
        : Offset(0, _offset + height);
    return Tuple2(offet, i);
  }

  Tuple2<Offset, int>? _getNext(double width, double height) {
    final next = controller.value + 1;
    if (next >= itemCount) {
      // 沒有下一個
      return null;
    }
    final offet = direction == Axis.horizontal
        ? Offset(_offset + width, 0)
        : Offset(0, _offset + height);
    return Tuple2(offet, next);
  }

  Tuple2<Offset, int>? _getPrevious(double width, double height) {
    final previous = controller.value - 1;
    if (previous < 0) {
      // 沒有上一個
      return null;
    }
    final offet = direction == Axis.horizontal
        ? Offset(_offset - width, 0)
        : Offset(0, _offset - height);
    return Tuple2(offet, previous);
  }

  Widget _buildItem(
      BuildContext context, double width, double height, BuildDetails details) {
    return SizedBox(
      width: width,
      height: height,
      child: itemBuilder(context, details),
    );
  }
}

class _SwiperAnimation extends StatefulWidget {
  const _SwiperAnimation({
    Key? key,
    required this.src,
    required this.target,
    required this.builder,
    required this.onCompleted,
    this.otherSrc,
    this.otherTarget,
    this.otherBuilder,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);
  final Offset src;
  final Offset target;
  final WidgetBuilder builder;

  final Offset? otherSrc;
  final Offset? otherTarget;
  final WidgetBuilder? otherBuilder;
  final Duration duration;
  final VoidCallback onCompleted;
  @override
  _SwiperAnimationState createState() => _SwiperAnimationState();
}

class _SwiperAnimationState extends State<_SwiperAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> animation;
  Animation<Offset>? otherAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted();
        }
      });
    animation = Tween<Offset>(begin: widget.src, end: widget.target)
        .animate(controller);
    if (widget.otherBuilder != null &&
        widget.otherSrc != null &&
        widget.otherTarget != null) {
      otherAnimation =
          Tween<Offset>(begin: widget.otherSrc, end: widget.otherTarget)
              .animate(controller);
    }
    controller.forward();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (otherAnimation != null) {
      return Stack(
        children: [
          _buildBody(context, otherAnimation!, widget.otherBuilder!),
          _buildBody(context, animation, widget.builder),
        ],
      );
    }
    return _buildBody(context, animation, widget.builder);
  }

  Widget _buildBody(BuildContext context, Animation<Offset> animation,
      WidgetBuilder builder) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: animation.value,
          child: child,
        );
      },
      child: builder(context),
    );
  }
}
