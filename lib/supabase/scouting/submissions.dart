import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase/supabase.dart';

import '../database.dart';
import 'scouting.dart';

part 'submissions.freezed.dart';
part 'submissions.g.dart';

@immutable
@freezed
class Submission with _$Submission {
  const factory Submission({
    required ScoutingCategory category,
    required int season,
    required int scoutedTeam,
    required DateTime createdAt,
    Uuid? scoutingUser,
    int? scoutingTeam,
    required String eventKey,
    String? matchKey,
  }) = _Submission;

  factory Submission.fromJson(JsonObject json) => _$SubmissionFromJson(json);
}

class SubmissionsRepository {
  final DataSubmissionService _service;

  final Cache<Uuid, Submission> _submissionsCache;

  SubmissionsRepository.supabase(SupabaseClient supabase)
      : this(DataSubmissionService(supabase));

  SubmissionsRepository(this._service)
      : _submissionsCache = Cache(
          expiration: const Duration(minutes: 30),
          origin: _service.getSubmission,
        );

  Future<Submission?> getSubmission({
    required Uuid submissionId,
    bool forceOrigin = false,
  }) =>
      _submissionsCache.get(key: submissionId, forceOrigin: forceOrigin);

  Future<void> submitMatch({
    required String matchKey,
    required int teamNum,
    required Map<Uuid, dynamic> data,
  }) =>
      _service.submitMatch(
        matchKey: matchKey,
        teamNum: teamNum,
        data: data,
      );

  Future<void> submitPit({
    required String eventKey,
    required int teamNum,
    required Map<Uuid, dynamic> data,
  }) =>
      _service.submitPit(
        eventKey: eventKey,
        teamNum: teamNum,
        data: data,
      );

  Future<void> submitDriveTeam({
    required String matchKey,
    required int teamNum,
    required Map<Uuid, dynamic> data,
  }) =>
      _service.submitDriveTeam(
        matchKey: matchKey,
        teamNum: teamNum,
        data: data,
      );
}

class DataSubmissionService {
  final SupabaseClient _supabase;

  DataSubmissionService(this._supabase);

  Future<Submission?> getSubmission(Uuid submissionId) async {
    final data = await _supabase
        .from('submissions')
        .select()
        .eq('id', submissionId)
        .maybeSingle();
    return data?.parse(Submission.fromJson);
  }

  Future<void> submitMatch({
    required String matchKey,
    required int teamNum,
    required Map<Uuid, dynamic> data,
  }) =>
      _submitScoutingData(
        category: ScoutingCategory.match,
        key: matchKey,
        teamNum: teamNum,
        data: data,
      );

  Future<void> submitPit({
    required String eventKey,
    required int teamNum,
    required Map<Uuid, dynamic> data,
  }) =>
      _submitScoutingData(
        category: ScoutingCategory.pit,
        key: eventKey,
        teamNum: teamNum,
        data: data,
      );

  Future<void> submitDriveTeam({
    required String matchKey,
    required int teamNum,
    required Map<Uuid, dynamic> data,
  }) =>
      _submitScoutingData(
        category: ScoutingCategory.driveTeam,
        key: matchKey,
        teamNum: teamNum,
        data: data,
      );

  Future<void> _submitScoutingData({
    required ScoutingCategory category,
    required String key,
    required int teamNum,
    required Map<Uuid, dynamic> data,
  }) async {
    await _supabase.rpc(
      'submit_scouting_data',
      params: {
        'category': category.value,
        'key': key,
        'team_num': teamNum,
        'data': data,
      },
    );
  }
}
