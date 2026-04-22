import 'dart:convert';

import 'package:gestor_personajes_dnd/models/character/pending_task.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

class PendingTaskService {
  final ApiClient _api;
  PendingTaskService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<PendingTask>> getPendingTasks(int characterId) async {
    final res = await _api.get('/api/characters/$characterId/pending-tasks');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list
          .map((j) => PendingTask.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load pending tasks (${res.statusCode})');
  }

  Future<PendingTask> resolveTask({
    required int characterId,
    required int taskId,
    required String choice,
    String? extraData,
  }) async {
    final body = jsonEncode({
      'choice': choice,
      if (extraData != null) 'extraData': extraData,
    });
    final res = await _api.post(
      '/api/characters/$characterId/pending-tasks/$taskId/resolve',
      body: body,
    );
    if (res.statusCode == 200) {
      return PendingTask.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);      
    }
    throw Exception('Failed to resolve task (${res.statusCode})');
  }

}