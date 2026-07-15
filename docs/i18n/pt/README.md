[English](../../README.md) | [한국어](../ko/README.md) | [日本語](../ja/README.md) | [简体中文](../zh-Hans/README.md) | [繁體中文](../zh-Hant/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Deutsch](../de/README.md) | **[Português](README.md)** | [Русский](../ru/README.md) | [Italiano](../it/README.md)

> Esta é uma tradução do [README.md](../../README.md). A versão em inglês é a fonte autoritativa e pode estar mais atualizada.

# toefl-prep

> Plugin de estudo para o TOEFL iBT — **Claude Code · Codex · agy(Antigravity CLI)**. Avalia completamente offline as 4 áreas de Reading/Listening/Speaking/Writing com **LLM local(Ollama) + whisper.cpp**.

Da geração de questões até a correção e o acompanhamento de pontuação, tudo é processado na sua máquina, sem nenhuma API externa. A trilha de estudos é **personalizada pelo usuário** — você define a duração, os dias da semana, os horários e os objetivos semanais.

## Recursos

- **Correção totalmente offline** — usa apenas modelos locais. Sem custos de API ou latência, e seus dados nunca saem do dispositivo.
- **Avaliação por área**:
  - Reading/Listening — revisão de respostas pelo LLM + evidências citadas do texto/script
  - Writing — correção direta pela rubrica ETS de 0–5 pontos (conteúdo/organização/linguagem/mecânica)
  - Speaking — transcrição por whisper.cpp → rubrica LLM (entrega/uso da linguagem/desenvolvimento do tema)
- **Trilha personalizada** — o `schedule.yaml` define datas, dias da semana, horários e objetivos por semana. Não há valores fixos no código.
- **Acompanhamento de pontuação** — histórico por área para diagnosticar pontos fracos e aplicar exercícios focados.
- **Suporte a três hosts** — Claude Code(comandos de barra), Codex, agy(fluxos de trabalho acionados por script).

## Instalação

Todos os três hosts instalam a partir do mesmo marketplace do GitHub (epicsagas/toefl-prep).

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

> Os pré-requisitos (PyYAML para a trilha de estudos) não são instalados automaticamente pelo Codex/agy (sem hook de SessionStart). Execute `pip3 install pyyaml` antes do primeiro uso, caso necessite dos recursos da trilha de estudos.

## Pré-requisitos

```bash
# 1. Ollama (correção/geração de questões pelo LLM)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # Recomendado (melhor correção em inglês em M-series 16GB)
# Fallback: ollama pull llama3.1:8b

# 2. whisper.cpp (STT de speaking)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (normalização de áudio, recomendado) + PyYAML (trilha de estudos)
brew install ffmpeg
pip3 install pyyaml
```

Os scripts selecionam o modelo automaticamente (priorizando qwen2.5:7b, com fallback para llama3.1:8b) e exibem instruções de instalação caso algum esteja ausente.

## Configuração da trilha de estudos

Na primeira execução, o plano é gerado a partir do template:

```bash
DATA="${TOEFL_DATA_DIR:-$HOME/Documents/toefl-prep}"
cp skills/toefl/schedule.example.yaml "$DATA/schedule.yaml"
# Edite: start_date, test_window_*, study_days, hours, target_score, weeks
```

Todos os valores exibidos na trilha vêm do `schedule.yaml`.

## Uso (Claude Code)

| Comando | Descrição |
|---------|-----------|
| `/toefl-roadmap` | Objetivos da semana + plano de hoje |
| `/toefl-practice [área] [n]` | Gera questões no formato TOEFL |
| `/toefl-grade [área] [arquivo]` | Corrige resposta/gravação → acumula em SCORES.md |
| `/toefl-drill [ponto-fraco]` | Exercícios focados em áreas fracas |
| `/toefl-status` | Progresso + evolução da pontuação + lacuna em relação à meta |

> Codex/agy invocam os mesmos scripts diretamente, seguindo o mapeamento intenção→ação do SKILL.md.

## Limites honestos

- **Pronúncia em speaking**: a qualidade da transcrição do whisper.cpp é um indicador *indireto* da pronúncia. Sotaque e entonação reais não são avaliados.
- **Correção por LLM local**: modelos de 7–8B têm diferença absoluta em relação à correção oficial da ETS. São estimativas para prática — valide sua linha de base com TPOs.
- **Reprodução de listening**: a reprodução do áudio é responsabilidade do usuário. O plugin fornece apenas o script e as questões.

## Contribuindo

Consulte [CONTRIBUTING.md](../../CONTRIBUTING.md). O `README.md` em inglês é a fonte da verdade — as traduções não podem precedê-lo.

## Licença

MIT
