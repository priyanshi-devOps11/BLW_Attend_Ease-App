import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/db_helper.dart';

class ExportService {
  final DBHelper _dbHelper = DBHelper();

  /// Export attendance to CSV file
  Future<File> exportToCSV(int userId) async {
    final records = await _dbHelper.getAttendance(userId);
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/attendance.csv";

    final csvBuffer = StringBuffer();
    csvBuffer.writeln("Status,Check-In,Check-Out");

    for (var r in records) {
      csvBuffer.writeln(
        "${r['status']},${r['timestamp']},${r['checkout_time'] ?? ''}",
      );
    }

    final file = File(path);
    return await file.writeAsString(csvBuffer.toString());
  }

  /// Export attendance to Excel file
  Future<File> exportToExcel(int userId) async {
    final records = await _dbHelper.getAttendance(userId);
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/attendance.xlsx";

    var excel = Excel.createExcel();
    Sheet sheet = excel['Attendance'];
    sheet.appendRow(["Status", "Check-In", "Check-Out"]);

    for (var r in records) {
      sheet.appendRow([
        r['status'],
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(r['timestamp'])),
        r['checkout_time'] != null
            ? DateFormat('yyyy-MM-dd HH:mm')
            .format(DateTime.parse(r['checkout_time']))
            : '',
      ]);
    }

    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  /// Export attendance to PDF file
  Future<File> exportToPDF(int userId) async {
    final records = await _dbHelper.getAttendance(userId);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: ["Status", "Check-In", "Check-Out"],
            data: records.map((r) {
              return [
                r['status'],
                DateFormat('yyyy-MM-dd HH:mm')
                    .format(DateTime.parse(r['timestamp'])),
                r['checkout_time'] != null
                    ? DateFormat('yyyy-MM-dd HH:mm')
                    .format(DateTime.parse(r['checkout_time']))
                    : 'Not yet',
              ];
            }).toList(),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/attendance.pdf";
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Share/print PDF directly
  Future<void> printPDF(int userId) async {
    final records = await _dbHelper.getAttendance(userId);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: ["Status", "Check-In", "Check-Out"],
            data: records.map((r) {
              return [
                r['status'],
                DateFormat('yyyy-MM-dd HH:mm')
                    .format(DateTime.parse(r['timestamp'])),
                r['checkout_time'] ?? 'Not yet',
              ];
            }).toList(),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
