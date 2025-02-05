import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';
import 'scouting.dart';

part 'questions.freezed.dart';
part 'questions.g.dart';

@immutable
@Freezed(fromJson: true, toJson: true)
sealed class QuestionNode with _$QuestionNode {
  const factory QuestionNode.group({
    required Uuid id,
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
  yesNo('yes_no'),
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
}

mixin BooleanConfig {
  QuestionStyle get style;
}

mixin StringConfig {
  QuestionStyle get style;
  int? get maxLength;
  String? get regex;
  List<String>? get options;
}

mixin ArrayConfig {
  QuestionStyle get style;
  List<String>? get options;
  int? get minSelected;
  int? get maxSelected;
}

@immutable
class QuestionConfig
    with NumberConfig, BooleanConfig, StringConfig, ArrayConfig {
  final JsonObject _json;

  const QuestionConfig.fromJson(this._json);

  JsonObject toJson() => _json;

  @override
  QuestionStyle get style => QuestionStyle.fromJson(_json['style'] as String);

  @override
  num? get min => _json['min'] as num?;
  @override
  num? get max => _json['max'] as num?;
  @override
  num? get step => _json['step'] as num?;
  @override
  String? get unit => _json['unit'] as String?;
  @override
  int? get maxLength => _json['len'] as int?;
  @override
  String? get regex => _json['regex'] as String?;
  @override
  List<String>? get options => (_json['options'] as List<dynamic>?)?.cast();
  @override
  int? get minSelected => _json['least'] as int?;
  @override
  int? get maxSelected => _json['most'] as int?;
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

  final Map<int, CacheAll<Uuid, QuestionNode>> _questionsCaches;
  final Map<int, CacheAll<Uuid, QuestionDetails>> _detailsCaches;

  QuestionsRepository.supabase(SupabaseClient supabase)
      : this(QuestionsService(supabase));

  QuestionsRepository(this._service)
      : _questionsCaches = {},
        _detailsCaches = {};

  CacheAll<Uuid, QuestionNode> _questionsCache(int season) => CacheAll(
        expiration: const Duration(minutes: 30),
        origin: _service.getQuestion,
        originAll: () async => _service.getSeasonQuestions(season),
        key: (node) => node.id,
      );

  CacheAll<Uuid, QuestionDetails> _detailsCache(int season) => CacheAll(
        expiration: const Duration(minutes: 30),
        origin: (questionId) async =>
            _service.getDetails(season: season, questionId: questionId),
        originAll: () async => _service.getSeasonDetails(season),
        key: (details) => details.questionId,
      );

  Future<QuestionNode?> getQuestion({
    required int season,
    required Uuid questionId,
    bool forceOrigin = false,
  }) =>
      _questionsCaches
          .putIfAbsent(season, () => _questionsCache(season))
          .get(key: questionId, forceOrigin: forceOrigin);

  Future<List<QuestionNode>> getSeasonQuestions({
    required int season,
    bool forceOrigin = false,
  }) =>
      _questionsCaches
          .putIfAbsent(season, () => _questionsCache(season))
          .getAll(forceOrigin: forceOrigin);

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
