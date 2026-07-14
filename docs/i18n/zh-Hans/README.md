[English](../../README.md) | [한국어](../ko/README.md) | [日本語](../ja/README.md) | **[简体中文](README.md)** | [繁體中文](../zh-Hant/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Deutsch](../de/README.md) | [Português](../pt/README.md) | [Русский](../ru/README.md) | [Italiano](../it/README.md)

> 本文是 [README.md](../../README.md) 的翻译。英文版本为权威原始来源，且可能更为更新。

# toefl-prep

> TOEFL iBT 学习插件 — **Claude Code · Codex · agy(Antigravity CLI)**。使用 **本地 LLM(Ollama) + whisper.cpp** 完全离线评估 Reading/Listening/Speaking/Writing 四个领域。

从题目生成到评分、分数追踪，全部在自己的电脑上完成，无需外部 API。学习路线图由 **用户自定义** — 学习周期、星期、时间段、每周目标均可自行设置。

## 特色

- **完全离线评分** — 仅使用本地模型。无 API 费用/延迟，数据不会离开设备。
- **分领域评估路径**:
  - Reading/Listening — LLM 答案校验 + 文章/脚本引用依据
  - Writing — 直接使用 ETS 0–5 分评分标准 (内容/组织/语言/机械性)
  - Speaking — whisper.cpp 转写 → LLM 评分标准 (传达/语言使用/主题展开)
- **自定义路线图** — `schedule.yaml` 决定日期、星期、时间、每周目标。无硬编码值。
- **分数追踪** — 按领域历史记录进行弱点诊断和集中训练。
- **支持三大宿主** — Claude Code(斜杠命令)、Codex、agy(脚本驱动工作流)。

## 安装

### Claude Code

```bash
/plugin marketplace add epicsagas/toefl-prep
/plugin install toefl-prep@epicsagas
```

### Codex / agy

克隆到各宿主的插件目录:

```bash
git clone https://github.com/epicsagas/toefl-prep
# Codex: ~/.codex/plugins/toefl-prep -> clone
# agy:   ~/.agy/plugins/toefl-prep -> clone
```

## 前置条件

```bash
# 1. Ollama (LLM 评分/题目生成)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # 推荐 (M 系列 16GB 上英语评分效果最佳)
# 备选: ollama pull llama3.1:8b

# 2. whisper.cpp (口语 STT)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (音频归一化，推荐) + PyYAML (路线图)
brew install ffmpeg
pip3 install pyyaml
```

脚本会自动选择模型(优先 qwen2.5:7b，回退 llama3.1:8b)，未安装时输出安装指引。

## 学习计划设置

首次运行时从模板生成计划:

```bash
VAULT="${TOEFL_VAULT_DIR:-$HOME/workspace/SecondBrain/01-Projects/toefl}"
cp skills/toefl/schedule.example.yaml "$VAULT/schedule.yaml"
# 编辑: start_date, test_window_*, study_days, hours, target_score, weeks
```

路线图中显示的所有值均来自 `schedule.yaml`。

## 使用方法 (Claude Code)

| 命令 | 说明 |
|------|------|
| `/toefl-roadmap` | 本周目标 + 今日计划 |
| `/toefl-practice [领域] [n]` | 生成 TOEFL 题型练习 |
| `/toefl-grade [领域] [文件]` | 评分答案/录音 → 累积至 SCORES.md |
| `/toefl-drill [弱点]` | 薄弱领域集中重复训练 |
| `/toefl-status` | 进度 + 分数趋势 + 与目标的差距 |

> Codex/agy 遵循 SKILL.md 的意图→动作映射，直接调用相同脚本。

## 诚实的局限

- **口语发音**: whisper.cpp 的转写质量仅是发音的 *间接* 指标。实际的口音/重音不予评估。
- **本地 LLM 评分**: 7–8B 模型与 ETS 官方评分存在绝对差异。仅为练习用估计值 — 实战基线请通过 TPO 验证。
- **听力播放**: 音频播放由用户负责。插件仅提供脚本+题目。

## 贡献

参见 [CONTRIBUTING.md](../../CONTRIBUTING.md)。英文版 `README.md` 为真实来源 — 翻译不会先于英文版。

## 许可证

MIT
