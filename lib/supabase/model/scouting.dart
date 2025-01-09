import 'package:freezed_annotation/freezed_annotation.dart';

part 'scouting.freezed.dart';
part 'scouting.g.dart';

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

@immutable
@Freezed(fromJson: true, toJson: true)
sealed class QuestionNode with _$QuestionNode {
  const factory QuestionNode.group({
    required String id,
    required int season,
    required ScoutingCategory category,
    String? prompt,
    String? parentId,
    int? index,
  }) = QuestionGroup;

  const factory QuestionNode.question({
    required String id,
    required int season,
    required ScoutingCategory category,
    required String prompt,
    required String parentId,
    required int index,
    required DataType dataType,
    required Map<String, dynamic> config,
  }) = Question;

  factory QuestionNode.fromJson(Map<String, dynamic> json) {
    return json['data_type'] == null
        ? QuestionGroup.fromJson(json)
        : Question.fromJson(json);
  }
}
