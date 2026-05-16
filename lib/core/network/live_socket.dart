import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

/// Events delivered by the live-broadcast websocket. Mirrors the three
/// `type` payloads the backend sends from `LiveScoreConsumer` (see
/// `livescores/consumers.py`).
sealed class LiveSocketEvent {
  const LiveSocketEvent({required this.livescoreId});
  final int livescoreId;
}

/// First payload after `accept()`. Includes the initial viewer count
/// and the broadcast's current status.
class LiveInitEvent extends LiveSocketEvent {
  const LiveInitEvent({
    required super.livescoreId,
    required this.status,
    required this.viewerCount,
  });
  final String status;
  final int viewerCount;
}

/// Push from the channel layer whenever a viewer joins/leaves OR a
/// heartbeat triggers a refresh.
class LiveViewerCountEvent extends LiveSocketEvent {
  const LiveViewerCountEvent({
    required super.livescoreId,
    required this.viewerCount,
  });
  final int viewerCount;
}

/// Server-side broadcast termination notification (`POST .../end` →
/// channel layer push). The bloc clears local state when it sees this.
class LiveBroadcastEndedEvent extends LiveSocketEvent {
  const LiveBroadcastEndedEvent({required super.livescoreId});
}

/// Connection to a single live broadcast. Each broadcast gets its own
/// channel — when the bloc ends or hot-swaps the broadcast it should
/// call [disconnect] and re-`connect(...)` if needed.
///
/// Patterned after [ChatSocket] but scoped to one broadcast: subscribing
/// to `events` outside of `connect()` is harmless but won't get any data
/// until a connection is opened.
@lazySingleton
class LiveSocket {
  LiveSocket(this._storage);

  final SecureStorageService _storage;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int? _livescoreId;
  int _retry = 0;
  bool _connecting = false;
  bool _disposed = false;

  final StreamController<LiveSocketEvent> _events =
      StreamController<LiveSocketEvent>.broadcast();

  static const List<Duration> _reconnectDelays = [
    Duration(milliseconds: 1000),
    Duration(milliseconds: 2000),
    Duration(milliseconds: 4000),
    Duration(milliseconds: 8000),
    Duration(milliseconds: 15000),
  ];

  /// Subscribe here to receive live-broadcast events.
  Stream<LiveSocketEvent> get events => _events.stream;

  /// Open (or reopen) the socket for [livescoreId]. If a different
  /// broadcast is already connected it's torn down first.
  Future<void> connect(int livescoreId) async {
    if (_disposed) return;
    if (_livescoreId == livescoreId && _channel != null) return;
    // Different broadcast — close the old one cleanly.
    if (_livescoreId != null && _livescoreId != livescoreId) {
      await disconnect();
    }
    _livescoreId = livescoreId;
    await _open();
  }

  Future<void> _open() async {
    if (_connecting || _channel != null) return;
    final id = _livescoreId;
    if (id == null) return;
    _connecting = true;
    try {
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) return;
      final uri = Uri.parse(
        '${ApiConstants.wsBaseUrl}${Endpoints.wsLive(id)}?token=$token',
      );
      final ch = WebSocketChannel.connect(uri);
      _channel = ch;
      _sub = ch.stream.listen(
        _onData,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
      _retry = 0;
      _startHeartbeat();
    } finally {
      _connecting = false;
    }
  }

  /// Tear down the current connection. Safe to call multiple times.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close();
    _channel = null;
    _livescoreId = null;
    _retry = 0;
  }

  @disposeMethod
  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _events.close();
  }

  // ── internals ──────────────────────────────────────────────────────────────

  void _onData(dynamic raw) {
    if (raw is! String) return;
    late final Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final id = _livescoreId;
    if (id == null) return;
    final type = data['type'];
    if (type is! String) return;

    switch (type) {
      case 'init':
        final status = data['status'] as String? ?? 'live';
        final count = data['viewer_count'];
        if (count is int) {
          _events.add(LiveInitEvent(
            livescoreId: id,
            status: status,
            viewerCount: count,
          ));
        }
      case 'viewer_count':
        final count = data['viewer_count'];
        if (count is int) {
          _events.add(LiveViewerCountEvent(
            livescoreId: id,
            viewerCount: count,
          ));
        }
      case 'broadcast_ended':
        _events.add(LiveBroadcastEndedEvent(livescoreId: id));
    }
  }

  /// Periodic ping so the backend's TTL-based viewer presence doesn't
  /// expire while the user is on the play screen. Mirrors the web's
  /// 25-second heartbeat cadence.
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      final ch = _channel;
      if (ch == null) return;
      try {
        ch.sink.add(jsonEncode({'action': 'heartbeat'}));
      } catch (_) {/* sink closed — reconnect handles it */}
    });
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    if (_livescoreId == null) return;
    _channel = null;
    _sub = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    final delay = _reconnectDelays[
        _retry.clamp(0, _reconnectDelays.length - 1)];
    _retry++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _open);
  }
}
