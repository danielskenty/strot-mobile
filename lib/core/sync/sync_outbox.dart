import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

enum SyncItemStatus { queued, retrying, needsAttention }

class SyncItem {
  const SyncItem({
    required this.id,
    required this.method,
    required this.path,
    required this.body,
    required this.createdAt,
    this.attempts = 0,
    this.status = SyncItemStatus.queued,
    this.lastError,
  });
  final String id;
  final String method;
  final String path;
  final Map<String, dynamic> body;
  final DateTime createdAt;
  final int attempts;
  final SyncItemStatus status;
  final String? lastError;
  SyncItem copyWith({
    int? attempts,
    SyncItemStatus? status,
    String? lastError,
  }) => SyncItem(
    id: id,
    method: method,
    path: path,
    body: body,
    createdAt: createdAt,
    attempts: attempts ?? this.attempts,
    status: status ?? this.status,
    lastError: lastError,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'method': method,
    'path': path,
    'body': body,
    'created_at': createdAt.toIso8601String(),
    'attempts': attempts,
    'status': status.name,
    'last_error': lastError,
  };
  factory SyncItem.fromJson(Map<String, dynamic> json) => SyncItem(
    id: json['id'] as String,
    method: json['method'] as String,
    path: json['path'] as String,
    body: Map<String, dynamic>.from(json['body'] as Map),
    createdAt: DateTime.parse(json['created_at'] as String),
    attempts: json['attempts'] as int? ?? 0,
    status: SyncItemStatus.values.byName(json['status'] as String? ?? 'queued'),
    lastError: json['last_error'] as String?,
  );
}

abstract interface class SyncStore {
  Future<List<SyncItem>> read();
  Future<void> write(List<SyncItem> items);
}

class PreferenceSyncStore implements SyncStore {
  static const key = 'strot_sync_outbox_v1';
  @override
  Future<List<SyncItem>> read() async {
    final raw = (await SharedPreferences.getInstance()).getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((item) => SyncItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> write(List<SyncItem> items) async =>
      (await SharedPreferences.getInstance()).setString(
        key,
        jsonEncode(items.map((item) => item.toJson()).toList()),
      );
}

class SyncOutbox extends ChangeNotifier {
  SyncOutbox(this.client, this.store);
  final ApiClient client;
  final SyncStore store;
  List<SyncItem> items = [];
  bool syncing = false;
  bool online = true;
  Future<void> load() async {
    items = await store.read();
    notifyListeners();
  }

  Future<void> enqueue(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final id = '${DateTime.now().microsecondsSinceEpoch}-$path';
    items = [
      ...items,
      SyncItem(
        id: id,
        method: method,
        path: path,
        body: body,
        createdAt: DateTime.now(),
      ),
    ];
    online = false;
    await store.write(items);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> sendOrQueue(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await client.mutate(method, path, body);
      online = true;
      notifyListeners();
      return response;
    } on NetworkUnavailableException {
      await enqueue(method, path, body);
      return null;
    }
  }

  Future<void> retryAll() async {
    if (syncing) return;
    syncing = true;
    notifyListeners();
    final remaining = <SyncItem>[];
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      try {
        await client.mutate(item.method, item.path, item.body);
        online = true;
      } on NetworkUnavailableException {
        online = false;
        remaining.add(
          item.copyWith(
            attempts: item.attempts + 1,
            status: SyncItemStatus.queued,
            lastError: 'Waiting for a connection',
          ),
        );
        remaining.addAll(items.skip(index + 1));
        break;
      } on ApiException catch (error) {
        final conflict = error.statusCode == 409 || error.statusCode == 422;
        remaining.add(
          item.copyWith(
            attempts: item.attempts + 1,
            status: conflict
                ? SyncItemStatus.needsAttention
                : SyncItemStatus.retrying,
            lastError: error.message,
          ),
        );
      }
    }
    items = remaining;
    syncing = false;
    await store.write(items);
    notifyListeners();
  }

  Future<void> discard(String id) async {
    items = items.where((item) => item.id != id).toList();
    await store.write(items);
    notifyListeners();
  }
}

class MemorySyncStore implements SyncStore {
  List<SyncItem> items = [];
  @override
  Future<List<SyncItem>> read() async => List.of(items);
  @override
  Future<void> write(List<SyncItem> value) async {
    items = List.of(value);
  }
}
