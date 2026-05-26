import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'report_detail_chat_screen.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivio Report'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout()),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.completedReports.length,
        itemBuilder: (context, index) {
          final report = provider.completedReports[index];
          return Card(
            color: AppTheme.surface,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment, color: AppTheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          report.taskTitle, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Data di caricamento: ${report.date}', style: const TextStyle(color: AppTheme.textLight)),
                  const SizedBox(height: 16),
                  
                  // I tre pulsanti richiesti per ciascun elemento caricato
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // PULSANTE APRI: Carica le informazioni del report
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mediaButtonBg,
                          foregroundColor: AppTheme.textDark,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                        ),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Apri'),
                        onPressed: () {
                          _showReportDetails(context, report);
                        },
                      ),
                      
                      // PULSANTE CHAT: Apre la chat RAG interattiva
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.textWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Chat AI'),
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => ReportDetailChatScreen(report: report))
                          );
                        },
                      ),
                      
                      // PULSANTE FOTO/VIDEO: Placeholder momentaneo non attivo
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mediaButtonBg,
                          foregroundColor: AppTheme.textLight,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                        ),
                        icon: const Icon(Icons.add_a_photo, size: 16),
                        label: const Text('Foto/Video'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funzionalità Foto/Video non attiva su questo report.'))
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Dialog modale per visualizzare il report quando l'utente preme "Apri"
  void _showReportDetails(BuildContext context, Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.taskTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Data: ${report.date}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Divider(),
                // Testo semplice ben spaziato (height: 1.5 aumenta la distanza tra le righe)
                Text(
                  report.aiSummary,
                  style: const TextStyle(fontSize: 15, height: 1.5, color: AppTheme.textDark),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi', style: TextStyle(color: AppTheme.primary)),
          )
        ],
      ),
    );
  }
}