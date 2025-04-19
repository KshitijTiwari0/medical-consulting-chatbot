import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_proj/models/report_model.dart';

class ReportScreen extends StatelessWidget {
  final Report report;
  const ReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(report.content);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(report.content),
        ),
      ),
    );
  }
}