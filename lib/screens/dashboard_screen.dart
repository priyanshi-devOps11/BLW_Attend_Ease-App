import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final db = await _dbHelper.database;

    // Join users + attendance
    final res = await db.rawQuery('''
      SELECT attendance.id, attendance.status, attendance.timestamp,
             users.name, users.role
      FROM attendance
      INNER JOIN users ON attendance.userId = users.id
      ORDER BY attendance.timestamp DESC
    ''');

    setState(() {
      _attendanceRecords = res;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.deepPurple,
      useMaterial3: true,
    );

    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manager Dashboard"),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: _toggleTheme,
            ),
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: _attendanceRecords.isEmpty
            ? const Center(child: Text("No attendance records yet"))
            : ListView.builder(
                itemCount: _attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = _attendanceRecords[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        "${record['name']} (${record['role']})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Status: ${record['status']}\nTime: ${record['timestamp']}",
                      ),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}
