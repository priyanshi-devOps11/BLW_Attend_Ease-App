import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/db_helper.dart';
import '../services/export_service.dart';
import '../widgets/export_buttons.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _dbHelper.getAllUsers(); // ✅ implement in DBHelper
    if (!mounted) return;
    setState(() => _users = users);
  }

  void _openUserAttendance(int userId, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserAttendanceScreen(userId: userId, name: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: _users.isEmpty
          ? const Center(child: Text("No users found"))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user['name']),
                    subtitle: Text("User ID: ${user['id']}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _openUserAttendance(user['id'], user['name']),
                  ),
                );
              },
            ),
    );
  }
}

/// ✅ Single User Attendance
class UserAttendanceScreen extends StatefulWidget {
  final int userId;
  final String name;

  const UserAttendanceScreen({
    super.key,
    required this.userId,
    required this.name,
  });

  @override
  State<UserAttendanceScreen> createState() => _UserAttendanceScreenState();
}

class _UserAttendanceScreenState extends State<UserAttendanceScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final records = await _dbHelper.getAttendance(widget.userId);
    if (!mounted) return;
    setState(() => _records = records);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.name}'s Attendance")),
      body: Column(
        children: [
          // ✅ Export buttons for admin
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ExportButtons(
              onExportCSV: () async {
                final file = await ExportService().exportToCSV(widget.userId);
                if (!mounted) return;
                _showSnack("CSV saved: ${file.path} ✅");
              },
              onExportExcel: () async {
                final file = await ExportService().exportToExcel(widget.userId);
                if (!mounted) return;
                _showSnack("Excel saved: ${file.path} ✅");
              },
              onExportPDF: () async {
                final file = await ExportService().exportToPDF(widget.userId);
                if (!mounted) return;
                _showSnack("PDF saved: ${file.path} ✅");
              },
            ),
          ),

          const Divider(),

          // ✅ Attendance records
          Expanded(
            child: _records.isEmpty
                ? const Center(child: Text("No attendance records"))
                : ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      final checkIn = DateTime.parse(record['timestamp']);
                      final checkOut = record['checkout_time'] != null
                          ? DateTime.tryParse(record['checkout_time'])
                          : null;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Icon(
                            record['status'] == "Present"
                                ? Icons.check_circle
                                : record['status'] == "Absent"
                                ? Icons.cancel
                                : Icons.access_time,
                            color: record['status'] == "Present"
                                ? Colors.green
                                : record['status'] == "Absent"
                                ? Colors.red
                                : Colors.orange,
                          ),
                          title: Text("Status: ${record['status']}"),
                          subtitle: Text(
                            "Check-In: ${DateFormat('yyyy-MM-dd – kk:mm').format(checkIn)}\n"
                            "Check-Out: ${checkOut != null ? DateFormat('yyyy-MM-dd – kk:mm').format(checkOut) : "Not yet"}",
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
