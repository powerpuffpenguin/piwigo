class Enum {
  final int value;
  final String name;
  const Enum(this.value, this.name);
  @override
  bool operator ==(Object other);
  @override
  int get hashCode => value;
  @override
  String toString() => name;
}
