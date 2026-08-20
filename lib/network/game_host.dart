import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'network_message.dart';

/// Game Server Lokal di HP Host (Port 7777).
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

  /// Dapatkan IP lokal Hotspot / Wi-Fi perangkat.
  Future<String> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && (addr.address.startsWith("192.168.") || addr.address.startsWith("10.") || addr.address.startsWith("172."))) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return "192.168.43.1"; // Default IP Hotspot Android tethering
  }

  /// Mulai mendengarkan koneksi di port 7777.
  Future<String> startHost({int port = defaultPort}) async {
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    isListening = true;

    _serverSocket!.listen((socket) {
      if (_clientSocket != null) {
        socket.destroy(); // Hanya terima 1 klien untuk 1v1
        return;
      }

      _clientSocket = socket;
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
      );
    });

    return await getLocalIp();
  }

  void send(NetworkMessage message) {
    if (_clientSocket != null && isConnected) {
      _clientSocket!.writeln(message.encode());
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
