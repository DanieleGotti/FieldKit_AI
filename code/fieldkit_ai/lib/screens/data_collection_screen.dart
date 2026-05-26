import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({super.key});

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> {
  final _idCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _aiResponseCtrl = TextEditingController();

  bool isPhotoGreen = false;
  bool isVideoGreen = false;
  bool isAudioGreen = false;

  bool isLoadingAiQuestions = false;
  String aiQuestions = ""; // Domande dinamiche generate da Gemini
  bool isReportReady = false;

  // IL TUO TEMPLATE DEL REPORT INCORPORATO DIRETTAMENTE NEL CODICE
  static const String reportTemplate = """
  REPORT DI MANUTENZIONE TECNICA E CONFORMITA'

  Codice Report: [ID_GENERATO_DA_AI]
  Operatore Responsabile: [NOME_OPERATORE]
  Data Ispezione: [DATA_OGGI]

  1. ANAGRAFICA IMPIANTO
  - Matricola Impianto: [MATRICOLA]
  - Tipologia Impianto: [TIPO_IMPIANTO]
  - Ubicazione: [UBICAZIONE_CLIENTE]
  - Normativa di Riferimento applicata: [NORMATIVA_RIFERIMENTO]

  2. STATO DI CONSERVAZIONE E ANALISI VISIVA
  - Stato Generale: [CONFORME / NON CONFORME / DA ATTENZIONARE]
  - Analisi dei Componenti Critici:
    * Componente A: [Stato e usura rilevati]
    * Componente B: [Stato e usura rilevati]
  - Dettagli da Analisi Multimediale: [Descrizione dettagliata]

  3. QUESTIONARIO DI VERIFICA AI
  - Verifica A: [Risposta fornita all'AI]
  - Verifica B: [Risposta fornita all'AI]

  4. AZIONI CORRETTIVE E RACCOMANDAZIONI
  - Interventi Immediati: [Sì/No + Descrizione]
  - Prossimo Controllo: [Data consigliata]

  5. DICHIARAZIONE DI RESPONSABILITA'
  Il sottoscritto [NOME_OPERATORE] dichiara sotto la propria responsabilita' che l'impianto in oggetto e' stato sottoposto alle verifiche sopra descritte in conformita' alle norme vigenti.
  Firma Elettronica: [FIRMA_OPERATORE]
  """;

  // Flash temporaneo del pulsante multimediale
  void _triggerFlashButton(String type) {
    setState(() {
      if (type == 'photo') isPhotoGreen = true;
      if (type == 'video') isVideoGreen = true;
      if (type == 'audio') isAudioGreen = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          if (type == 'photo') isPhotoGreen = false;
          if (type == 'video') isVideoGreen = false;
          if (type == 'audio') isAudioGreen = false;
        });
      }
    });
  }

  // STEP 1: Richiede all'AI di formulare domande basandosi sugli input per completare il documento a norma
  void _getAiMissingQuestions() async {
    if (_idCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci prima la Matricola Impianto.'))
      );
      return;
    }

    setState(() {
      isLoadingAiQuestions = true;
      aiQuestions = "";
    });

    final provider = context.read<AppProvider>();
    
    final prompt = """
    L'operatore sta controllando l'impianto matricola ${_idCtrl.text}.
    Note inserite dall'operatore: "${_notesCtrl.text}".
    
    In base alle norme tecniche e di sicurezza degli impianti industriali,
    individua le informazioni o i controlli critici che l'operatore potrebbe aver dimenticato o tralasciato di inserire in questo contesto.
    Genera al massimo 5 domande tecniche molto brevi e mirate per forzare l'operatore a verificare questi dettagli critici.
    Evita spiegazioni prolisse, restituisci solo le domande numerate in italiano.
    """;

    final response = await provider.callBackend(prompt);

    setState(() {
      isLoadingAiQuestions = false;
      aiQuestions = response;
      isReportReady = true; // Sblocca la possibilità di generare il report finale
    });
  }

  // STEP 2: Invia il template del report assieme a tutti i dati raccolti all'AI per la compilazione
  void _generateFinalReport() async {
    setState(() {
      isLoadingAiQuestions = true;
    });

    final provider = context.read<AppProvider>();

    // Qui il codice inserisce e invia il template e i dati estratti direttamente alle API di Gemini
    final prompt = """
    Compila e restituisci questo report in FORMATO TESTO SEMPLICE. 
    ASSOLUTAMENTE NON USARE IL MARKDOWN: non usare MAI asterischi (**) o cancelletti (#).
    Usa solo lettere maiuscole per i titoli e vai a capo per separare i paragrafi.
    Riempi i campi tra parentesi quadre [...] con i dati raccolti.

    DATI DA INSERIRE:
    - Matricola Impianto: ${_idCtrl.text}
    - Dettagli operatore: ${_notesCtrl.text}
    - Risposte alle domande aggiuntive AI: ${_aiResponseCtrl.text}
    - Data odierna: 16 Maggio 2026
    - Nome operatore: ${provider.loggedUser}

    TEMPLATE DA COMPILARE RIGOROSAMENTE:
    $reportTemplate
    """;

    final reportContent = await provider.callBackend(prompt);

    provider.addGeneratedReport("Report Impianto ${_idCtrl.text}", reportContent);

    // Reset completo dello stato della scheda
    _idCtrl.clear();
    _notesCtrl.clear();
    _aiResponseCtrl.clear();
    setState(() {
      aiQuestions = "";
      isReportReady = false;
      isLoadingAiQuestions = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report generato correttamente e salvato nell\'Archivio.'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ispezione Guidata')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acquisizione Multimediale', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _mediaBtn(Icons.camera_alt, 'Foto', isPhotoGreen, () => _triggerFlashButton('photo')),
                _mediaBtn(Icons.videocam, 'Video', isVideoGreen, () => _triggerFlashButton('video')),
                _mediaBtn(Icons.mic, 'Audio', isAudioGreen, () => _triggerFlashButton('audio')),
              ],
            ),
            const Divider(height: 48, color: AppTheme.divider),
            Text('Dati di Ispezione', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _idCtrl, 
              decoration: const InputDecoration(labelText: 'Matricola Impianto', border: OutlineInputBorder(), filled: true, fillColor: AppTheme.surface)
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl, 
              maxLines: 3, 
              decoration: const InputDecoration(labelText: 'Dettagli scritti dall\'operatore...', border: OutlineInputBorder(), filled: true, fillColor: AppTheme.surface)
            ),
            const SizedBox(height: 24),

            if (isLoadingAiQuestions)
              const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            else if (aiQuestions.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.warningBg, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.warning),
                        const SizedBox(width: 8),
                        Text('Questionario Dinamico AI:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, color: AppTheme.warning)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(aiQuestions, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _aiResponseCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Rispondi alle domande sollevate dall\'AI...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.surface
                ),
              ),
            ],

            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: !isReportReady 
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.analytics),
                    label: const Text('ANALIZZA INPUT & GENERA DOMANDE'),
                    onPressed: _getAiMissingQuestions,
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                    icon: const Icon(Icons.done_all),
                    label: const Text('ELABORA E GENERA REPORT FINALE'),
                    onPressed: _generateFinalReport,
                  ),
            )
          ],
        ),
      ),
    );
  }

  Widget _mediaBtn(IconData icon, String label, bool isGreen, VoidCallback onTap) {
    Color color = isGreen ? AppTheme.success : AppTheme.textDark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isGreen ? AppTheme.success.withOpacity(0.15) : AppTheme.mediaButtonBg, 
              shape: BoxShape.circle,
              border: isGreen ? Border.all(color: AppTheme.success, width: 2) : null,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}