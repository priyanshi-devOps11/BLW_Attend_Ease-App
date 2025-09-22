import 'package:flutter/material.dart';

class ExportButtons extends StatelessWidget {
  final VoidCallback onExportCSV;
  final VoidCallback onExportExcel;
  final VoidCallback onExportPDF;

  const ExportButtons({
    super.key,
    required this.onExportCSV,
    required this.onExportExcel,
    required this.onExportPDF,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildActionButton(
          "Export CSV",
          Icons.file_present,
          Colors.teal,
          onExportCSV,
        ),
        _buildActionButton(
          "Export Excel",
          Icons.table_chart,
          Colors.indigo,
          onExportExcel,
        ),
        _buildActionButton(
          "Export PDF",
          Icons.picture_as_pdf,
          Colors.brown,
          onExportPDF,
        ),
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
