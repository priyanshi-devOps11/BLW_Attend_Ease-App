import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final String studentName;
  final String status; // e.g., "Present", "Absent", "Late"
  final VoidCallback onTap;

  const AttendanceCard({
    super.key,
    required this.studentName,
    required this.status,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case "present":
        return Colors.green;
      case "absent":
        return Colors.red;
      case "late":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          studentName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: Chip(
          label: Text(status, style: const TextStyle(color: Colors.white)),
          backgroundColor: _getStatusColor(),
        ),
        onTap: onTap,
      ),
    );
  }
}
