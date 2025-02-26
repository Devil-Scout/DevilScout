import 'dart:collection';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase/supabase.dart';

import '../database.dart';
import 'scouting.dart';

part 'questions.freezed.dart';
part 'questions.g.dart';

class QuestionTree {
  final QuestionNode node;
  final List<QuestionTree> children;

  QuestionGroup get group => node as QuestionGroup;
  Question get question => node as Question;
  bool get isQuestion => node is Question;

  QuestionTree({required this.node, required this.children});

  factory QuestionTree.build(Iterable<QuestionNode> nodes, QuestionNode root) {
    final children = nodes
        .where((n) => n.parentId == root.id)
        .map((n) => QuestionTree.build(nodes, n))
        .toList()
      ..sort((a, b) => a.node.index.compareTo(b.node.index));
    return QuestionTree(node: root, children: children);
  }
}

@immutable
@Freezed(fromJson: true, toJson: true)
sealed class QuestionNode with _$QuestionNode {
  const factory QuestionNode.group({
    required Uuid id,
    required int season,
    required ScoutingCategory category,
    required int index,
    Uuid? parentId,
    String? label,
  }) = QuestionGroup;

  const factory QuestionNode.question({
    required Uuid id,
    required int season,
    required ScoutingCategory category,
    required int index,
    required Uuid parentId,
    required String label,
    required DataType dataType,
    required QuestionConfig config,
  }) = Question;

  factory QuestionNode.fromJson(JsonObject json) {
    return json['data_type'] == null
        ? QuestionGroup.fromJson(json)
        : Question.fromJson(json);
  }
}

enum QuestionStyle {
  counter('counter'),
  textField('field'),
  checkbox('checkbox'),
  segmented('segmented'),
  radio('radio'),
  dropdown('dropdown');

  final String value;

  const QuestionStyle(this.value);

  @override
  String toString() => value;

  static final _jsonMap = Map.fromEntries(
    QuestionStyle.values.map((e) => MapEntry(e.value, e)),
  );
  factory QuestionStyle.fromJson(String json) => _jsonMap[json]!;
}

mixin NumberConfig {
  QuestionStyle get style;
  num? get min;
  num? get max;
  num? get step;
  String? get unit;

  bool validateNumber(num value) {
    if (!value.isFinite) return false;
    if (min != null && value < min!) return false;
    if (max != null && value > max!) return false;
    if (step != null && (value % step!) != 0) return false;
    return true;
  }
}

mixin BooleanConfig {
  QuestionStyle get style;

  // ignore: avoid_positional_boolean_parameters for function reference
  bool validateBool(bool value) => true;
}

mixin StringConfig {
  QuestionStyle get style;
  int? get maxLength;
  RegExp? get regex;
  Set<String>? get options;

  bool validateString(String value) {
    if (maxLength != null && value.length > maxLength!) return false;
    if (options != null && !options!.contains(value)) return false;
    if (regex != null && !regex!.hasMatch(value)) return false;
    return true;
  }
}

mixin ArrayConfig {
  QuestionStyle get style;
  Set<String>? get options;
  int? get minSelected;
  int? get maxSelected;

  bool validateArray(Iterable<String> value) {
    if (minSelected != null && value.length < minSelected!) return false;
    if (maxSelected != null && value.length > maxSelected!) return false;
    if (options != null && !options!.containsAll(value)) return false;
    return true;
  }
}

