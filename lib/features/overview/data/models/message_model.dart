class MessageModel {
  final String id;
  final String from;
  final String content;
  final String timestamp;
  final bool read;

  MessageModel({
    required this.id,
    required this.from,
    required this.content,
    required this.timestamp,
    required this.read,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      from: json['from'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '',
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'content': content,
      'timestamp': timestamp,
      'read': read,
    };
  }
}
