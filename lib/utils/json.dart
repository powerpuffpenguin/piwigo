List<T> listFromJson<T>(List? list) {
  return ((list?.map<T>((e) => e))?.toList()) ?? <T>[];
}

int intFromJson(v) {
  if (v == null) {
    return 0;
  } else if (v is int) {
    return v;
  }
  return int.parse(v);
}
