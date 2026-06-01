import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'report_detail_chat_screen.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  // PIALLATORE TOTALE: Rimuove tutto ciò che genera i quadrati neri
  String _sanitizeForPdf(String text) {
    return text
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        // Distrugge i cancelletti markdown se l'AI dovesse metterli per sbaglio
        .replaceAll(RegExp(r'^#+\s*'), '') 
        // Converte i vari tipi di bullet point strani in un semplice trattino
        .replaceAll(RegExp(r'[•·▪▫►♦]'), '-'); 
  }

  Future<Uint8List> _generatePdfBytes(Report report) async {
    final pdf = pw.Document();

    pw.Widget parseLine(String line) {
      if (line.trim().isEmpty) return pw.SizedBox(height: 8);
      
      // Prima sanitizziamo pesantemente la riga
      String cleanLine = _sanitizeForPdf(line.trim());
      
      bool isBullet = cleanLine.startsWith('-');
      if (isBullet) {
        cleanLine = cleanLine.substring(1).trim(); // Togliamo il trattino per usare il bullet nativo del PDF
      }

      // Se la riga è tutta in grassetto (es. titolo)
      bool isTitleLine = cleanLine.startsWith('**') && cleanLine.endsWith('**') && cleanLine.length > 4;

      final spans = <pw.InlineSpan>[];
      final parts = cleanLine.split('**');
      for (int i = 0; i < parts.length; i++) {
        if (i % 2 != 0) { 
          spans.add(pw.TextSpan(text: parts[i], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
        } else {
          spans.add(pw.TextSpan(text: parts[i]));
        }
      }

      // Se è una riga titolo, la facciamo leggermente più grande
      pw.Widget textWidget = pw.RichText(
        text: pw.TextSpan(
          children: spans, 
          style: pw.TextStyle(
            fontSize: isTitleLine ? 13 : 11, 
            color: PdfColors.black, 
            lineSpacing: 1.5
          )
        )
      );

      if (isBullet) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 15, bottom: 4, top: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('- ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)), // Trattino pulito
              pw.Expanded(child: textWidget),
            ]
          )
        );
      }
      return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 6), child: textWidget);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('FIELDKIT AI', style: pw.TextStyle(color: PdfColors.red800, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('DOCUMENTO DI ISPEZIONE', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
              ]
            ),
            pw.Divider(color: PdfColors.red800, thickness: 1.5),
            pw.SizedBox(height: 20),
          ]
        ),
        build: (pw.Context context) {
          return report.aiSummary.split('\n').map((line) => parseLine(line)).toList();
        },
      ),
    );

    return pdf.save();
  }

  void _showReportDetails(BuildContext context, Report report) {
    bool isDesktop = MediaQuery.of(context).size.width >= 800;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isDesktop ? 24 : 0), 
        child: Container(
          width: double.infinity,
          height: double.infinity,
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(isDesktop ? 12 : 0)),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 20 : 16),
                decoration: BoxDecoration(color: AppTheme.sidebarBg, borderRadius: BorderRadius.vertical(top: Radius.circular(isDesktop ? 12 : 0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(report.taskTitle, style: TextStyle(color: Colors.white, fontSize: AppTheme.titleSize(context), fontWeight: FontWeight.bold))),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(isDesktop ? 12 : 0)),
                  child: PdfPreview(
                    build: (format) => _generatePdfBytes(report),
                    allowPrinting: true, 
                    allowSharing: false, 
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false, 
                    pdfFileName: '${report.taskTitle.replaceAll(' ', '_')}.pdf',
                    actions: [
                      PdfPreviewAction(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: (context, build, pageFormat) async {
                          final bytes = await build(pageFormat);
                          await Printing.sharePdf(
                            bytes: bytes, 
                            filename: '${report.taskTitle.replaceAll(' ', '_')}.pdf'
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(title: Text('Archivio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppTheme.titleSize(context)))),
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
                                Text(report.taskTitle, style: TextStyle(fontWeight: FontWeight.w800, fontSize: AppTheme.titleSize(context), color: AppTheme.textDark)),
                                const SizedBox(height: 8),
                                Text('Generato il: ${report.date}\nStatus: Completato', style: TextStyle(color: AppTheme.textLight, fontSize: AppTheme.bodySize(context), height: 1.5)),
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
                            label: Text('Visualizza PDF', style: TextStyle(fontSize: AppTheme.bodySize(context))),
                            onPressed: () => _showReportDetails(context, report),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text('Chat con l\'AI', style: TextStyle(fontSize: AppTheme.bodySize(context), fontWeight: FontWeight.bold)),
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
}