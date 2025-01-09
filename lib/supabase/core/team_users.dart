import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';
import 'core.dart';

part 'team_users.freezed.dart';
part 'team_users.g.dart';

@immutable
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required Uuid id,
    required String name,
    required DateTime createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(JsonObject json) => _$UserProfileFromJson(json);
}

@immutable
@freezed
class TeamUser with _$TeamUser {
  const factory TeamUser({
    required Uuid userId,
    required int teamNum,
    required Uuid addedBy,
    required DateTime addedAt,
    required UserProfile profile,
    required List<UserPermission> permissions,
  }) = _TeamUser;

  factory TeamUser.fromJson(JsonObject json) => _$TeamUserFromJson(json);
}

@immutable
@freezed
class UserPermission with _$UserPermission {
  const factory UserPermission({
    required Uuid userId,
    required int teamNum,
    required DateTime grantedAt,
    required Uuid grantedBy,
    required PermissionType type,
  }) = _UserPermission;

  factory UserPermission.fromJson(JsonObject json) =>
      _$UserPermissionFromJson(json);
}

class TeamUsersRepository {
  final TeamUsersService service;
  final CacheAll<Uuid, TeamUser> _teamUsersCache;

  TeamUsersRepository.supabase(SupabaseClient supabase)
      : this(TeamUsersService(supabase));

  TeamUsersRepository(this.service)
      : _teamUsersCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: service.getUser,
          originAll: service.getAllUsers,
          key: (user) => user.userId,
        );

  Future<TeamUser?> getUser({
    required Uuid userId,
    bool forceOrigin = false,
  }) =>
      _teamUsersCache.get(key: userId, forceOrigin: forceOrigin);

  Future<List<TeamUser>> getAllUsers({
    bool forceOrigin = false,
  }) =>
      _teamUsersCache.getAll(forceOrigin: forceOrigin);
}

class TeamUsersService {
  final SupabaseClient supabase;

  TeamUsersService(this.supabase);

  Future<TeamUser?> getUser(Uuid id) async {
    final data = await supabase
        .from('team_users')
        .select('*, users:profile(*), permissions(*)')
        .eq('user_id', id)
        .maybeSingle();
    return data?.parse(TeamUser.fromJson);
  }

  Future<List<TeamUser>> getAllUsers() async {
    final data = await supabase
        .from('team_users')
        .select('*, users:profile(*), permissions(*)');
    return data.parse(TeamUser.fromJson);
  }
}
