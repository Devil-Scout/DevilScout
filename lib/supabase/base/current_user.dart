import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:supabase/supabase.dart';

import '../core/core.dart';
import '../database.dart';

part 'current_user.freezed.dart';
part 'current_user.g.dart';

@immutable
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required Uuid userId,
    String? name,
    required DateTime createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(JsonObject json) => _$UserProfileFromJson(json);
}

class CurrentUserRepository {
  final CurrentUserService _service;

  CurrentUserRepository(this._service);

  CurrentUserRepository.supabase(SupabaseClient supabase)
      : this(CurrentUserService(supabase));

  Future<void> setName(String name) => _service.setName(name);

  Future<void> refresh() => _service.refresh();

  Future<UserProfile?> getProfile() => _service.getProfile();

  // User? get user => _service.user;
  Uuid? get id => _service.id;
  String? get name => _service.name;
  int? get teamNum => _service.teamNum;
  Set<PermissionType>? get permissions => _service.permissions;
  String? get teamName => _service.teamName;
  DateTime? get createdAt => _service.createdAt;

  bool get isOnTeam => teamNum != null;

  bool hasPermission(PermissionType type) =>
      permissions?.contains(type) ?? false;
}

class CurrentUserService {
  final SupabaseClient _supabase;

  CurrentUserService(this._supabase);

  Uuid? get id => _supabase.auth.currentUser?.id;

  String? get name => _supabase.auth.currentUser?.userMetadata?['full_name'];

  DateTime? get createdAt {
    final createdAt = _supabase.auth.currentUser?.createdAt;
    return createdAt == null ? null : DateTime.parse(createdAt);
  }

  Future<void> setName(String name) => _supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': name},
        ),
      );

  Future<void> refresh() => _supabase.auth.refreshSession();

  Future<UserProfile?> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return data?.parse(UserProfile.fromJson);
  }

  int? get teamNum => _jwtClaims?['team_num'] as int?;
  String? get teamName => _jwtClaims?['team_name'] as String?;

  Set<PermissionType>? get permissions =>
      ((_jwtClaims?['permissions'] ?? []) as List<dynamic>?)
          ?.cast<String>()
          .map(PermissionType.fromJson)
          .toSet();

  Map<String, dynamic>? get _jwtClaims {
    final token = _supabase.auth.currentSession?.accessToken;
    return token == null ? null : JwtDecoder.decode(token);
  }
}
