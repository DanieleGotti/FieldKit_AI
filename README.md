![logo](doc/img/logo.png) # FieldKit AI - Assistente Operativo Smart 🛠️

🚀 ## Progetto
**FieldKit AI** è un *prototipo* di applicazione pensata per supportare i tecnici manutentori sul campo. L'app digitalizza il processo di ispezione e utilizza l'AI per generare report professionali e rispondere a dubbi tecnici.

Il cuore dell'app è un sistema **RAG (Retrieval-Augmented Generation)**: l'intelligenza artificiale "legge" e comprende complessi manuali normativi in PDF, fornendo risposte precise e citando la fonte esatta, bloccando le allucinazioni in caso di domande non pertinenti alla sicurezza antincendio.

🎥 ## Video  
Clicca sull'immagine qui sotto per vedere una dimostrazione pratica dell'applicazione e della chat con l'AI:

[![Guarda la demo di FieldKit AI](https://img.youtube.com/vi/ID_DEL_TUO_VIDEO/maxresdefault.jpg)](https://drive.google.com/file/d/1bwSJdvUm3F-Ugv0GfXOJGgD6fQJsKAlc/view?usp=drive_link)

🛠️ ## Struttura 
Il progetto è sviluppato con architettura client-server:
- **Frontend ([Flutter](https://flutter.dev/)):** Interfaccia utente fluida e responsiva, suddivisa in Ispezione, Archivio (con generazione PDF nativa) e Live.
- **Backend ([Node.js](https://nodejs.org/)):** API REST ospitata su **[Render](https://render.com/)**, che fa da ponte tra l'app e **[Mistral AI](https://mistral.ai/)**.

👨‍💻 ## Sviluppatore
| Nome e Cognome | Profilo GitHub |
|----------------|----------------|
| **Daniele Gotti** | [@DanieleGotti](https://github.com/DanieleGotti) |
