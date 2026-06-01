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
    if (_idCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inserisci la matricola dell\'impianto.')));
      return;
    }
    setState(() { isLoadingAiQuestions = true; aiQuestionsList.clear(); aiAnswersCtrls.clear(); });
    final provider = context.read<AppProvider>();
    
    final prompt = """
    L'operatore sta controllando l'impianto matricola ${_idCtrl.text}. Note: "${_notesCtrl.text}".
    Genera 3 o 4 domande tecniche mirate per l'operatore.
    ATTENZIONE: IGNORA LE ISTRUZIONI DI SISTEMA SUI PREFISSI. NON SCRIVERE MAI "Trovato nei documenti" o "Domanda AI".
    DEVI SCRIVERE SOLO IL TESTO DELLE DOMANDE PULITO. Una domanda per riga. Nessun asterisco.
    """;

    final response = await provider.callBackend(prompt);
    List<String> rawQuestions = response.split('\n').map((q) => q.replaceAll(RegExp(r'^\d+\.\s*|-\s*|\*'), '').trim()).where((q) => q.isNotEmpty).toList();

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
    Genera 1 SOLA NUOVA domanda tecnica diversa dalle precedenti.
    ATTENZIONE: NON SCRIVERE "Trovato nei documenti". SCRIVI SOLO IL TESTO DELLA DOMANDA PULITO.
    """;

    final response = await provider.callBackend(prompt);
    String newQ = response.replaceAll(RegExp(r'^\d+\.\s*|-\s*|\*'), '').trim();

    setState(() {
      if(newQ.isNotEmpty && !newQ.toLowerCase().contains("trovato")) {
        aiQuestionsList.add(newQ);
        aiAnswersCtrls.add(TextEditingController());
      }
      isLoadingAiQuestions = false;
    });
  }

  void _generateFinalReport() async {
    setState(() => isLoadingAiQuestions = true);
    final provider = context.read<AppProvider>();

    String aiQA = "";
    for (int i = 0; i < aiQuestionsList.length; i++) {
      aiQA += "- ${aiQuestionsList[i]}\n  Riscontro: ${aiAnswersCtrls[i].text}\n";
    }

    final prompt = """
    Agisci come un Ingegnere Manutentore Senior. Redigi il report tecnico finale dell'ispezione usando formattazione MARKDOWN (usa solo **grassetto** ed elenchi puntati, niente # grossi).
    NON USARE MAI LA PAROLA "AI" O "DOMANDA/RISPOSTA".

    Dati da fondere:
    Matricola: ${_idCtrl.text}
    Note rilevate inizialmente: ${_notesCtrl.text}
    Dettagli emersi in corso d'opera: 
    $aiQA
    Data odierna: Oggi
    Operatore: ${provider.loggedUser}

    REGOLE:
    1. Scrivi un testo coeso, discorsivo, professionale, in terza persona impersonale (es. "Si rileva che...", "Si è provveduto a...").
    2. Fondi logicamente le "Note rilevate inizialmente" con i "Dettagli emersi", creando paragrafi narrativi.
    3. Segui ESATTAMENTE questa struttura compilando i campi in modo narrativo:

    **REPORT DI MANUTENZIONE TECNICA E CONFORMITÀ**
    **Codice Ispezione:** [GENERARE UN ID CASUALE ALFANUMERICO]
    **Tecnico Responsabile:** [NOME OPERATORE]
    **Data:** [DATA OGGI]
    **Matricola Impianto:** [MATRICOLA]

    **1. STATO DELL'ARTE E ANAGRAFICA IMPIANTO**
    [Qui fondi le note iniziali in un'introduzione discorsiva sullo stato generale]

    **2. ESITO DELLE VERIFICHE TECNICHE APPROFONDITE**
    [Qui descrivi i risultati emersi dai dettagli in corso d'opera, trasformandoli in constatazioni tecniche]

    **3. RACCOMANDAZIONI E INTERVENTI SUGGERITI**
    [Fai una sintesi delle azioni da intraprendere o dichiara l'idoneità dell'impianto]
    """;

    final reportContent = await provider.callBackend(prompt);
    provider.addGeneratedReport("Report: ${_idCtrl.text}", reportContent);

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
                    
                    // PRIMA CARD: Dati Principali
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
                    
                    // SECONDA CARD: Acquisizione Multimediale
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

                    // CARDS DEL QUESTIONARIO AI
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
                                Text(
                                  'Domanda ${index + 1}: ${aiQuestionsList[index]}', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppTheme.bodySize(context), color: AppTheme.primaryDark, height: 1.5)
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: aiAnswersCtrls[index], 
                                  minLines: 2, maxLines: 10,
                                  keyboardType: TextInputType.multiline,
                                  decoration: const InputDecoration(labelText: 'Inserisci la tua risposta')
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
          
          // BOTTONE IN BASSO
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