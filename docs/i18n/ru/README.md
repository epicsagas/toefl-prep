[English](../../README.md) | [한국어](../ko/README.md) | [日本語](../ja/README.md) | [简体中文](../zh-Hans/README.md) | [繁體中文](../zh-Hant/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Deutsch](../de/README.md) | [Português](../pt/README.md) | **[Русский](README.md)** | [Italiano](../it/README.md)

> Это перевод [README.md](../../README.md). Английская версия является авторитетным источником и может быть более актуальной.

# toefl-prep

> Плагин для подготовки к TOEFL iBT — **Claude Code · Codex · agy(Antigravity CLI)**. Полностью офлайн оценивает 4 раздела Reading/Listening/Speaking/Writing с помощью **локального LLM(Ollama) + whisper.cpp**.

От генерации заданий до проверки и отслеживания баллов — всё обрабатывается на вашем компьютере, без внешних API. Учебный маршрут **настраивается пользователем** — вы сами определяете длительность, дни недели, временные слоты и цели по неделям.

## Возможности

- **Полностью офлайн-проверка** — используются только локальные модели. Никаких затрат или задержек API, данные не покидают устройство.
- **Оценка по разделам**:
  - Reading/Listening — проверка ответов LLM + обоснования со ссылками на текст/скрипт
  - Writing — прямая оценка по рубрике ETS 0–5 баллов (содержание/организация/язык/механика)
  - Speaking — транскрипция whisper.cpp → рубрика LLM (подача/использование языка/раскрытие темы)
- **Настраиваемый маршрут** — `schedule.yaml` определяет даты, дни недели, время и цели по неделям. Никаких захардкоженных значений.
- **Отслеживание баллов** — история по разделам для диагностики слабых мест и целевых тренировок.
- **Поддержка трёх хостов** — Claude Code(slash-команды), Codex, agy(рабочие процессы на скриптах).

## Установка

Все три хоста устанавливаются из одного и того же маркетплейса GitHub (epicsagas/toefl-prep).

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
agy plugin install epicsagas/toefl-prep
agy plugin enable toefl-prep
```

> Предварительные зависимости (PyYAML для учебного маршрута) не устанавливаются автоматически в Codex/agy (хук SessionStart отсутствует). Выполните `pip3 install pyyaml` перед первым использованием, если нужны функции учебного маршрута.

## Системные требования

```bash
# 1. Ollama (проверка/генерация заданий LLM)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # Рекомендуется (лучшая проверка английского на M-series 16GB)
# Резерв: ollama pull llama3.1:8b

# 2. whisper.cpp (STT для speaking)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (нормализация звука, рекомендуется) + PyYAML (учебный маршрут)
brew install ffmpeg
pip3 install pyyaml
```

Скрипты автоматически выбирают модель (приоритет qwen2.5:7b, резерв llama3.1:8b) и выводят инструкции по установке, если модель не найдена.

## Настройка учебного расписания

При первом запуске план создаётся из шаблона:

```bash
DATA="${TOEFL_DATA_DIR:-$HOME/Documents/toefl-prep}"
cp skills/toefl/schedule.example.yaml "$DATA/schedule.yaml"
# Отредактируйте: start_date, test_window_*, study_days, hours, target_score, weeks
```

Все значения, отображаемые в маршруте, берутся из `schedule.yaml`.

## Использование (Claude Code)

| Команда | Описание |
|---------|----------|
| `/toefl-roadmap` | Цели недели + план на сегодня |
| `/toefl-practice [раздел] [n]` | Генерация заданий в формате TOEFL |
| `/toefl-grade [раздел] [файл]` | Проверка ответа/записи → накопление в SCORES.md |
| `/toefl-drill [слабое-место]` | Циклы повторения по слабым разделам |
| `/toefl-status` | Прогресс + динамика баллов + отставание от цели |

> Codex/agy вызывают те же скрипты напрямую, следуя отображению намерение→действие из SKILL.md.

## Честные ограничения

- **Произношение в speaking**: качество транскрипции whisper.cpp — лишь *косвенный* показатель произношения. Реальные акцент и ударение не оцениваются.
- **Проверка локальным LLM**: модели 7–8B принципиально отличаются от официальной оценки ETS. Это ориентировочные оценки для практики — базу для реального экзамена проверяйте через TPO.
- **Воспроизведение listening**: воспроизведение аудио — ответственность пользователя. Плагин предоставляет только скрипт и задания.

## Участие

См. [CONTRIBUTING.md](../../CONTRIBUTING.md). Английский `README.md` является источником истины — переводы не могут его опережать.

## Лицензия

MIT
