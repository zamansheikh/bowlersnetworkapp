import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

/// Events delivered by the chat websocket. Mirrors the three `type` values
/// the web provider watches for (see `WebSocketProvider.tsx`).
sealed class ChatSocketEvent {
  const ChatSocketEvent();
}

class ChatMessageEvent extends ChatSocketEvent {
  const ChatMessageEvent({
    required this.conversationUid,
    required this.message,
  });
  final String conversationUid;
  final Map<String, dynamic> message;
}

class ChatTypingEvent extends ChatSocketEvent {
  const ChatTypingEvent({
    required this.conversationUid,
    required this.userId,
    required this.username,
  });
  final String conversationUid;
  final int userId;
  final String username;
}

class ChatMessageDeletedEvent extends ChatSocketEvent {
  const ChatMessageDeletedEvent({
    required this.conversationUid,
    required this.messageUid,
  });
  final String conversationUid;
  final String messageUid;
}

/// Long-lived chat websocket connection with automatic reconnect. Exposes a
/// broadcast stream of typed events so any bloc can subscribe/unsubscribe
/// without owning the connection.
///
/// Lifecycle: call [ensureConnected] after login (blocs that need it call
/// it themselves). Call [disconnect] on logout.
@lazySingleton
class ChatSocket {
  ChatSocket(this._storage);

  final SecureStorageService _storage;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  int _retry = 0;
  bool _connecting = false;
  bool _disposed = false;

  final StreamController<ChatSocketEvent> _events =
      StreamController<ChatSocketEvent>.broadcast();

  /// Mirrors the web's exponential-backoff ladder.
  static const List<Duration> _reconnectDelays = [
    Duration(milliseconds: 1000),
    Duration(milliseconds: 2000),
    Duration(milliseconds: 4000),
    Duration(milliseconds: 8000),
    Duration(milliseconds: 15000),
  ];

  /// Subscribe here to receive chat events.
  Stream<ChatSocketEvent> get events => _events.stream;

  /// Idempotent — no-op if already connected or connecting.
  Future<void> ensureConnected() async {
    if (_disposed) return;
    if (_channel != null || _connecting) return;
    _connecting = true;
    try {
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) return;
      final uri = Uri.parse(
        '${ApiConstants.wsBaseUrl}${Endpoints.wsChat}?token=$token',
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
    } finally {
      _connecting = false;
    }
  }

  /// Notify backend the current user is typing in [conversationUid]. Matches
  /// web's `{action: "typing", conversation_uid}` payload.
  void sendTyping(String conversationUid) {
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(
        jsonEncode({
          'action': 'typing',
          'conversation_uid': conversationUid,
        }),
      );
    } catch (_) {
      // Sink closed between check and send — reconnect will run.
    }
  }

  /// Tear down the connection (e.g., on logout). Leaves the stream controller
  /// open so subscribers stay attached across re-login.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close();
    _channel = null;
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
    final type = data['type'];
    final uid = data['conversation_uid'];
    if (type is! String || uid is! String) return;

    switch (type) {
      case 'chat_message':
        final msg = data['message'];
        if (msg is Map<String, dynamic>) {
          _events.add(
            ChatMessageEvent(conversationUid: uid, message: msg),
          );
        }
      case 'chat_typing':
        final user = data['user'];
        if (user is Map<String, dynamic>) {
          final id = user['id'];
          final username = user['username'];
          if (id is int && username is String) {
            _events.add(
              ChatTypingEvent(
                conversationUid: uid,
                userId: id,
                username: username,
              ),
            );
          }
        }
      case 'chat_message_deleted':
        final messageUid = data['message_uid'];
        if (messageUid is String) {
          _events.add(
            ChatMessageDeletedEvent(
              conversationUid: uid,
              messageUid: messageUid,
            ),
          );
        }
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _channel = null;
    _sub = null;
    final delay = _reconnectDelays[
        _retry.clamp(0, _reconnectDelays.length - 1)];
    _retry++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, ensureConnected);
  }
}
