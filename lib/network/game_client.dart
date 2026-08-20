import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'network_message.dart';

/// Game Client on Challenger device connecting to Host IP via LAN/Hotspot.
class GameClient {
  Socket? _socket;
  bool isConnected = false;

  final StreamController<NetworkMessage> _messageController = StreamController<NetworkMessage>.broadcast();
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();

  Stream<NetworkMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  /// Connect to Host IP (Port 7777).
  Future<bool> connect(String hostIp, {int port = 7777, Duration timeout = const Duration(seconds: 8)}) async {
    try {
      disconnect(); // Clean up previous connection if any
      _socket = await Socket.connect(hostIp.trim(), port, timeout: timeout);
      try {
        _socket!.setOption(SocketOption.tcpNoDelay, true);
      } catch (_) {}

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
        cancelOnError: false,
      );

      return true;
    } catch (_) {
      _handleDisconnected();
      return false;
    }
  }

  void send(NetworkMessage message) {
    if (_socket != null && isConnected) {
      try {
        _socket!.writeln(message.encode());
      } catch (_) {
        _handleDisconnected();
      }
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
