enum MessageType { text, voice, location, system }

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isOwner;
  final double? latitude;
  final double? longitude;
  final int? voiceDurationSec;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    required this.isOwner,
    this.latitude,
    this.longitude,
    this.voiceDurationSec,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isOwner: json['isOwner'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      voiceDurationSec: json['voiceDurationSec'],
    );
  }
}