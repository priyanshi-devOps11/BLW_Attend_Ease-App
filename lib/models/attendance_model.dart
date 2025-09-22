class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String status; // Present / Absent / Late
  final DateTime timestamp;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.timestamp,
  });

  /// Convert Map → AttendanceModel
  factory AttendanceModel.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceModel(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      status: data['status'] ?? 'Unknown',
      timestamp: data['timestamp'] is String
          ? DateTime.tryParse(data['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert AttendanceModel → Map (for local storage / JSON)
  Map<String, dynamic> toMap() {
    return {
      "studentId": studentId,
      "studentName": studentName,
      "status": status,
      "timestamp": timestamp.toIso8601String(),
    };
  }
}
