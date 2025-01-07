// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'questions.freezed.dart';
part 'questions.g.dart';

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

@Freezed(fromJson: true, makeCollectionsUnmodifiable: false)
sealed class QuestionNode with _$QuestionNode {
  const factory QuestionNode.group({
    required String id,
    required int season,
    required ScoutingCategory category,
    String? prompt,
    @JsonKey(name: 'parent_id') String? parentId,
    int? index,
    @JsonKey(includeFromJson: false) @Default([]) List<QuestionNode> children,
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

  factory QuestionNode.buildTree(List<Map<String, dynamic>> json) {
    final questions = {
      for (final node in json.map(QuestionNode.fromJson)) node.id: node
    };

    late final QuestionNode root;
    for (final node in questions.values) {
      final parentId = node.parentId;
      if (parentId == null) {
        root = node;
        continue;
      }

      final parent = questions[parentId];
      if (parent == null) {
        throw 'parent of question is missing: ${node.id}';
      } else if (parent is! QuestionGroup) {
        throw 'parent of question is not group: ${node.id} -> ${parent.id}';
      }

      parent.children.add(node);
    }

    return root;
  }
}
