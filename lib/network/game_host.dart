import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'network_message.dart';

/// Local Socket Game Server on Host device (Port 7777).
class GameHost {
  static const int defaultPort = 7777;
  ServerSocket? _serverSocket;
  Socket? _clientSocket;

  bool isListening = false;
  bool isConnected = false;

  final StreamController<NetworkMessage> _messageController = StreamController<NetworkMessage>.broadcast();
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();

  Stream<NetworkMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  /// Get local IP address (Wi-Fi router LAN or Hotspot).
  Future<String> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback &&
              (addr.address.startsWith("192.168.") ||
                  addr.address.startsWith("10.") ||
                  addr.address.startsWith("172."))) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return "192.168.43.1"; // Default Android Hotspot tethering IP
  }

  /// Start listening for incoming client connections on port 7777.
  Future<String> startHost({int port = defaultPort}) async {
    await stop(); // Ensure any existing socket is cleaned up

    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port, shared: true);
    isListening = true;

    _serverSocket!.listen((socket) {
      if (_clientSocket != null) {
        socket.destroy(); // Accept 1 client for 1v1 PvP
        return;
      }

      _clientSocket = socket;
      try {
        _clientSocket!.setOption(SocketOption.tcpNoDelay, true);
      } catch (_) {}

      isConnected = true;
      _connectionStateController.add(true);

      _clientSocket!
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          final msg = NetworkMessage.decode(line);
          if (msg != null) _messageController.add(msg);
        },
        onDone: () => _handleClientDisconnected(),
        onError: (_) => _handleClientDisconnected(),
        cancelOnError: false,
      );
    });

    return await getLocalIp();
  }

  void send(NetworkMessage message) {
    if (_clientSocket != null && isConnected) {
      try {
        _clientSocket!.writeln(message.encode());
      } catch (_) {
        _handleClientDisconnected();
      }
    }
  }

  void _handleClientDisconnected() {
    _clientSocket?.destroy();
    _clientSocket = null;
    isConnected = false;
    _connectionStateController.add(false);
  }

  Future<void> stop() async {
    _handleClientDisconnected();
    await _serverSocket?.close();
    _serverSocket = null;
    isListening = false;
  }
}
