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
    required String name,
    required DateTime createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(JsonObject json) => _$UserProfileFromJson(json);
}

class CurrentUserRepository {
  final CurrentUserService _service;

  CurrentUserRepository(this._service);

  CurrentUserRepository.supabase(SupabaseClient supabase)
      : this(CurrentUserService(supabase));

  Future<void> refresh() => _service.refresh();

  Uuid get id => _service.id;
  String get name => _service.name;
  String get email => _service.email;
  DateTime get createdAt => _service.createdAt;
  Set<PermissionType> get permissions => _service.permissions;

  bool get isOnTeam => teamNum != null;
  int? get teamNum => _service.teamNum;
  String? get teamName => _service.teamName;

  bool get hasTeamRequest => requestedTeamNum != null;
  int? get requestedTeamNum => _service.requestedTeamNum;
  String? get requestedTeamName => _service.requestedTeamName;

  bool hasPermission(PermissionType type) => permissions.contains(type);

  Future<void> updateUserDetails({
    String? name,
    String? email,
    String? password,
  }) =>
      _service.updateUserDetails(
        name: name,
        email: email,
        password: password,
      );
}

class CurrentUserService {
  final SupabaseClient _supabase;

  CurrentUserService(this._supabase);

  Uuid get id => _supabase.auth.currentUser!.id;
  String get name =>
      _supabase.auth.currentUser!.userMetadata!['full_name'] as String;
  String get email => _supabase.auth.currentUser!.email!;
  DateTime get createdAt =>
      DateTime.parse(_supabase.auth.currentUser!.createdAt);

  Future<void> updateUserDetails({
    required String? name,
    required String? email,
    required String? password,
  }) async {
    final userData = UserAttributes(email: email, password: password);
    if (name != null) {
      userData.data = {'full_name': name};
    }

    await _supabase.auth.updateUser(userData);
  }

  Future<void> refresh() => _supabase.auth.refreshSession();

  int? get teamNum => _jwtClaims['team_num'] as int?;
  String? get teamName => _jwtClaims['team_name'] as String?;
  int? get requestedTeamNum => _jwtClaims['requested_team_num'] as int?;
  String? get requestedTeamName => _jwtClaims['requested_team_name'] as String?;

  Set<PermissionType> get permissions =>
      ((_jwtClaims['permissions'] ?? []) as List<dynamic>)
          .cast<String>()
          .map(PermissionType.fromJson)
          .toSet();

  Map<String, dynamic> get _jwtClaims =>
      JwtDecoder.decode(_supabase.auth.currentSession!.accessToken);
}
