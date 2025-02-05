enum FrcMatchLevel {
  qualification('qm'),
  elimination('em'),
  quarterfinals('qf'),
  semifinals('sf'),
  finals('f');

  final String value;

  const FrcMatchLevel(this.value);

  @override
  String toString() => value;

  static final _jsonMap =
      Map.fromEntries(FrcMatchLevel.values.map((e) => MapEntry(e.value, e)));
  factory FrcMatchLevel.fromJson(String json) => _jsonMap[json]!;
}

enum FrcAlliance {
  blue,
  red;

  @override
  String toString() => name;

  static final _jsonMap = FrcAlliance.values.asNameMap();
  factory FrcAlliance.fromJson(String json) => _jsonMap[json]!;
}