@immutable
class QuestionConfig
    with NumberConfig, BooleanConfig, StringConfig, ArrayConfig {
  final JsonObject _json;

  QuestionConfig.fromJson(this._json);

  JsonObject toJson() => _json;

  @override
  late final style = QuestionStyle.fromJson(_json['style'] as String);

  @override
  late final min = _json['min'] as num?;
  @override
  late final max = _json['max'] as num?;
  @override
  late final step = _json['step'] as num?;
  @override
  late final unit = _json['unit'] as String?;
  @override
  late final maxLength = _json['len'] as int?;
  @override
  late final regex =
      _json.containsKey('regex') ? RegExp(_json['regex'] as String) : null;
  @override
  late final options = _json.containsKey('options')
      ? LinkedHashSet.from(_json['options'] as List<dynamic>)
      : null;
  @override
  late final minSelected = _json['least'] as int?;
  @override
  late final maxSelected = _json['most'] as int?;

  bool validate(DataType type, dynamic value) => switch (type) {
        DataType.boolean => validateBool(value as bool),
        DataType.number => validateNumber(value as num),
        DataType.string => validateString(value as String),
        DataType.stringArray => validateArray(value as Iterable<String>),
      };
}

@immutable
@freezed
class QuestionDetails with _$QuestionDetails {
  const factory QuestionDetails({
    required Uuid questionId,
    required String markdown,
  }) = _QuestionDetails;
}

class QuestionsRepository {
  final QuestionsService _service;

  final Cache<int, List<QuestionNode>> _questions;
  final Map<int, CacheAll<Uuid, QuestionDetails>> _detailsCaches;

  QuestionsRepository.supabase(SupabaseClient supabase)
      : this(QuestionsService(supabase));

  QuestionsRepository(this._service)
      : _detailsCaches = {},
        _questions = Cache(
          expiration: const Duration(minutes: 30),
          origin: _service.getSeasonQuestions,
        );

  CacheAll<Uuid, QuestionDetails> _detailsCache(int season) => CacheAll(
        expiration: const Duration(minutes: 30),
        origin: (questionId) async =>
            _service.getDetails(season: season, questionId: questionId),
        originAll: () async => _service.getSeasonDetails(season),
        key: (details) => details.questionId,
      );

  Future<List<QuestionNode>?> getQuestions({
    required int season,
    bool forceOrigin = false,
  }) =>
      _questions.get(key: season, forceOrigin: forceOrigin);

  Future<QuestionDetails?> getDetails({
    required int season,
    required Uuid questionId,
    bool forceOrigin = false,
  }) =>
      _detailsCaches
          .putIfAbsent(season, () => _detailsCache(season))
          .get(key: questionId, forceOrigin: forceOrigin);

  Future<List<QuestionDetails>> getSeasonDetails({
    required int season,
    bool forceOrigin = false,
  }) =>
      _detailsCaches
          .putIfAbsent(season, () => _detailsCache(season))
          .getAll(forceOrigin: forceOrigin);
}

class QuestionsService {
  final SupabaseClient _supabase;

  QuestionsService(this._supabase);

  Future<QuestionNode?> getQuestion(Uuid questionId) async {
    final data = await _supabase
        .from('questions')
        .select()
        .eq('id', questionId)
        .maybeSingle();
    return data?.parse(QuestionNode.fromJson);
  }

  Future<List<QuestionNode>> getSeasonQuestions(int season) async {
    final data =
        await _supabase.from('questions').select().eq('season', season);
    return data.parse(QuestionNode.fromJson);
  }

  Future<QuestionDetails?> getDetails({
    required int season,
    required Uuid questionId,
  }) async {
    try {
      final data = await _supabase.storage
          .from('question-info')
          .download('$season/$questionId');
      return QuestionDetails(
        questionId: questionId,
        markdown: utf8.decode(data),
      );
    } on StorageException catch (_) {
      // file not found
      return null;
    }
  }

  Future<List<QuestionDetails>> getSeasonDetails(int season) async {
    final files =
        await _supabase.storage.from('question-info').list(path: '$season');
    final questionIds = files.map((file) => file.name);

    final data = await Future.wait(
      questionIds.map(
        (id) => _supabase.storage
            .from('question-info')
            .download('$season/$id')
            .then(utf8.decode),
      ),
    );

    return Map.fromIterables(questionIds, data)
        .entries
        .map(
          (entry) =>
              QuestionDetails(questionId: entry.key, markdown: entry.value),
        )
        .toList();
  }
}
