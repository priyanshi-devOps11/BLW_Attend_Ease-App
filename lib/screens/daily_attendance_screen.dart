import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'dart:io';

import '../services/db_helper.dart';

class DailyAttendanceScreen extends StatefulWidget {
  @override
  _DailyAttendanceScreenState createState() => _DailyAttendanceScreenState();
}

class _DailyAttendanceScreenState extends State<DailyAttendanceScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> attendanceData = [];
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    final data = await _dbHelper.getDailyAttendance(selectedDate);
    setState(() {
      attendanceData = data;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchAttendance();
    }
  }

  // ======================
  // EXPORT FUNCTIONS
  // ======================

  Future<void> _exportToCSV() async {
    final headers = ['Name', 'Status', 'Check-In', 'Check-Out'];
    final rows = attendanceData.map((record) {
      return [
        record['name'],
        record['status'],
        DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(DateTime.parse(record['timestamp'])),
        record['checkout_time'] != null
            ? DateFormat(
                'yyyy-MM-dd HH:mm',
              ).format(DateTime.parse(record['checkout_time']))
            : "Not Checked Out",
      ];
    }).toList();

    final csvData = [
      headers.join(','),
      ...rows.map((row) => row.join(',')),
    ].join('\n');

    final directory = Directory('/storage/emulated/0/Download');
    final path =
        '${directory.path}/Daily_Attendance_${DateFormat('yyyyMMdd').format(selectedDate)}.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('✅ CSV saved: $path')));

    OpenFilex.open(path);
  }

  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Daily Attendance'];

    sheetObject.appendRow(['Name', 'Status', 'Check-In', 'Check-Out']);

    for (var record in attendanceData) {
      sheetObject.appendRow([
        record['name'],
        record['status'],
        DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(DateTime.parse(record['timestamp'])),
        record['checkout_time'] != null
            ? DateFormat(
                'yyyy-MM-dd HH:mm',
              ).format(DateTime.parse(record['checkout_time']))
            : "Not Checked Out",
      ]);
    }

    final directory = Directory('/storage/emulated/0/Download');
    final path =
        '${directory.path}/Daily_Attendance_${DateFormat('yyyyMMdd').format(selectedDate)}.xlsx';
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('✅ Excel saved: $path')));

    OpenFilex.open(path);
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            children: [
              pw.Text(
                'Daily Attendance Report - ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Name', 'Status', 'Check-In', 'Check-Out'],
                data: attendanceData.map((record) {
                  return [
                    record['name'],
                    record['status'],
                    DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(DateTime.parse(record['timestamp'])),
                    record['checkout_time'] != null
                        ? DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(DateTime.parse(record['checkout_time']))
                        : "Not Checked Out",
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final directory = Directory('/storage/emulated/0/Download');
    final path =
        '${directory.path}/Daily_Attendance_${DateFormat('yyyyMMdd').format(selectedDate)}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('✅ PDF saved: $path')));

    OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Attendance"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              await _exportToCSV();
            },
            tooltip: "Export CSV",
          ),
          IconButton(
            icon: Icon(Icons.table_chart),
            onPressed: () async {
              await _exportToExcel();
            },
            tooltip: "Export Excel",
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await _exportToPDF();
            },
            tooltip: "Export PDF",
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
            ),
            trailing: ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text("Pick Date"),
            ),
          ),
          Expanded(
            child: attendanceData.isEmpty
                ? Center(child: Text("No attendance records for this day."))
                : ListView.builder(
                    itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final record = attendanceData[index];
                      return ListTile(
                        title: Text(record['name']),
                        subtitle: Text(
                          "Check-In: ${DateFormat('HH:mm').format(DateTime.parse(record['timestamp']))}\n"
                          "Check-Out: ${record['checkout_time'] != null ? DateFormat('HH:mm').format(DateTime.parse(record['checkout_time'])) : "Not Checked Out"}",
                        ),
                        trailing: Text(record['status']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
