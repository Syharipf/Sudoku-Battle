import 'dart:convert';

/// Tipe pesan network PvP.
class NetworkMessage {
  final String type;
  final Map<String, dynamic> payload;

  NetworkMessage({required this.type, required this.payload});

  Map<String, dynamic> toJson() => {'type': type, 'payload': payload};

  factory NetworkMessage.fromJson(Map<String, dynamic> json) {
    return NetworkMessage(
      type: json['type'] as String,
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
    );
  }

  String encode() => jsonEncode(toJson());

  static NetworkMessage? decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return NetworkMessage.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
