import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({super.key});

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> with AutomaticKeepAliveClientMixin {
  final _idCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  bool isLoadingAiQuestions = false;
  List<String> aiQuestionsList = [];
  List<TextEditingController> aiAnswersCtrls = [];
  bool isReportReady = false;

  @override
  bool get wantKeepAlive => true; 

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funzionalità in fase di sviluppo. Disponibile a breve!'), backgroundColor: AppTheme.textDark, behavior: SnackBarBehavior.floating)
    );
  }

  void _getInitialAiQuestions() async {
    if (_idCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inserisci la matricola dell\'impianto.')));
      return;
    }
    setState(() { isLoadingAiQuestions = true; aiQuestionsList.clear(); aiAnswersCtrls.clear(); });
    final provider = context.read<AppProvider>();
    
    // Prompt dettagliato per guidare l'AI a generare domande tecniche pertinenti
    final prompt = """
    L'operatore sta controllando l'impianto matricola ${_idCtrl.text}. Note: "${_notesCtrl.text}".
  
    REGOLA 1: Se la matricola o le note sono palesemente parole a caso (es. "asdasd"), lettere senza senso o non pertinenti a un ispezione o macchinari tecnici, DEVI BLOCCARE TUTTO e rispondere SOLO con: ERRORE_DATI
    
    REGOLA 2: Se i dati hanno senso, genera 3 domande prendendo spunto dai pdf di manuali che aiutino l'operatore a verificare lo stato dell'impianto, controllare se ha fatto tutta la procedura o raccogliere tutto ciò che serve per fare un lavoro e un report completo.
    
    REGOLA ASSOLUTA: NON SCRIVERE A FINE DEL MESSAGGIO LE FONTI.
    
    REGOLA IMPORTANTISSIMA: Fornisci SOLO le domande, NIENTE ALTRO. Non scrivere introduzioni, spiegazioni o altro. SOLO LE DOMANDE, in elenco puntato, senza numeri, simboli o formattazione. Perchè estraggo dalle tue righe il testo da mettere nell'app.
    """;

    final response = await provider.callBackend(prompt);

    if (response.contains("ERRORE_DATI")) {
      setState(() => isLoadingAiQuestions = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dati non validi. Inserisci dati reali.'), backgroundColor: AppTheme.error));
      return;
    }

    List<String> rawQuestions = response.split('\n')
        .map((q) => q.replaceAll(RegExp(r'^\d+\.\s*|-\s*|\*'), '').trim())
        .where((q) => q.isNotEmpty && !q.toLowerCase().contains("fonte")) 
        .toList();

    setState(() {
      aiQuestionsList = rawQuestions;
      aiAnswersCtrls = List.generate(rawQuestions.length, (index) => TextEditingController());
      isReportReady = true;
      isLoadingAiQuestions = false;
    });
  }

  void _addOneMoreQuestion() async {
    setState(() => isLoadingAiQuestions = true);
    final provider = context.read<AppProvider>();
    String alreadyAsked = aiQuestionsList.map((e) => "- $e").join('\n');

    final prompt = """
    L'operatore controlla l'impianto ${_idCtrl.text}. Note: "${_notesCtrl.text}". Ha già risposto a:
    $alreadyAsked

    Genera 1 SOLA NUOVA domanda tecnica diversa.

    REGOLA ASSOLUTA: NON SCRIVERE A FINE DEL MESSAGGIO LE FONTI. 

    REGOLA IMPORTANTISSIMA: Fornisci SOLO la domanda, NIENTE ALTRO. Non scrivere introduzioni, spiegazioni o altro. SOLO LA DOMANDA, senza numeri, simboli o formattazione.
    """;

    final response = await provider.callBackend(prompt);
    String newQ = response.replaceAll(RegExp(r'^\d+\.\s*|-\s*|\*'), '').trim();

    setState(() {
      if(newQ.isNotEmpty && !newQ.toLowerCase().contains("fonte")) {
        aiQuestionsList.add(newQ);
        aiAnswersCtrls.add(TextEditingController());
      }
      isLoadingAiQuestions = false;
    });
  }

  void _generateFinalReport() async {
    setState(() => isLoadingAiQuestions = true);
    final provider = context.read<AppProvider>();

    String answeredQA = "";
    String unansweredQuestions = "";
    
    for (int i = 0; i < aiQuestionsList.length; i++) {
      String ans = aiAnswersCtrls[i].text.trim();
      if (ans.isNotEmpty) {
        answeredQA += "- ${aiQuestionsList[i]}\n  Riscontro: $ans\n";
      } else {
        unansweredQuestions += "- ${aiQuestionsList[i]}\n";
      }
    }

    if (answeredQA.isEmpty) answeredQA = "Nessuna verifica aggiuntiva effettuata durante l'ispezione.";
    if (unansweredQuestions.isEmpty) unansweredQuestions = "Nessuna raccomandazione specifica aggiuntiva.";

    final prompt = """
    Agisci come un Ingegnere Manutentore Senior. Redigi il report tecnico finale dell'ispezione usando formattazione MARKDOWN, usa solo **grassetto**, nessun cancelletto #, elenchi o spaziature particolari. 
    
    RICERCA MANUALI: Consulta attivamente i manuali tecnici PDF a tua disposizione per arricchire il Punto 3 con dettagli specifici, tolleranze o procedure ufficiali.

    Dati da fondere:
    Matricola: ${_idCtrl.text}
    Note rilevate inizialmente: ${_notesCtrl.text}
    
    Dati Verificati (da mettere nel Punto 2): 
    $answeredQA
    
    Verifiche Saltate (da mettere nel Punto 3 come azioni future da compiere):
    $unansweredQuestions

    REGOLA TASSATIVA 1: Non dire MAI che l'operatore non ha risposto a una domanda o ha saltato dei passaggi. Le "Verifiche Saltate" devono essere inserite nel Punto 3 trasformandole elegantemente in raccomandazioni.
    REGOLA TASSATIVA 2: NON INSERIRE ALCUNA FONTE ALLA FINE DEL REPORT. Non scrivere "Trovato nei documenti" o altro. Lo farà il sistema in automatico.
    
    Segui ESATTAMENTE questa struttura:

    **REPORT DI MANUTENZIONE TECNICA E CONFORMITÀ**
    **Tecnico Responsabile:** ${provider.loggedUser}
    **Data:** Oggi
    **Matricola Impianto:** ${_idCtrl.text}

    **1. STATO DELL'ARTE E ANAGRAFICA IMPIANTO**
    [Fondi le note iniziali in un'introduzione discorsiva]

    **2. ESITO DELLE VERIFICHE TECNICHE APPROFONDITE**
    [Descrivi i risultati basandoti SOLO sui "Dati Verificati"]

    **3. RACCOMANDAZIONI E INTERVENTI SUGGERITI**
    [Inserisci qui le raccomandazioni e integra nozioni dai manuali tecnici]
    """;

    final reportContent = await provider.callBackend(prompt);
    
    // Pulizia stringa
    String cleanReport = reportContent
        .replaceAll(RegExp(r'Trovato nei documenti\.\s*'), '')
        .replaceAll(RegExp(r'Trovato nel report\.\s*'), '')
        .replaceAll(RegExp(r"Fonte: dati forniti dall'utente.*"), '')
        .trim();
        
    // Aggiungianta della fonte 
    cleanReport += "\n\n**Fonte:** Input utente e manuali tecnici.";

    provider.addGeneratedReport("Report: ${_idCtrl.text}", cleanReport);

    _idCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      aiQuestionsList.clear();
      aiAnswersCtrls.clear();
      isReportReady = false;
      isLoadingAiQuestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(title: Text('Ispezione', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppTheme.titleSize(context)))),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Dati impianto'), 
                            const SizedBox(height: 24),
                            TextField(controller: _idCtrl, decoration: const InputDecoration(labelText: 'Matricola', prefixIcon: Icon(Icons.qr_code))),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _notesCtrl, 
                              minLines: 4, maxLines: 15,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(labelText: 'Aggiungi dettagli', prefixIcon: Padding(padding: EdgeInsets.only(bottom: 80), child: Icon(Icons.edit_note)))
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: _buildSectionTitle(context, 'Acquisizione multimediale'),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _mediaBtn(context, Icons.camera_alt, 'Foto', isDesktop),
                                _mediaBtn(context, Icons.videocam, 'Video', isDesktop),
                                _mediaBtn(context, Icons.mic, 'Audio', isDesktop),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (aiQuestionsList.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Verifica con l\'AI', icon: Icons.auto_awesome, color: AppTheme.warning),
                      const SizedBox(height: 16),
                      ...List.generate(aiQuestionsList.length, (index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: AppTheme.bodySize(context), height: 1.5),
                                    children: [
                                      TextSpan(
                                        text: 'Domanda ${index + 1}: ',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary), 
                                      ),
                                      TextSpan(
                                        text: aiQuestionsList[index],
                                        style: const TextStyle(fontWeight: FontWeight.normal, color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: aiAnswersCtrls[index], 
                                  minLines: 2, maxLines: 10,
                                  keyboardType: TextInputType.multiline,
                                  decoration: const InputDecoration(labelText: 'Risposta (lascia vuoto per rimandare a future ispezioni)')
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: isLoadingAiQuestions 
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                              onPressed: _addOneMoreQuestion, 
                              icon: const Icon(Icons.add), 
                              label: const Text('Genera un\'altra domanda')
                            ),
                      )
                    ] else if (isLoadingAiQuestions) ...[
                       const Center(child: CircularProgressIndicator())
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
            ),
            child: SafeArea( 
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  width: double.infinity,
                  height: 64,
                  child: !isReportReady 
                    ? ElevatedButton.icon(icon: const Icon(Icons.analytics), label: const Text('Analizza e genera domande'), onPressed: _getInitialAiQuestions)
                    : ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary), icon: const Icon(Icons.done_all), label: const Text('Genera il report'), onPressed: _generateFinalReport),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {IconData? icon, Color color = AppTheme.textDark}) {
    return Row(
      children: [
        if (icon != null) ...[Icon(icon, color: color, size: AppTheme.titleSize(context) + 4), const SizedBox(width: 8)],
        Text(title, style: TextStyle(fontSize: AppTheme.titleSize(context), fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _mediaBtn(BuildContext context, IconData icon, String label, bool isDesktop) {
    return GestureDetector(
      onTap: _showComingSoon,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: const BoxDecoration(color: AppTheme.mediaButtonBg, shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppTheme.bodySize(context), color: AppTheme.textDark)),
        ],
      ),
    );
  }
}