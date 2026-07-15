[English](../../README.md) | [한국어](../ko/README.md) | **[日本語](README.md)** | [简体中文](../zh-Hans/README.md) | [繁體中文](../zh-Hant/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Deutsch](../de/README.md) | [Português](../pt/README.md) | [Русский](../ru/README.md) | [Italiano](../it/README.md)

> これは [README.md](../../README.md) の翻訳です。英語版が権威ある原本であり、より最新の可能性があります。

# toefl-prep

> TOEFL iBT 学習プラグイン — **Claude Code · Codex · agy(Antigravity CLI)**。Reading/Listening/Speaking/Writing の4領域を **ローカル LLM(Ollama) + whisper.cpp** で完全オフライン評価する。

問題生成から採点、スコア追跡まで、外部 API なしで自分のコンピュータ上で全て処理する。学習ロードマップは **ユーザーカスタム** — 学習期間・曜日・時間帯・週ごとの目標を自分で設定する。

## 特徴

- **完全オフライン採点** — ローカルモデルのみ使用。API コスト/レイテンシなく、データが端末外に漏れない。
- **領域別評価パス**:
  - Reading/Listening — LLM による正答検証 + 本文/スクリプトの引用根拠
  - Writing — ETS 0–5点ルーブリック直接採点 (内容/組織/言語/機械性)
  - Speaking — whisper.cpp 書き起こし → LLM ルーブリック (伝達/言語使用/トピック展開)
- **カスタムロードマップ** — `schedule.yaml` が日付・曜日・時間・週ごとの目標を決定。ハードコードされた値はない。
- **スコア追跡** — 領域別履歴で弱点診断・集中ドリル。
- **3ホスト対応** — Claude Code(スラッシュコマンド)、Codex、agy(スクリプト駆動ワークフロー)。

## インストール

3つのホストすべてで同じ GitHub マーケットプレース (epicsagas/toefl-prep) からインストールする。

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

> 前提条件 (ロードマップ用 PyYAML) は Codex/agy では自動インストールされない (SessionStart フックなし)。ロードマップ機能が必要な場合は、初回使用前に `pip3 install pyyaml` を実行すること。

## 前提条件

```bash
# 1. Ollama (LLM 採点/問題生成)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # 推奨 (Mシリーズ16GBで英語採点が最高)
# フォールバック: ollama pull llama3.1:8b

# 2. whisper.cpp (スピーキング STT)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (音声正規化、推奨) + PyYAML (ロードマップ)
brew install ffmpeg
pip3 install pyyaml
```

スクリプトがモデルを自動選択(qwen2.5:7b 優先、llama3.1:8b フォールバック)し、未インストール時はインストール案内を表示する。

## 学習スケジュール設定

初回実行時にテンプレートから計画を生成:

```bash
VAULT="${TOEFL_VAULT_DIR:-$HOME/workspace/SecondBrain/01-Projects/toefl}"
cp skills/toefl/schedule.example.yaml "$VAULT/schedule.yaml"
# 編集: start_date, test_window_*, study_days, hours, target_score, weeks
```

ロードマップに表示される全ての値は `schedule.yaml` から取得される。

## 使い方 (Claude Code)

| コマンド | 説明 |
|------|------|
| `/toefl-roadmap` | 今週の目標 + 今日の計画 |
| `/toefl-practice [領域] [n]` | TOEFL 形式の問題生成 |
| `/toefl-grade [領域] [ファイル]` | 回答/録音を採点 → SCORES.md に蓄積 |
| `/toefl-drill [弱点]` | 苦手領域の集中反復 |
| `/toefl-status` | 進捗 + スコア推移 + 目標に対するギャップ |

> Codex/agy は SKILL.md の意図→アクションマッピングに従い、同じスクリプトを直接呼び出す。

## 正直な限界

- **スピーキング発音**: whisper.cpp の書き起こし品質は発音の *間接的* 指標。実際のアクセント/強勢は未評価。
- **ローカル LLM 採点**: 7–8B モデルは ETS 公認採点との絶対的差異がある。練習用の推定値 — 実戦ベースラインは TPO で検証すること。
- **リスニング再生**: 音声再生はユーザーの責任。プラグインはスクリプト+問題のみ提供。

## コントリビュート

[CONTRIBUTING.md](../../CONTRIBUTING.md) 参照。英語版 `README.md` が真実のソース — 翻訳が英語版を先行することはない。

## ライセンス

MIT
