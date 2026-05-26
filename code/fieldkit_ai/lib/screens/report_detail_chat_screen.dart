import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Assistente AI attivo per il report dell\'impianto. Fai domande sul documento o sulle normative di settore.', 
      isUser: false
    ));
  }

  void _sendMessage() async {
    if (_chatCtrl.text.isEmpty) return;
    
    final userQuery = _chatCtrl.text;
    setState(() {
      _messages.add(ChatMessage(text: userQuery, isUser: true));
      _chatCtrl.clear();
      isAiTyping = true;
    });

    final provider = context.read<AppProvider>();

    // Siccome le regole RAG severe ora sono sul server Render,
    // a noi basta "allegare" il testo del report alla domanda dell'utente.
    final promptUnito = """
    Ecco il report appena compilato:
    --- INIZIO REPORT ---
    ${widget.report.aiSummary}
    --- FINE REPORT ---
    
    Rispondi a questa domanda dell'utente seguendo le tue regole RAG:
    $userQuery
    """;

    // Chiamiamo il nostro server Render!
    final aiResponse = await provider.callBackend(promptUnito);

    setState(() {
      isAiTyping = false;
      _messages.add(ChatMessage(text: aiResponse, isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Assistente RAG')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surface,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.report.taskTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 6),
                Text('Creato il: ${widget.report.date}', style: const TextStyle(color: AppTheme.textLight)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      msg.text, 
                      style: TextStyle(color: msg.isUser ? AppTheme.primary : AppTheme.textDark, fontSize: 15)
                    ),
                  ),
                );
              },
            ),
          ),
          if (isAiTyping)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            color: AppTheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Fai una domanda sul report...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16)
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primary), 
                  onPressed: _sendMessage
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}