import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import '../services/db_helper.dart';
import 'login_screen.dart';
import '../utils/location_helper.dart';

// ✅ Constants for BLW TTC location
const double blwLatitude = 25.2901446;
const double blwLongitude = 82.9607415;
const double allowedDistanceMeters = 10000;

class AttendanceScreen extends StatefulWidget {
  final int userId;

  const AttendanceScreen({super.key, required this.userId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DBHelper _dbHelper = DBHelper();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _filtered = [];

  DateTime? _startDate;
  DateTime? _endDate;
  String _statusFilter = "All";
  bool _sortAsc = false;
  bool _isDarkMode = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadAttendance();
  }

  Future<void> _initializeNotifications() async {
    tzData.initializeTimeZones();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _notifications.initialize(initSettings);
  }

  Future<void> _loadAttendance() async {
    final records = await _dbHelper.getAttendance(widget.userId);
    if (!mounted) return;
    setState(() {
      _records = records;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = [..._records];
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((rec) {
        final date = DateTime.parse(rec['timestamp']);
        return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    if (_statusFilter != "All") {
      filtered = filtered
          .where((rec) => rec['status'] == _statusFilter)
          .toList();
    }

    filtered.sort((a, b) {
      final d1 = DateTime.parse(a['timestamp']);
      final d2 = DateTime.parse(b['timestamp']);
      return _sortAsc ? d1.compareTo(d2) : d2.compareTo(d1);
    });

    setState(() => _filtered = filtered);
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: _statusFilter,
                  items: ["All", "Present", "Absent", "Late"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setModal(() => _statusFilter = val!),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setModal(() => _startDate = date);
                        },
                        child: Text(
                          _startDate == null
                              ? "Start Date"
                              : DateFormat('yyyy-MM-dd').format(_startDate!),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setModal(() => _endDate = date);
                        },
                        child: Text(
                          _endDate == null
                              ? "End Date"
                              : DateFormat('yyyy-MM-dd').format(_endDate!),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Sort Order"),
                    Switch(
                      value: _sortAsc,
                      onChanged: (val) => setModal(() => _sortAsc = val),
                    ),
                    Text(_sortAsc ? "Oldest First" : "Newest First"),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  child: const Text("Apply Filters"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getCurrentLocationData() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        blwLatitude,
        blwLongitude,
      );

      return {
        'insideAllowedArea': distance <= allowedDistanceMeters,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print("Location error: $e");
      return {'insideAllowedArea': false, 'latitude': 0.0, 'longitude': 0.0};
    }
  }

  Future<void> _markCheckout() async {
    final locationData = await getCurrentLocationData();

    if (!locationData['insideAllowedArea']) {
      _showSnack("❌ You must be at BLW TTC Office to check out.");
      return;
    }

    final lat = locationData['latitude'];
    final lon = locationData['longitude'];
    final location = '$lat, $lon';

    try {
      final result = await _dbHelper.markCheckout(widget.userId, location);
      if (!mounted) return;
      if (result) {
        await _loadAttendance();
        _showSnack("✅ Checked out successfully at $location");
        await _notifications.cancel(1);
      } else {
        _showSnack("⚠️ No active check-in found for today");
      }
    } catch (e) {
      _showSnack("❌ Error: $e");
    }
  }

  Future<void> _confirmAndMark(String status) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Action"),
        content: Text("Are you sure you want to mark yourself as $status?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _withLoading(() => _markAttendance(status));
    }
  }

  Future<void> _confirmAndCheckout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Check-Out"),
        content: const Text("Are you sure you want to Check-Out now?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _withLoading(_markCheckout);
    }
  }

  Future<void> _markAttendance(String status) async {
    // 🔒 Step 1: Check if already checked in
    final alreadyCheckedIn = await _dbHelper.hasCheckedInToday(widget.userId);
    if (alreadyCheckedIn) {
      _showSnack("❌ You already checked in today");
      return;
    }

    // 📍 Step 2: Get location with permission check
    final locationData = await getCurrentLocationData();

    // ⚠️ Step 3: Handle location errors or invalid area
    if (locationData['error'] != null) {
      _showSnack("❌ Location Error: ${locationData['error']}");
      return;
    }

    if (!locationData['insideAllowedArea']) {
      _showSnack("❌ You must be at BLW TTC Office to check in.");
      return;
    }

    // ✅ Step 4: Proceed with attendance
    final lat = locationData['latitude'];
    final lon = locationData['longitude'];
    final location = '$lat, $lon';

    await _dbHelper.insertAttendance(widget.userId, status, location);
    await _loadAttendance();
    _showSnack("✅ Checked in as $status at $location");

    await _scheduleCheckoutReminder();
  }

  Future<void> _scheduleCheckoutReminder() async {
    final now = DateTime.now();
    final reminderTime = DateTime(now.year, now.month, now.day, 18, 0); // 6 PM
    if (reminderTime.isAfter(now)) {
      await _notifications.zonedSchedule(
        1,
        'Check-Out Reminder',
        'Don’t forget to check-out today!',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'attendance_channel',
            'Attendance Reminders',
            channelDescription: 'Reminders to check-out on time',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _withLoading(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
          title: const Text("My Attendance"),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilterSheet,
            ),
            IconButton(
              icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: _toggleTheme,
            ),
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildActionButton(
                        "Check-In",
                        Icons.login,
                        Colors.green,
                        () => _withLoading(() => _markAttendance("Present")),
                      ),
                      _buildActionButton(
                        "Absent",
                        Icons.cancel,
                        Colors.red,
                        () {
                          _confirmAndMark("Absent");
                        },
                      ),
                      _buildActionButton(
                        "Late",
                        Icons.access_time,
                        Colors.orange,
                        () {
                          _confirmAndMark("Late");
                        },
                      ),
                      _buildActionButton(
                        "Check-Out",
                        Icons.logout,
                        Colors.blue,
                        _confirmAndCheckout,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(child: Text("No attendance records yet"))
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final record = _filtered[index];
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
                                  "Check-In: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(record['timestamp']))}\n"
                                  "Check-Out: ${record['checkout_time'] != null ? DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(record['checkout_time'])) : "Not yet"}",
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            if (_loading)
              Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
