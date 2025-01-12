import 'dart:async';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/core.dart';

class CurrentUserRepository {
  final CurrentUserService _service;

  CurrentUserRepository(this._service);

  CurrentUserRepository.supabase(SupabaseClient supabase)
      : this(CurrentUserService(supabase));

  Future<void> setName(String name) => _service.setName(name);

  User? get user => _service.user;
  String? get name => _service.name;
  int? get teamNum => _service.teamNum;
  Set<PermissionType>? get permissions => _service.permissions;
}

class CurrentUserService {
  final SupabaseClient _supabase;

  CurrentUserService(this._supabase);

  User? get user => _supabase.auth.currentUser;

  String? get name => user?.userMetadata?['full_name'];

  Future<void> setName(String name) => _supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': name},
        ),
      );

  int? get teamNum => _jwtClaims?['team_num'] as int?;

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
