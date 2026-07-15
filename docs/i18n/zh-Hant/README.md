[English](../../README.md) | [한국어](../ko/README.md) | [日本語](../ja/README.md) | [简体中文](../zh-Hans/README.md) | **[繁體中文](README.md)** | [Español](../es/README.md) | [Français](../fr/README.md) | [Deutsch](../de/README.md) | [Português](../pt/README.md) | [Русский](../ru/README.md) | [Italiano](../it/README.md)

> 本文是 [README.md](../../README.md) 的翻譯。英文版本為權威原始來源，且可能更為更新。

# toefl-prep

> TOEFL iBT 學習插件 — **Claude Code · Codex · agy(Antigravity CLI)**。使用 **本地 LLM(Ollama) + whisper.cpp** 完全離線評估 Reading/Listening/Speaking/Writing 四個領域。

從題目生成到評分、分數追蹤，全部在自己的電腦上完成，無需外部 API。學習路線圖由 **使用者自訂** — 學習週期、星期、時段、每週目標均可自行設定。

## 特色

- **完全離線評分** — 僅使用本地模型。無 API 費用/延遲，資料不會離開裝置。
- **分領域評估路徑**:
  - Reading/Listening — LLM 答案校驗 + 文章/腳本引用依據
  - Writing — 直接使用 ETS 0–5 分評分標準 (內容/組織/語言/機械性)
  - Speaking — whisper.cpp 轉寫 → LLM 評分標準 (傳達/語言使用/主題展開)
- **自訂路線圖** — `schedule.yaml` 決定日期、星期、時間、每週目標。無硬編碼值。
- **分數追蹤** — 按領域歷史記錄進行弱點診斷和集中訓練。
- **支援三大宿主** — Claude Code(斜線命令)、Codex、agy(腳本驅動工作流程)。

## 安裝

三個宿主均從同一個 GitHub 市場 (epicsagas/plugins) 安裝。

### Claude Code

```bash
claude plugin marketplace add epicsagas/plugins
claude plugin install epicsagas@toefl-prep
```

### Codex

```bash
codex plugin marketplace add epicsagas/plugins
codex plugin add epicsagas@toefl-prep
```

### agy (Antigravity CLI)

```bash
agy plugin install https://github.com/epicsagas/toefl-prep
agy plugin enable toefl-prep
```

> 前置條件 (路線圖所需 PyYAML) 不會被 Codex/agy 自動安裝 (無 SessionStart 鉤子)。如需路線圖功能，請在首次使用前執行 `pip3 install pyyaml`。

## 前置條件

```bash
# 1. Ollama (LLM 評分/題目生成)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # 推薦 (M 系列 16GB 上英語評分效果最佳)
# 備選: ollama pull llama3.1:8b

# 2. whisper.cpp (口語 STT)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (音訊歸一化，推薦) + PyYAML (路線圖)
brew install ffmpeg
pip3 install pyyaml
```

腳本會自動選擇模型(優先 qwen2.5:7b，回退 llama3.1:8b)，未安裝時輸出安裝指引。

## 學習計畫設定

首次執行時從範本生成計畫:

```bash
DATA="${TOEFL_DATA_DIR:-$HOME/Documents/toefl-prep}"
cp skills/toefl/schedule.example.yaml "$DATA/schedule.yaml"
# 編輯: start_date, test_window_*, study_days, hours, target_score, weeks
```

路線圖中顯示的所有值均來自 `schedule.yaml`。

## 使用方法 (Claude Code)

| 命令 | 說明 |
|------|------|
| `/toefl-roadmap` | 本週目標 + 今日計畫 |
| `/toefl-practice [領域] [n]` | 生成 TOEFL 題型練習 |
| `/toefl-grade [領域] [檔案]` | 評分答案/錄音 → 累積至 SCORES.md |
| `/toefl-drill [弱點]` | 薄弱領域集中重複訓練 |
| `/toefl-status` | 進度 + 分數趨勢 + 與目標的差距 |

> Codex/agy 遵循 SKILL.md 的意圖→動作對映，直接呼叫相同腳本。

## 誠實的限制

- **口語發音**: whisper.cpp 的轉寫品質僅是發音的 *間接* 指標。實際的口音/重音不予評估。
- **本地 LLM 評分**: 7–8B 模型與 ETS 官方評分存在絕對差異。僅為練習用估計值 — 實戰基線請透過 TPO 驗證。
- **聽力播放**: 音訊播放由使用者負責。插件僅提供腳本+題目。

## 貢獻

參見 [CONTRIBUTING.md](../../CONTRIBUTING.md)。英文版 `README.md` 為真實來源 — 翻譯不會先於英文版。

## 授權條款

MIT
