import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../database.dart';
import 'core.dart';

part 'users.freezed.dart';
part 'users.g.dart';

@immutable
@freezed
class User with _$User {
  const factory User({
    required UserId id,
    required String name,
    required DateTime createdAt,
    required TeamUser teamUser,
    required List<UserPermission> permissions,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@immutable
@freezed
class TeamUser with _$TeamUser {
  const factory TeamUser({
    required UserId userId,
    required int teamNum,
    required UserId addedBy,
    required DateTime addedAt,
  }) = _TeamUser;

  factory TeamUser.fromJson(Map<String, dynamic> json) =>
      _$TeamUserFromJson(json);
}

@immutable
@freezed
class UserPermission with _$UserPermission {
  const factory UserPermission({
    required UserId userId,
    required int teamNum,
    required DateTime grantedAt,
    required UserId grantedBy,
    required PermissionType type,
  }) = _UserPermission;

  factory UserPermission.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionFromJson(json);
}

class TeamUsersRepository {
  final TeamUsersService service;
  final CacheAll<UserId, User> _teamUsersCache;

  TeamUsersRepository.supabase(SupabaseClient supabase)
      : this(TeamUsersService(supabase));

  TeamUsersRepository(this.service)
      : _teamUsersCache = CacheAll(
          expiration: const Duration(minutes: 30),
          origin: service.getUser,
          originAll: service.getAllUsers,
          key: (user) => user.id,
        );

  Future<User?> getUser({
    required UserId userId,
    bool forceOrigin = false,
  }) =>
      _teamUsersCache.get(
        key: userId,
        forceOrigin: forceOrigin,
      );

  Future<List<User>> getAllUsers({
    bool forceOrigin = false,
  }) =>
      _teamUsersCache.getAll(
        forceOrigin: forceOrigin,
      );
}

class TeamUsersService {
  final SupabaseClient supabase;

  TeamUsersService(this.supabase);

  Future<User?> getUser(UserId id) async {
    final data = await supabase
        .from('users')
        .select('*, team_users:team_user(*), permissions(*)')
        .eq('id', id)
        .maybeSingle();
    return data?.parse(User.fromJson);
  }

  Future<List<User>> getAllUsers() async {
    final data = await supabase
        .from('users')
        .select('*, team_users:team_user(*), permissions(*)')
        .not('team_user.team_num', 'is', null);
    return data.parse(User.fromJson);
  }
}
