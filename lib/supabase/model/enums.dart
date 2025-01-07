import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum ScoutingCategory {
  match('match'),
  pit('pit'),
  driveTeam('drive_team');

  final String value;

  const ScoutingCategory(this.value);
}

@JsonEnum(valueField: 'value')
enum DataType {
  number('number'),
  boolean('boolean'),
  string('string'),
  stringArray('string[]');

  final String value;

  const DataType(this.value);
}
