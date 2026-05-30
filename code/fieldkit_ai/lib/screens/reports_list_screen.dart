import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'report_detail_chat_screen.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(title: const Text('Archivio', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16, vertical: 24),
            itemCount: provider.completedReports.length,
            itemBuilder: (context, index) {
              final report = provider.completedReports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.picture_as_pdf, color: AppTheme.primary, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(report.taskTitle, style: TextStyle(fontWeight: FontWeight.w800, fontSize: isDesktop ? 20 : 16, color: AppTheme.textDark)),
                                const SizedBox(height: 8),
                                // INTERLINEA SIMILE (height: 1.5) AGGIUNTA QUI
                                Text('Generato il: ${report.date}\nStatus: Completato', style: TextStyle(color: AppTheme.textLight, fontSize: isDesktop ? 16 : 14, height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), backgroundColor: AppTheme.primary),
                            icon: const Icon(Icons.visibility, size: 20),
                            label: const Text('Visualizza PDF'),
                            onPressed: () => _showReportDetails(context, report),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Chat con l\'AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            onPressed: () => showDialog(context: context, builder: (_) => ReportDetailChatScreen(report: report)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showReportDetails(BuildContext context, Report report) {
    bool isDesktop = MediaQuery.of(context).size.width >= 800;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isDesktop ? 24 : 16), 
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                decoration: const BoxDecoration(color: AppTheme.sidebarBg, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        report.taskTitle, 
                        style: TextStyle(color: Colors.white, fontSize: isDesktop ? 20 : 16, fontWeight: FontWeight.bold)
                      )
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download avviato'))),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24, vertical: isDesktop ? 40 : 24),
                  child: MarkdownBody(
                    data: report.aiSummary,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.primaryDark),
                      h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textDark, height: 2.5),
                      p: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                      strong: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}