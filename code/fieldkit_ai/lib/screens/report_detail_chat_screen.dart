import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/app_provider.dart'; 
import '../models/models.dart';
import '../theme/app_theme.dart';

class ReportDetailChatScreen extends StatefulWidget {
  final Report report;
  const ReportDetailChatScreen({super.key, required this.report});

  @override
  State<ReportDetailChatScreen> createState() => _ReportDetailChatScreenState();
}

class _ReportDetailChatScreenState extends State<ReportDetailChatScreen> {
  final _chatCtrl = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool isAiTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Ciao! Sono l\'assistente AI di FieldKit.\nHo analizzato il report. Fammi qualsiasi domanda sulle **normative** o sui **dettagli tecnici** relativi all\'impianto scelto.', 
      isUser: false
    ));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_chatCtrl.text.isEmpty) return;
    
    final userQuery = _chatCtrl.text;
    setState(() {
      _messages.add(ChatMessage(text: userQuery, isUser: true));
      _chatCtrl.clear();
      isAiTyping = true;
    });
    _scrollToBottom();

    final provider = context.read<AppProvider>();

    final promptUnito = """
    Ecco il report ufficiale appena compilato:
    --- INIZIO REPORT ---
    ${widget.report.aiSummary}
    --- FINE REPORT ---
    
    RICERCA FONDAMENTALE: Prima di rispondere, DEVI cercare approfonditamente nei manuali tecnici e documenti .pdf a tua disposizione.
    
    Rispondi in modo professionale a questa richiesta dell'utente:
    "$userQuery"
    
    REGOLE IMPERATIVE PER LA CITAZIONE DELLA FONTE:
    1. Scrivi la fonte in una sola riga alla fine, formattata ESATTAMENTE così: "**Fonte:** [Nome fonte]". 
    2. VIETATO usare frasi introduttive come "Trovato nei documenti", "Trovato nel report". Scrivi SOLO "**Fonte:** ...".
    3. Se l'info è nel esplicitamente nel report qui sopra scrivi: "**Fonte:** Report utente".
    4. Se l'info è nei manuali PDF scrivi: "**Fonte:** [Nome e pagina del manuale]".
    5. Se l'info non è né in report né nei manuali: NON SCRIVERE NULLA ALLA FINE.
    """;

    final aiResponse = await provider.callBackend(promptUnito);
    
    // Pulizia della stringa
    String cleanResponse = aiResponse
        .replaceAll(RegExp(r'Trovato nei documenti\.\s*'), '')
        .replaceAll(RegExp(r'Trovato nel report\.\s*'), '')
        .trim();

    setState(() {
      isAiTyping = false;
      _messages.add(ChatMessage(text: cleanResponse, isUser: false));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900),
        decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 20 : 16),
              decoration: const BoxDecoration(color: AppTheme.sidebarBg, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Assistente AI', style: TextStyle(color: Colors.white, fontSize: AppTheme.titleSize(context), fontWeight: FontWeight.bold))),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * (isDesktop ? 0.6 : 0.8)),
                      decoration: BoxDecoration(
                        color: msg.isUser ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(msg.isUser ? 20 : 0),
                          bottomRight: Radius.circular(msg.isUser ? 0 : 20),
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: MarkdownBody(
                        data: msg.text,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(color: msg.isUser ? Colors.white : AppTheme.textDark, fontSize: AppTheme.bodySize(context), height: 1.5),
                          strong: TextStyle(fontWeight: FontWeight.w900, color: msg.isUser ? Colors.white : AppTheme.primaryDark),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            if (isAiTyping)
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Center(child: CircularProgressIndicator(color: AppTheme.primary))),
              
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatCtrl,
                        decoration: InputDecoration(
                          hintText: 'Chiedi dettagli',
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton(
                      backgroundColor: AppTheme.primary,
                      elevation: 0,
                      onPressed: _sendMessage,
                      child: const Icon(Icons.send, color: Colors.white),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}