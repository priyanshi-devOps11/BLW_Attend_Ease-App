import 'package:flutter/material.dart';

class UserAttendanceButtons extends StatelessWidget {
  final VoidCallback onCheckIn;
  final VoidCallback onAbsent;
  final VoidCallback onLate;
  final VoidCallback onCheckOut;

  const UserAttendanceButtons({
    super.key,
    required this.onCheckIn,
    required this.onAbsent,
    required this.onLate,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildActionButton("Check-In", Icons.login, Colors.green, onCheckIn),
        _buildActionButton("Absent", Icons.cancel, Colors.red, onAbsent),
        _buildActionButton("Late", Icons.access_time, Colors.orange, onLate),
        _buildActionButton("Check-Out", Icons.logout, Colors.blue, onCheckOut),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
