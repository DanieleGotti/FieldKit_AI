const express = require('express');
const path = require('path');
const fs = require('fs');
const pdf = require('pdf-parse'); // La libreria che legge i PDF

const app = express();
const PORT = process.env.PORT || 3000;
const MISTRAL_API_KEY = process.env.MISTRAL_API_KEY; // Dalle Environment di Render

app.use(express.json());

// 1. CARICAMENTO DEI PDF CON TRACCIAMENTO DELLE PAGINE
const pdfDir = path.join(__dirname, 'pdfs');
let knowledgeBase = "";

// Funzione speciale per "stampare" il numero di pagina mentre legge il PDF
function render_page(pageData) {
    return pageData.getTextContent().then(function(textContent) {
        let text = textContent.items.map(item => item.str).join(' ');
        return `\n[PAGINA ${pageData.pageIndex + 1}]\n${text}`;
    });
}

async function loadPDFs() {
  if (fs.existsSync(pdfDir)) {
    const files = fs.readdirSync(pdfDir).filter(f => f.endsWith('.pdf'));
    for (const file of files) {
      let dataBuffer = fs.readFileSync(path.join(pdfDir, file));
      try {
        let data = await pdf(dataBuffer, { pagerender: render_page });
        knowledgeBase += `\n\n--- INIZIO FILE PDF: ${file} ---\n${data.text}\n--- FINE FILE PDF ---`;
      } catch (err) {
        console.error(`Errore lettura PDF ${file}:`, err);
      }
    }
    console.log(`Caricati ${files.length} PDF nel server con successo!`);
  }
}

// Avviamo la lettura dei PDF quando si accende il server
loadPDFs();

// 2. L'API CHE CHIAMERÀ FLUTTER
app.post('/api/chat', async (req, res) => {
  const { prompt } = req.body;

  // LE TUE REGOLE ESATTE AL 100% (Ho solo aggiunto dove pescare i dati)
  const systemPrompt = `SEI UN ASSISTENTE TECNICO. Usa SEMPRE E SOLO i file PDF allegati a questo agente per rispondere e, se presente, il report allegato nel messaggio della domanda. 
Se la risposta è nel report dell'utente, scrivi 'Trovato nel report. '. 
Se è nei PDF, scrivi 'Trovato nei documenti. '. 
Se non c'è, scrivi 'Informazione non trovata nei documenti, non rispondo per ragioni di sicurezza'. 
Inoltre metti sempre in fondo al messaggio nome file, capitolo e pagina della fonte se c'è.

ECCO IL CONTENUTO DEI FILE PDF ALLEGATI:
${knowledgeBase}`;

  try {
    const response = await fetch('https://api.mistral.ai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${MISTRAL_API_KEY}`
      },
      body: JSON.stringify({
        model: 'mistral-large-latest', // Il modello migliore per il ragionamento
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: prompt }
        ]
      })
    });

    const data = await response.json();
    if (!response.ok) throw new Error(JSON.stringify(data));

    const textResponse = data.choices[0].message.content;
    res.status(200).json({ answer: textResponse });
    
  } catch (error) {
    console.error("Errore Mistral API:", error);
    res.status(500).json({ error: 'Errore interno del server' });
  }
});

// 3. OSPITA LA WEB APP FLUTTER
app.use(express.static(path.join(__dirname, 'build/web')));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server avviato sulla porta ${PORT}`);
});