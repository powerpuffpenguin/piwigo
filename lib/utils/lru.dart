import 'dart:collection';

class Lru<TK, TV> {
  final int max;
  final _list = LinkedList<_Element<TK, TV>>();
  final _keys = <TK, _Element<TK, TV>>{};
  Lru(this.max) : assert(max > -1);
  TV? get(TK key) {
    final ele = _keys[key];
    if (ele == null) {
      return null;
    }
    ele.unlink();
    _list.add(ele);
    return ele.value;
  }

  TV? delete(TK key) {
    final ele = _keys[key];
    if (ele == null) {
      return null;
    }
    ele.unlink();
    _keys.remove(key);
    return ele.value;
  }

  TV? put(TK key, TV val) {
    if (max == 0) {
      return val;
    }

    final ele = _keys[key];
    if (ele != null) {
      final old = ele.value;
      if (old == val) {
        ele.unlink();
        _list.add(ele);
        return null;
      }
      ele.value = val;
      ele.unlink();
      _list.add(ele);
      return old;
    }
    final add = _Element(key: key, value: val);
    _list.add(add);
    _keys[key] = add;

    if (_list.length == max) {
      return _popFirst();
    }
    return null;
  }

  TV _popFirst() {
    final first = _list.first;
    final val = first.value;
    _keys.remove(first.key);
    first.unlink();
    return val;
  }
}

class _Element<TK, TV> extends LinkedListEntry<_Element<TK, TV>> {
  final TK key;
  TV value;

  _Element({
    required this.key,
    required this.value,
  });

  @override
  String toString() {
    return "$key=$value";
  }
}
