[English](../../README.md) | [한국어](../ko/README.md) | [日本語](../ja/README.md) | [简体中文](../zh-Hans/README.md) | [繁體中文](../zh-Hant/README.md) | [Español](../es/README.md) | **[Français](README.md)** | [Deutsch](../de/README.md) | [Português](../pt/README.md) | [Русский](../ru/README.md) | [Italiano](../it/README.md)

> Ceci est une traduction de [README.md](../../README.md). La version anglaise est la source faisant autorité et peut être plus à jour.

# toefl-prep

> Plugin d'étude pour le TOEFL iBT — **Claude Code · Codex · agy(Antigravity CLI)**. Évalue entièrement hors ligne les 4 domaines Reading/Listening/Speaking/Writing avec un **LLM local(Ollama) + whisper.cpp**.

De la génération de questions à la notation et au suivi des scores, tout est traité sur votre propre machine sans aucune API externe. Le parcours d'étude est **personnalisé par l'utilisateur** — vous définissez vous-même la durée, les jours, les créneaux horaires et les objectifs hebdomadaires.

## Fonctionnalités

- **Notation 100 % hors ligne** — utilise uniquement des modèles locaux. Aucun coût ni latence d'API, et vos données ne quittent jamais votre appareil.
- **Parcours d'évaluation par domaine** :
  - Reading/Listening — vérification des réponses par LLM + preuve citée du passage/script
  - Writing — notation directe avec la grille ETS de 0–5 points (contenu/organisation/langue/mécanique)
  - Speaking — transcription par whisper.cpp → grille LLM (delivery/utilisation de la langue/développement du sujet)
- **Parcours personnalisé** — `schedule.yaml` définit les dates, les jours, les horaires et les objectifs par semaine. Aucune valeur codée en dur.
- **Suivi des scores** — historique par domaine pour diagnostiquer les faiblesses et appliquer des exercices ciblés.
- **Prise en charge de 3 hôtes** — Claude Code (commandes slash), Codex, agy (flux de travail piloté par scripts).

## Installation

### Claude Code

```bash
/plugin marketplace add epicsagas/toefl-prep
/plugin install toefl-prep@epicsagas
```

### Codex / agy

Clonez dans le répertoire de plugins de chaque hôte :

```bash
git clone https://github.com/epicsagas/toefl-prep
# Codex : ~/.codex/plugins/toefl-prep -> clone
# agy :   ~/.agy/plugins/toefl-prep -> clone
```

## Prérequis

```bash
# 1. Ollama (notation/génération de questions par LLM)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # Recommandé (meilleure notation en anglais sur M-series 16GB)
# Alternative : ollama pull llama3.1:8b

# 2. whisper.cpp (STT pour Speaking)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (normalisation audio, recommandé) + PyYAML (parcours)
brew install ffmpeg
pip3 install pyyaml
```

Les scripts sélectionnent automatiquement le modèle (priorité à qwen2.5:7b, repli sur llama3.1:8b) et affichent des instructions d'installation s'ils sont absents.

## Configuration du plan d'étude

À la première exécution, un plan est généré à partir du modèle :

```bash
VAULT="${TOEFL_VAULT_DIR:-$HOME/workspace/SecondBrain/01-Projects/toefl}"
cp skills/toefl/schedule.example.yaml "$VAULT/schedule.yaml"
# Éditer : start_date, test_window_*, study_days, hours, target_score, weeks
```

Toutes les valeurs affichées dans le parcours proviennent de `schedule.yaml`.

## Utilisation (Claude Code)

| Commande | Description |
|----------|-------------|
| `/toefl-roadmap` | Objectif de la semaine + plan du jour |
| `/toefl-practice [domaine] [n]` | Génère des questions type TOEFL |
| `/toefl-grade [domaine] [fichier]` | Note réponses/enregistrements → cumule dans SCORES.md |
| `/toefl-drill [faiblesse]` | Exercices intensifs sur les domaines faibles |
| `/toefl-status` | Progression + évolution des scores + écart par rapport à l'objectif |

> Codex/agy suivent le mappage intention→action de SKILL.md et appellent directement les mêmes scripts.

## Limites honnêtes

- **Prononciation en Speaking** : la qualité de transcription de whisper.cpp est un indicateur *indirect* de la prononciation. L'accent/la prosodie réels ne sont pas évalués.
- **Notation par LLM local** : les modèles de 7–8B présentent un écart absolu par rapport à la notation officielle d'ETS. Ce sont des estimations d'entraînement — validez votre ligne de base réelle avec les TPO.
- **Lecture de Listening** : la lecture audio relève de la responsabilité de l'utilisateur. Le plugin fournit uniquement le script et les questions.

## Contribuer

Consultez [CONTRIBUTING.md](../../CONTRIBUTING.md). Le `README.md` anglais est la source de vérité — les traductions ne peuvent pas devancer la version anglaise.

## Licence

MIT
