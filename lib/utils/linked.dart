import 'dart:collection';

class LinkedValue<T> extends LinkedListEntry<LinkedValue<T>> {
  final T value;

  LinkedValue(this.value);

  @override
  String toString() {
    return value.toString();
  }
}
