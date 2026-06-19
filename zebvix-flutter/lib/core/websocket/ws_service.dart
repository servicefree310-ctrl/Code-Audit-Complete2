import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

final wsServiceProvider = Provider<WsService>((ref) {
  final storage = ref.read(secureStorageProvider);
  return WsService(storage);
});

class WsService {
  final SecureStorage _storage;
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _intentionalClose = false;

  final _controllers = <String, StreamController<dynamic>>{};
  final _subscriptions = <String>{};

  WsService(this._storage);

  Future<void> connect() async {
    _intentionalClose = false;
    final token = await _storage.getAccessToken();

    // FIX: Token sent as first message instead of URL query param.
    // URL query params appear in server access logs and proxy logs — security risk.
    final uri = Uri.parse(AppConstants.wsUrl);
    try {
      _channel = WebSocketChannel.connect(uri);
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      // Authenticate immediately after connection via first message
      if (token != null && token.isNotEmpty) {
        send({'type': 'auth', 'token': token});
      }
      _startPing();
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type != null && _controllers.containsKey(type)) {
        _controllers[type]!.add(data['data']);
      }
    } catch (_) {}
  }

  void _onError(Object error) {
    if (!_intentionalClose) _scheduleReconnect();
  }

  void _onDone() {
    if (!_intentionalClose) _scheduleReconnect();
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      send({'type': 'ping'});
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), connect);
  }

  void subscribe(String channel, {Map<String, dynamic>? params}) {
    if (!_subscriptions.contains(channel)) {
      _subscriptions.add(channel);
      send({'type': 'subscribe', 'channel': channel, ...?params});
    }
  }

  void unsubscribe(String channel) {
    _subscriptions.remove(channel);
    send({'type': 'unsubscribe', 'channel': channel});
  }

  Stream<dynamic> stream(String type) {
    _controllers.putIfAbsent(type, () => StreamController.broadcast());
    return _controllers[type]!.stream;
  }

  void send(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  void disconnect() {
    _intentionalClose = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    for (final ctrl in _controllers.values) {
      ctrl.close();
    }
    _controllers.clear();
    _subscriptions.clear();
  }
}

// Providers for specific streams
final tickerStreamProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, symbol) {
  final ws = ref.read(wsServiceProvider);
  ws.subscribe('ticker:$symbol');
  return ws.stream(AppConstants.wsTicker)
      .where((d) => (d as Map<String, dynamic>)['symbol'] == symbol)
      .cast<Map<String, dynamic>>();
});

final orderBookStreamProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, symbol) {
  final ws = ref.read(wsServiceProvider);
  ws.subscribe('orderbook:$symbol');
  return ws.stream(AppConstants.wsOrderBook).cast<Map<String, dynamic>>();
});

final balanceStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final ws = ref.read(wsServiceProvider);
  ws.subscribe(AppConstants.wsBalance);
  return ws.stream(AppConstants.wsBalance).cast<Map<String, dynamic>>();
});
