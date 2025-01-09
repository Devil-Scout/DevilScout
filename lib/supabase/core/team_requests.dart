import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../database.dart';
import 'core.dart';
import 'users.dart';

part 'team_requests.freezed.dart';
part 'team_requests.g.dart';

@immutable
@freezed
class TeamRequest with _$TeamRequest {
  const factory TeamRequest({
    required String userId,
    required DateTime requestedAt,
    required int teamNum,
    required User user,
  }) = _TeamRequest;

  factory TeamRequest.fromJson(Map<String, dynamic> json) =>
      _$TeamRequestFromJson(json);
}

@immutable
@freezed
class RequestUser with _$RequestUser {
  const factory RequestUser({
    required UserId id,
    required String name,
    required DateTime createdAt,
  }) = _RequestUser;

  factory RequestUser.fromJson(Map<String, dynamic> json) =>
      _$RequestUserFromJson(json);
}

class TeamRequestsRepository {
  final CacheAll<UserId, TeamRequest> _teamsCache;

  TeamRequestsRepository.supabase(SupabaseClient supabase)
      : this(TeamRequestsService(supabase));

  TeamRequestsRepository(TeamRequestsService service)
      : _teamsCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: service.getRequest,
          originAll: service.getAllRequests,
          key: (request) => request.userId,
        );

  Future<TeamRequest?> getTeam({
    required String userId,
    bool forceOrigin = false,
  }) =>
      _teamsCache.get(
        key: userId,
        forceOrigin: forceOrigin,
      );

  Future<List<TeamRequest>> getAllRequests({
    bool forceOrigin = false,
  }) =>
      _teamsCache.getAll(
        forceOrigin: forceOrigin,
      );
}

class TeamRequestsService {
  final SupabaseClient supabase;

  TeamRequestsService(this.supabase);

  Future<TeamRequest?> getRequest(String userId) async {
    final data = await supabase
        .from('team_requests')
        .select('*, users:user(*)')
        .eq('user_id', userId)
        .maybeSingle();
    return data?.parse(TeamRequest.fromJson);
  }

  Future<List<TeamRequest>> getAllRequests() async {
    final data = await supabase.from('team_requests').select('*,users:user(*)');
    return data.parse(TeamRequest.fromJson);
  }
}
