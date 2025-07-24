import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase/supabase.dart';

import '../base/current_user.dart';
import '../database.dart';
import 'core.dart';

part 'team_users.freezed.dart';
part 'team_users.g.dart';

@immutable
@freezed
@JsonSerializable()
final class TeamUser with _$TeamUser {
  @override
  final Uuid userId;
  @override
  final int teamNum;
  @override
  final Uuid? addedBy;
  @override
  final DateTime addedAt;
  @override
  final UserProfile profile;
  @override
  final List<UserPermission> permissions;

  const TeamUser({
    required this.userId,
    required this.teamNum,
    this.addedBy,
    required this.addedAt,
    required this.profile,
    required this.permissions,
  });

  factory TeamUser.fromJson(JsonObject json) => _$TeamUserFromJson(json);
}

@immutable
@freezed
@JsonSerializable()
final class UserPermission with _$UserPermission {
  @override
  final Uuid userId;
  @override
  final int teamNum;
  @override
  final DateTime grantedAt;
  @override
  final Uuid grantedBy;
  @override
  final PermissionType type;

  const UserPermission({
    required this.userId,
    required this.teamNum,
    required this.grantedAt,
    required this.grantedBy,
    required this.type,
  });

  factory UserPermission.fromJson(JsonObject json) =>
      _$UserPermissionFromJson(json);
}

class TeamUsersRepository {
  final TeamUsersService _service;
  final CacheAll<Uuid, TeamUser> _teamUsersCache;

  TeamUsersRepository.supabase(SupabaseClient supabase)
      : this(TeamUsersService(supabase));

  TeamUsersRepository(this._service)
      : _teamUsersCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: _service.getUser,
          originAll: _service.getAllUsers,
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

  Future<void> addUser(Uuid userId) => _service.addUser(userId);

  Future<void> removeUser(Uuid userId) => _service.removeUser(userId);

  Future<void> grantPermission({
    required Uuid userId,
    required PermissionType type,
  }) =>
      _service.grantPermission(userId: userId, type: type);

  Future<void> revokePermission({
    required Uuid userId,
    required PermissionType type,
  }) =>
      _service.revokePermission(userId: userId, type: type);
}

class TeamUsersService {
  final SupabaseClient _supabase;

  TeamUsersService(this._supabase);

  Future<TeamUser?> getUser(Uuid id) async {
    final data = await _supabase
        .from('team_users')
        .select(
          '*, profile:profiles!team_users_user_id_fkey(*), permissions!permissions_team_num_user_id_fkey(*)',
        )
        .eq('user_id', id)
        .maybeSingle();
    return data?.parse(TeamUser.fromJson);
  }

  Future<List<TeamUser>> getAllUsers() async {
    final data = await _supabase.from('team_users').select(
          '*, profile:profiles!team_users_user_id_fkey(*), permissions!permissions_team_num_user_id_fkey(*)',
        );
    return data.parse(TeamUser.fromJson);
  }

  Future<void> addUser(Uuid userId) =>
      _supabase.from('team_users').insert({'user_id': userId});

  Future<void> removeUser(Uuid userId) =>
      _supabase.from('team_users').delete().eq('user_id', userId);

  Future<void> grantPermission({
    required Uuid userId,
    required PermissionType type,
  }) =>
      _supabase.from('permissions').insert({
        'user_id': userId,
        'type': type,
      });

  Future<void> revokePermission({
    required Uuid userId,
    required PermissionType type,
  }) =>
      _supabase
          .from('permissions')
          .delete()
          .eq('user_id', userId)
          .eq('type', type);
}
