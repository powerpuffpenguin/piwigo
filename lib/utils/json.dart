List<T> listFromJson<T>(List? list) {
  return ((list?.map<T>((e) => e))?.toList()) ?? <T>[];
}
