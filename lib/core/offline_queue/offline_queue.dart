import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _queueKey = 'offline_queue';
const _uuid = Uuid();

class OfflineQueueTask {
  OfflineQueueTask({
    String? id,
    required this.type,
    required this.payload,
    DateTime? createdAt,
    this.attempt = 0,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempt;

  OfflineQueueTask copyWith({int? attempt}) {
    return OfflineQueueTask(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      attempt: attempt ?? this.attempt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'attempt': attempt,
    };
  }

  factory OfflineQueueTask.fromJson(Map<String, dynamic> json) {
    return OfflineQueueTask(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      attempt: json['attempt'] as int? ?? 0,
    );
  }
}

class OfflineQueueState {
  const OfflineQueueState({this.tasks = const []});

  final List<OfflineQueueTask> tasks;
}

final offlineQueueControllerProvider =
    StateNotifierProvider<OfflineQueueController, OfflineQueueState>((ref) {
  final controller = OfflineQueueController();
  ref.onDispose(controller.dispose);
  return controller;
});

class OfflineQueueController extends StateNotifier<OfflineQueueState> {
  OfflineQueueController() : super(const OfflineQueueState()) {
    _restore();
  }

  SharedPreferences? _prefs;

  Future<void> _restore() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getStringList(_queueKey) ?? [];
    final tasks = raw
        .map((encoded) =>
            OfflineQueueTask.fromJson(jsonDecode(encoded) as Map<String, dynamic>))
        .toList();
    state = OfflineQueueState(tasks: tasks);
  }

  Future<void> enqueue(OfflineQueueTask task) async {
    final updated = [...state.tasks, task];
    await _persist(updated);
    state = OfflineQueueState(tasks: updated);
  }

  Future<void> markComplete(String taskId) async {
    final updated = state.tasks.where((task) => task.id != taskId).toList();
    await _persist(updated);
    state = OfflineQueueState(tasks: updated);
  }

  Future<void> bumpAttempt(String taskId) async {
    final updated = state.tasks
        .map((task) =>
            task.id == taskId ? task.copyWith(attempt: task.attempt + 1) : task)
        .toList();
    await _persist(updated);
    state = OfflineQueueState(tasks: updated);
  }

  Future<void> _persist(List<OfflineQueueTask> tasks) async {
    _prefs ??= await SharedPreferences.getInstance();
    final encoded = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await _prefs!.setStringList(_queueKey, encoded);
  }
}
