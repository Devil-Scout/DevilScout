import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(valueField: 'value')
enum PermissionType {
  matchScouting('scout.match'),
  pitScouting('scout.pit'),
  driveTeamScouting('scout.drive_team'),
  manageTeam('manage_team');

  final String value;

  const PermissionType(this.value);
}
