class NotificationItem {
  final int id;
  final String titre;
  final String message;
  final bool lu;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.titre,
    required this.message,
    required this.lu,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      titre: json['titre'] as String? ?? '',
      message: json['message'] as String? ?? '',
      lu: json['lu'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
