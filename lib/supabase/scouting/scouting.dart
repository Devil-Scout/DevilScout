enum ScoutingCategory {
  match('match'),
  pit('pit'),
  driveTeam('drive_team');

  final String value;

  const ScoutingCategory(this.value);

  @override
  String toString() => value;

  static final _jsonMap =
      Map.fromEntries(ScoutingCategory.values.map((e) => MapEntry(e.value, e)));
  factory ScoutingCategory.fromJson(String json) => _jsonMap[json]!;
}

enum DataType {
  number('number'),
  boolean('boolean'),
  string('string'),
  stringArray('string[]');

  final String value;

  const DataType(this.value);

  @override
  String toString() => value;

  static final _jsonMap =
      Map.fromEntries(DataType.values.map((e) => MapEntry(e.value, e)));
  factory DataType.fromJson(String json) => _jsonMap[json]!;
}
