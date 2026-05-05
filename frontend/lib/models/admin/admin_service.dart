import 'dart:convert';

import 'package:gestor_personajes_dnd/models/admin/user_dto.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

class AdminService {
  final ApiClient _api;
  AdminService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<UserDto>> getAllUsers() async {
    final res = await _api.get('/api/admin/users');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((j) => UserDto.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load users (${res.statusCode})');
  }

  Future<UserDto> createUser({
    required String username,
    required String password,
  }) async {
    final res = await _api.post(
      '/api/admin/users',
      body: {
        'username': username,
        'password': password,
      },
    );
    if (res.statusCode == 201) {
      return UserDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    if (res.statusCode == 409) {
      throw Exception('That username already exists. Please choose a different one.');
    }
    final body = res.body;
    String msg = 'Failed to create user (${res.statusCode})';
    if (body.isNotEmpty) {
      try { final decoded = jsonDecode(body); msg = decoded is String ? decoded : msg; } catch (_) { msg = body; }
    }
    throw Exception(msg);
  }

  Future<UserDto> setActive(int userId, bool active) async {
    final endpoint = '/api/admin/users/$userId/${active ? 'activate' : 'deactivate'}';
    final res = await _api.patch(endpoint);
    if (res.statusCode == 200) {
      return UserDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update user status');
  }

  Future<void> resetPassword(int userId, String newPassword) async {
    final res = await _api.patch(
      '/api/admin/users/$userId/reset-password',
      body: {'newPassword': newPassword},
    );
    if (res.statusCode != 204)
      throw Exception('Failed to reset password (${res.statusCode})');
  }

  Future<void> deleteUser(int userId) async {
    final res = await _api.delete('/api/admin/users/$userId');
    if (res.statusCode != 204)
      throw Exception('Failed to delete user (${res.statusCode})');
  }

  Future<void> changeOwnPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _api.patch(
      '/api/users/me/password',
      body: {
        'currentPassword': currentPassword,
        'newPassword':     newPassword,
      },
    );
    if (res.statusCode != 204) {
      final msg = res.body;
      throw Exception(msg.isNotEmpty ? msg : 'Failed to change password');
    }
  }
}