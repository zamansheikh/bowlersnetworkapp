class Report {
  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String? reportedPostId;
  final String? reportedMessageId;
  final String reason;
  final String? description;
  final DateTime createdAt;
  final String status;

  Report({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    this.reportedPostId,
    this.reportedMessageId,
    required this.reason,
    this.description,
    required this.createdAt,
    this.status = 'pending',
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String? ?? '',
      reporterId: json['reporter_id'] as String? ?? '',
      reportedUserId: json['reported_user_id'] as String?,
      reportedPostId: json['reported_post_id'] as String?,
      reportedMessageId: json['reported_message_id'] as String?,
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'reported_post_id': reportedPostId,
      'reported_message_id': reportedMessageId,
      'reason': reason,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}

class ReportReason {
  final String key;
  final String label;
  final String icon;
  final String description;

  ReportReason({
    required this.key,
    required this.label,
    required this.icon,
    required this.description,
  });
}

final List<ReportReason> reportReasons = [
  ReportReason(
    key: 'inappropriate_content',
    label: 'Inappropriate Content',
    icon: '⚠️',
    description: 'Sexual, violent, or offensive content',
  ),
  ReportReason(
    key: 'harassment',
    label: 'Harassment or Bullying',
    icon: '😠',
    description: 'Threatening, bullying, or hurtful messages',
  ),
  ReportReason(
    key: 'child_safety',
    label: 'Child Safety Concern',
    icon: '🛡️',
    description: 'Predatory behavior or child exploitation',
  ),
  ReportReason(
    key: 'spam',
    label: 'Spam or Scam',
    icon: '🚫',
    description: 'Unwanted commercial messages or fraud',
  ),
  ReportReason(
    key: 'other',
    label: 'Other',
    icon: '❓',
    description: 'Something else',
  ),
];
