enum PermissionType {
  matchScouting('scout.match'),
  pitScouting('scout.pit'),
  driveTeamScouting('scout.drive_team'),
  manageTeam('team.manage'),
  teamAdmin('team.admin');

  final String value;

  const PermissionType(this.value);

  @override
  String toString() => value;

  static final _jsonMap =
      Map.fromEntries(PermissionType.values.map((e) => MapEntry(e.value, e)));
  factory PermissionType.fromJson(String json) => _jsonMap[json]!;
}
