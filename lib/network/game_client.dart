import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'network_message.dart';

/// Game Client di HP Player 2 yang terhubung ke IP Host via Hotspot.
class GameClient {
  Socket? _socket;
  bool isConnected = false;

  final StreamController<NetworkMessage> _messageController = StreamController<NetworkMessage>.broadcast();
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();

  Stream<NetworkMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  /// Hubungkan ke IP Host (Port 7777).
  Future<bool> connect(String hostIp, {int port = 7777, Duration timeout = const Duration(seconds: 8)}) async {
    try {
      _socket = await Socket.connect(hostIp, port, timeout: timeout);
      isConnected = true;
      _connectionStateController.add(true);

      _socket!
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          final msg = NetworkMessage.decode(line);
          if (msg != null) _messageController.add(msg);
        },
        onDone: () => _handleDisconnected(),
        onError: (_) => _handleDisconnected(),
      );

      return true;
    } catch (_) {
      _handleDisconnected();
      return false;
    }
  }

  void send(NetworkMessage message) {
    if (_socket != null && isConnected) {
      _socket!.writeln(message.encode());
    }
  }

  void _handleDisconnected() {
    _socket?.destroy();
    _socket = null;
    isConnected = false;
    _connectionStateController.add(false);
  }

  void disconnect() {
    _handleDisconnected();
  }
}
