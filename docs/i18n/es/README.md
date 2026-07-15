[English](../../README.md) | [한국어](../ko/README.md) | [日本語](../ja/README.md) | [简体中文](../zh-Hans/README.md) | [繁體中文](../zh-Hant/README.md) | **[Español](README.md)** | [Français](../fr/README.md) | [Deutsch](../de/README.md) | [Português](../pt/README.md) | [Русский](../ru/README.md) | [Italiano](../it/README.md)

> Esta es una traducción de [README.md](../../README.md). La versión en inglés es la fuente autorizada y puede estar más actualizada.

# toefl-prep

> Plugin de estudio para el TOEFL iBT — **Claude Code · Codex · agy(Antigravity CLI)**. Evalúa completamente sin conexión las 4 áreas de Reading/Listening/Speaking/Writing con **LLM local(Ollama) + whisper.cpp**.

Desde la generación de preguntas hasta la calificación y el seguimiento de puntajes, todo se procesa en tu propia máquina sin ninguna API externa. La hoja de ruta de estudio es **personalizada por el usuario** — configuras tú mismo el periodo de estudio, los días de la semana, los horarios y los objetivos semanales.

## Características

- **Calificación 100 % sin conexión** — usa únicamente modelos locales. Sin costos ni latencia de API, y los datos nunca salen de tu dispositivo.
- **Rutas de evaluación por área**:
  - Reading/Listening — revisión de respuestas con LLM + evidencia citada del pasaje/script
  - Writing — calificación directa con la rúbrica ETS de 0–5 puntos (contenido/organización/lenguaje/mecánica)
  - Speaking — transcripción con whisper.cpp → rúbrica LLM (entrega/uso del lenguaje/desarrollo del tema)
- **Hoja de ruta personalizada** — `schedule.yaml` define fechas, días, horarios y objetivos por semana. No hay valores predefinidos.
- **Seguimiento de puntajes** — historial por área para diagnosticar puntos débiles y aplicar prácticas intensivas.
- **Compatibilidad con 3 hosts** — Claude Code (comandos con barra), Codex, agy (flujo de trabajo impulsado por scripts).

## Instalación

Los tres hosts se instalan desde el mismo marketplace de GitHub (epicsagas/toefl-prep).

### Claude Code

```bash
claude plugin marketplace add epicsagas/toefl-prep
claude plugin install toefl-prep@epicsagas
```

### Codex

```bash
codex plugin marketplace add epicsagas/toefl-prep
codex plugin add toefl-prep@epicsagas
```

### agy (Antigravity CLI)

```bash
agy plugin install https://github.com/epicsagas/toefl-prep
agy plugin enable toefl-prep
```

> Los requisitos previos (PyYAML para la hoja de ruta) no se instalan automáticamente con Codex/agy (no hay hook SessionStart). Ejecuta `pip3 install pyyaml` antes del primer uso si necesitas las funciones de la hoja de ruta.

## Requisitos previos

```bash
# 1. Ollama (calificación/generación de preguntas con LLM)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # Recomendado (mejor calificación en inglés en M-series 16GB)
# Alternativa: ollama pull llama3.1:8b

# 2. whisper.cpp (STT para Speaking)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (normalización de audio, recomendado) + PyYAML (hoja de ruta)
brew install ffmpeg
pip3 install pyyaml
```

Los scripts seleccionan el modelo automáticamente (priorizan qwen2.5:7b, con respaldo en llama3.1:8b) y muestran instrucciones de instalación si no están presentes.

## Configuración del plan de estudio

En la primera ejecución se genera un plan a partir de la plantilla:

```bash
DATA="${TOEFL_DATA_DIR:-$HOME/Documents/toefl-prep}"
cp skills/toefl/schedule.example.yaml "$DATA/schedule.yaml"
# Editar: start_date, test_window_*, study_days, hours, target_score, weeks
```

Todos los valores mostrados en la hoja de ruta provienen de `schedule.yaml`.

## Uso (Claude Code)

| Comando | Descripción |
|---------|-------------|
| `/toefl-roadmap` | Objetivo de esta semana + plan de hoy |
| `/toefl-practice [área] [n]` | Genera preguntas tipo TOEFL |
| `/toefl-grade [área] [archivo]` | Califica respuestas/grabaciones → acumula en SCORES.md |
| `/toefl-drill [debilidad]` | Práctica intensiva en áreas débiles |
| `/toefl-status` | Progreso + evolución de puntajes + brecha frente al objetivo |

> Codex/agy siguen el mapeo intención→acción de SKILL.md e invocan directamente los mismos scripts.

## Limitaciones honestas

- **Pronunciación en Speaking**: la calidad de transcripción de whisper.cpp es un indicador *indirecto* de la pronunciación. No evalúa acento/énfasis reales.
- **Calificación con LLM local**: los modelos de 7–8B tienen una diferencia absoluta frente a la calificación oficial de ETS. Son estimaciones para práctica — valida tu línea base real con TPO.
- **Reproducción de Listening**: la reproducción de audio es responsabilidad del usuario. El plugin solo proporciona el script y las preguntas.

## Contribuir

Consulta [CONTRIBUTING.md](../../CONTRIBUTING.md). El `README.md` en inglés es la fuente de verdad — las traducciones no pueden adelantarse a la versión en inglés.

## Licencia

MIT
