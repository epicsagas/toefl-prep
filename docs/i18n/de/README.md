[English](../../README.md) | [한국어](../ko/README.md) | [日本語](../ja/README.md) | [简体中文](../zh-Hans/README.md) | [繁體中文](../zh-Hant/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | **[Deutsch](README.md)** | [Português](../pt/README.md) | [Русский](../ru/README.md) | [Italiano](../it/README.md)

> Dies ist eine Übersetzung von [README.md](../../README.md). Die englische Version ist die maßgebliche Quelle und kann aktueller sein.

# toefl-prep

> TOEFL-iBT-Lern-Plugin — **Claude Code · Codex · agy(Antigravity CLI)**. Bewertet die 4 Bereiche Reading/Listening/Speaking/Writing vollständig offline mit **lokalem LLM(Ollama) + whisper.cpp**.

Von der Fragenerstellung über die Bewertung bis zur Fortschrittsverfolgung wird alles auf Ihrem eigenen Rechner ohne externe API verarbeitet. Der Lernfahrplan ist **benutzerdefiniert** — Sie legen Lernzeitraum, Wochentage, Uhrzeiten und wöchentliche Ziele selbst fest.

## Funktionen

- **100 % Offline-Bewertung** — verwendet ausschließlich lokale Modelle. Keine API-Kosten/-Latenz und Daten verlassen nie Ihr Gerät.
- **Bewertungspfade pro Bereich**:
  - Reading/Listening — LLM-Antwortprüfung + zitierte Belege aus Passage/Transkript
  - Writing — direkte Bewertung mit der ETS-Rubrik (0–5 Punkte: Inhalt/Organisation/Sprache/Mechanik)
  - Speaking — Transkription mit whisper.cpp → LLM-Rubrik (Delivery/Sprachgebrauch/Themenentwicklung)
- **Benutzerdefinierter Fahrplan** — `schedule.yaml` legt Daten, Tage, Uhrzeiten und Ziele pro Woche fest. Keine fest codierten Werte.
- **Score-Tracking** — Verlauf pro Bereich zur Diagnose von Schwächen und gezieltem Üben.
- **3 Hosts unterstützt** — Claude Code (Slash-Befehle), Codex, agy (skriptgesteuerter Workflow).

## Installation

### Claude Code

```bash
/plugin marketplace add epicsagas/toefl-prep
/plugin install toefl-prep@epicsagas
```

### Codex / agy

In das Plugin-Verzeichnis des jeweiligen Hosts klonen:

```bash
git clone https://github.com/epicsagas/toefl-prep
# Codex: ~/.codex/plugins/toefl-prep -> clone
# agy:   ~/.agy/plugins/toefl-prep -> clone
```

## Voraussetzungen

```bash
# 1. Ollama (LLM-Bewertung/Fragenerstellung)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # Empfohlen (beste englische Bewertung auf M-Series 16GB)
# Fallback: ollama pull llama3.1:8b

# 2. whisper.cpp (STT für Speaking)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (Audio-Normalisierung, empfohlen) + PyYAML (Fahrplan)
brew install ffmpeg
pip3 install pyyaml
```

Die Skripte wählen das Modell automatisch (bevorzugen qwen2.5:7b, Fallback llama3.1:8b) und zeigen Installationshinweise an, falls es fehlt.

## Lernplan einrichten

Beim ersten Ausführen wird ein Plan aus der Vorlage erstellt:

```bash
VAULT="${TOEFL_VAULT_DIR:-$HOME/workspace/SecondBrain/01-Projects/toefl}"
cp skills/toefl/schedule.example.yaml "$VAULT/schedule.yaml"
# Bearbeiten: start_date, test_window_*, study_days, hours, target_score, weeks
```

Alle im Fahrplan angezeigten Werte stammen aus `schedule.yaml`.

## Verwendung (Claude Code)

| Befehl | Beschreibung |
|--------|--------------|
| `/toefl-roadmap` | Wochenziel + Tagesplan |
| `/toefl-practice [Bereich] [n]` | Erstellt TOEFL-typische Fragen |
| `/toefl-grade [Bereich] [Datei]` | Bewertet Antworten/Aufnahmen → sammelt in SCORES.md |
| `/toefl-drill [Schwäche]` | Intensivübung für schwache Bereiche |
| `/toefl-status` | Fortschritt + Score-Verlauf + Abstand zum Ziel |

> Codex/agy folgen der Intention→Action-Zuordnung aus SKILL.md und rufen direkt dieselben Skripte auf.

## Ehrliche Grenzen

- **Sprech-Aussprache**: Die Transkriptionsqualität von whisper.cpp ist ein *indirekter* Indikator für die Aussprache. Tatsischer Akzent/Betonung wird nicht bewertet.
- **Lokale LLM-Bewertung**: 7–8B-Modelle weisen absolute Unterschiede zur offiziellen ETS-Bewertung auf. Es handelt sich um Übungs-Schätzwerte — validieren Sie Ihre tatsächliche Baseline mit TPO.
- **Listening-Wiedergabe**: Die Audiowiedergabe obliegt dem Benutzer. Das Plugin stellt nur Transkript und Fragen bereit.

## Beitragen

Siehe [CONTRIBUTING.md](../../CONTRIBUTING.md). Die englische `README.md` ist die Single Source of Truth — Übersetzungen können der englischen Version nicht vorausgreifen.

## Lizenz

MIT
