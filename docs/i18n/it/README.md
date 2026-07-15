[English](../../README.md) | [한국어](../ko/README.md) | [日本語](../ja/README.md) | [简体中文](../zh-Hans/README.md) | [繁體中文](../zh-Hant/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Deutsch](../de/README.md) | [Português](../pt/README.md) | [Русский](../ru/README.md) | **[Italiano](README.md)**

> Questa è una traduzione di [README.md](../../README.md). La versione in inglese è la fonte autorevole e potrebbe essere più aggiornata.

# toefl-prep

> Plugin di studio per il TOEFL iBT — **Claude Code · Codex · agy(Antigravity CLI)**. Valuta completamente offline le 4 aree Reading/Listening/Speaking/Writing con **LLM locale(Ollama) + whisper.cpp**.

Dalla generazione delle domande alla correzione e al monitoraggio dei punteggi, tutto è elaborato sul tuo computer, senza API esterne. Il percorso di studio è **personalizzato dall'utente** — definisci tu durata, giorni della settimana, fasce orarie e obiettivi settimanali.

## Caratteristiche

- **Correzione completamente offline** — usa solo modelli locali. Nessun costo o latenza API, e i dati non escono mai dal dispositivo.
- **Valutazione per area**:
  - Reading/Listening — revisione delle risposte tramite LLM + evidenze citate dal testo/script
  - Writing — correzione diretta con rubrica ETS 0–5 punti (contenuto/organizzazione/linguaggio/meccanica)
  - Speaking — trascrizione whisper.cpp → rubrica LLM (consegna/uso della lingua/sviluppo dell'argomento)
- **Percorso personalizzato** — `schedule.yaml` determina date, giorni della settimana, orari e obiettivi per settimana. Nessun valore hardcoded.
- **Monitoraggio dei punteggi** — cronologia per area per diagnosticare le debolezze e applicare esercizi mirati.
- **Supporto per tre host** — Claude Code(slash command), Codex, agy(workflow basati su script).

## Installazione

Tutti e tre gli host si installano dallo stesso marketplace di GitHub (epicsagas/toefl-prep).

### Claude Code

```bash
claude plugin marketplace add epicsagas/toefl-prep
claude plugin install epicsagas@toefl-prep
```

### Codex

```bash
codex plugin marketplace add epicsagas/toefl-prep
codex plugin add epicsagas@toefl-prep
```

### agy (Antigravity CLI)

```bash
agy plugin install https://github.com/epicsagas/toefl-prep
agy plugin enable toefl-prep
```

> I prerequisiti (PyYAML per il percorso di studio) non vengono installati automaticamente da Codex/agy (nessun hook SessionStart). Esegui `pip3 install pyyaml` prima del primo utilizzo, se sono necessarie le funzionalità del percorso di studio.

## Requisiti preliminari

```bash
# 1. Ollama (correzione/generazione domande tramite LLM)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # Consigliato (migliore correzione in inglese su M-series 16GB)
# Fallback: ollama pull llama3.1:8b

# 2. whisper.cpp (STT per lo speaking)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (normalizzazione audio, consigliato) + PyYAML (percorso di studio)
brew install ffmpeg
pip3 install pyyaml
```

Gli script selezionano automaticamente il modello (priorità a qwen2.5:7b, fallback llama3.1:8b) e mostrano le istruzioni di installazione se un modello risulta mancante.

## Configurazione del percorso di studio

Al primo avvio, il piano viene generato dal template:

```bash
DATA="${TOEFL_DATA_DIR:-$HOME/Documents/toefl-prep}"
cp skills/toefl/schedule.example.yaml "$DATA/schedule.yaml"
# Modifica: start_date, test_window_*, study_days, hours, target_score, weeks
```

Tutti i valori mostrati nel percorso provengono da `schedule.yaml`.

## Utilizzo (Claude Code)

| Comando | Descrizione |
|---------|-------------|
| `/toefl-roadmap` | Obiettivi della settimana + piano di oggi |
| `/toefl-practice [area] [n]` | Genera domande in formato TOEFL |
| `/toefl-grade [area] [file]` | Corregge risposta/registrazione → accumula in SCORES.md |
| `/toefl-drill [debolezza]` | Ripetizione focalizzata sulle aree deboli |
| `/toefl-status` | Avanzamento + andamento dei punteggi + scarto rispetto all'obiettivo |

> Codex/agy richiamano gli stessi script direttamente, seguendo la mappatura intenzione→azione di SKILL.md.

## Limiti onesti

- **Pronuncia nello speaking**: la qualità della trascrizione di whisper.cpp è solo un indicatore *indiretto* della pronuncia. Accento e intonazione reali non vengono valutati.
- **Correzione tramite LLM locale**: i modelli 7–8B presentano una differenza assoluta rispetto alla correzione ufficiale ETS. Sono stime per esercitazione — convalida il tuo livello di base con i TPO.
- **Riproduzione del listening**: la riproduzione audio è responsabilità dell'utente. Il plugin fornisce solo script e domande.

## Contribuire

Vedi [CONTRIBUTING.md](../../CONTRIBUTING.md). Il `README.md` in inglese è la fonte di verità — le traduzioni non possono precederlo.

## Licenza

MIT
