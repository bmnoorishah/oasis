class TimesheetEntry {
  final String userId;
  final String action; // 'entry' or 'exit'
  final DateTime timestamp;
  final String device;

  TimesheetEntry({
    required this.userId,
    required this.action,
    required this.timestamp,
    required this.device,
  });

  factory TimesheetEntry.fromJson(Map<String, dynamic> json) {
    return TimesheetEntry(
      userId: json['userId'],
      action: json['action'],
      timestamp: DateTime.parse(json['timestamp']),
      device: json['device'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'device': device,
    };
  }
}
