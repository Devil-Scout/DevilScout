// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'questions.freezed.dart';
part 'questions.g.dart';

@Freezed(fromJson: true)
sealed class QuestionNode with _$QuestionNode {
  const factory QuestionNode.group({
    required String id,
    required int season,
    required ScoutingCategory category,
    String? prompt,
    @JsonKey(name: 'parent_id') String? parentId,
    int? index,
  }) = QuestionGroup;

  const factory QuestionNode.question({
    required String id,
    required int season,
    required ScoutingCategory category,
    required String prompt,
    @JsonKey(name: 'parent_id') String? parentId,
    int? index,
    @JsonKey(name: 'data_type') required DataType dataType,
    required Map<String, dynamic> config,
  }) = Question;

  factory QuestionNode.fromJson(Map<String, dynamic> json) {
    return json['data_type'] == null
        ? QuestionGroup.fromJson(json)
        : Question.fromJson(json);
  }
}
