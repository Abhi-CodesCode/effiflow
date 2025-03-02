class AppClipboardData {
  final int? id;
  final int? userId;
  final String content; // Make content nullable
  final DateTime createdAt;
  final DateTime updatedAt;

  AppClipboardData({
    this.id,
    this.userId,
    this.content="", // content is now optional
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppClipboardData.fromJson(Map<String, dynamic> json) {
    print("OnlineClipboardData.fromJson called with: $json");
    return AppClipboardData(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'], // content can be null
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}