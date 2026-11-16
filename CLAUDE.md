# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## このリポジトリについて

このリポジトリはアプリケーションではなく、**Claude Skill パッケージ**である。ここで定義されている
`fusionplace-librarian` は、fusions corporation の経営管理クラウドサービス **fusion_place** に関する
ユーザーの質問に、公式ドキュメントサイトを検索して回答するスキルである。従来型の意味でのビルド手順・
テストランナーは存在しない。「コード」に相当するのは `SKILL.md` の指示内容と、そこから条件付きで
読み込まれる参照ドキュメント群であり、検証手段は `evals/` 配下の評価スクリプトのみである。

## リポジトリ構成

スキル本体（`SKILL.md` と各ユースケースのフォルダ）はすべて **`fusionplace-skill/`** 配下に置かれ、
`package_skill.py` はこのディレクトリを再帰的に zip 化する（`evals/`・`CLAUDE.md` 等は含まれない）。
以下のパスは特記なき限り `fusionplace-skill/` からの相対パス。

- **`SKILL.md`** — スキル定義本体（YAML フロントマター＋指示内容）。フロントマターの `description` は
  ホスト側がこのスキルを**いつ発動させるか**を判断する材料になる（発動キーワードは後述）。本文は
  ライブラリアンのペルソナ、回答方針、および4ステップの手順（質問分析 → ドキュメント検索 → 自己チェック
  → 回答作成）を定義する。
- **`knowledge/`** — ライブラリアン（Q&A回答）用。起点ガイド `librarian_guide.md`（ペルソナ・回答方針・
  回答パターンA/B/C・手順）と、必要時のみ読み込む補助資料：
  - `document_search_api.md` — ドキュメント検索APIの詳細仕様。Step 2（API呼び出し）の直前に読み込む。
  - `ja_en_glossary.md` — JA/EN対応表（`| JA | EN | Status | Note |`）。全文ではなく `grep` で検索する前提。
  - `product_overview.md` — fusion_place の基礎概念の解説。前提知識の説明が不十分なときのみ全文を読み込む。
- **`excel_link/`・`app_definition/`・`data_access/`** — それぞれ Excel-Link 作成・解読支援、.apd 読解支援、
  MCP 経由のフォームデータ分析支援の起点ガイドと補助ファイル。`SKILL.md` が振り分ける。
- **`evals/`** — アプリケーションのテストではなく、このスキル自体の評価資産：
  - `trigger_eval.json` / `run_trigger_eval.py` — `should_trigger: true/false` がラベル付けされたクエリ集で、
    `SKILL.md` のフロントマターが意図通りに発動（または非発動）するかを検証する。ランナーはローカルの
    `claude` バイナリを `--output-format stream-json` で実行し、tool-use ストリームから
    `fusionplace-librarian` という名前の `Skill` 呼び出しを検出する。結果は `trigger_eval_results.json`
    に書き出される。
  - `evals.json` — 回答品質のエンドツーエンド評価。プロンプト・`expected_output` の要約・アサーション
    （`contains_pattern`, `contains_keyword`, `contains_any_keyword`, `min_section_count`）のリストで構成される。
    このリポジトリ内にはこのファイルを実行するランナースクリプトは存在せず、外部の評価ハーネスから
    参照される想定。

## トリガー評価の実行方法

```bash
# ローカルに claude CLI バイナリが必要。スクリプトにハードコードされた既定の Windows パス以外を
# 使う場合は CLAUDE_EXE で上書きする。
CLAUDE_EXE=/path/to/claude python3 evals/run_trigger_eval.py
```

`evals/trigger_eval.json` の各クエリを CLI で非対話的に実行し、実際の発動有無と期待値を突き合わせて、
pass/fail のサマリと各クエリの結果を `evals/trigger_eval_results.json` に書き出す。`SKILL.md` の
フロントマター（発動キーワード・SKIP条件）を編集した後は、既存ケースの発動挙動を壊していないか確認する
ためにこれを実行すること。

## `SKILL.md` を編集する際の注意点

- **発動条件はフロントマターの `description` に集約されている**（本文ではない）。製品名の表記ゆれ
  （fusion_place / fusionplace / フュージョンプレイス / フュージョン / fp）と、製品名がなくても発動すべき
  fusion_place 固有用語（業務責任単位, コントリビュータ, マネージャ, ブラウザ, Excel-Link, 元帳,
  ディメンション, FRE, FMC, 提出パッケージ）、および他製品（SAP, Oracle, Tableau, Power BI, Salesforce 等）
  が主題の場合の明示的な SKIP 条件を、引き続き維持する必要がある。
- **「位置づけ」が回答方針の前提になっている**：ライブラリアンは公式サポートへの一次受付・取次役ではなく、
  独立した製品機能として文書化されている。パターンC（「サポートへお問い合わせください」）を安易な
  万能回避策として復活させないこと。パターンCはバージョン固有仕様・契約条件・既知の不具合・環境固有の
  設定値など「客観的事実の欠落時」に限定される。ユーザー自身の業務・設計相談に対しては、情報の欠如を
  理由にパターンCへ逃げず、【推論による補足】として選択肢を自ら提示することが期待されている。
- **回答パターンA/B/Cのテンプレート**は `SKILL.md` 本体ではなく `knowledge/librarian_guide.md` に
  切り出されている。文言テンプレートを変更する場合は両ファイルが食い違わないようそちらを編集すること。
- **用語の誤用禁止**：`SKILL.md` には、地の文で別の意味に使ってはならない fusion_place 固有用語の対応表
  （シナリオ・元帳・フォーム・メンバ・バージョン・プロセス）がある。用語の追加・変更があれば、この表も
  実際の製品用語と整合させて更新すること。
- **JA/EN対応表の優先順位**：`Status: Added` の項目は既存マニュアル表記への後からの追加・訂正であり、
  同一用語について `Status: Existing` より優先される。`ja_en_glossary.md` を編集する際もこの優先順位を
  崩さないこと。
- 遅延読み込み方式の参照ファイルを新規追加する場合は、既存の補助ファイルの慣習に従うこと：`SKILL.md` 側に
  「どのステップで読み込むか」を明記し、参照ファイル冒頭にも「読み込むタイミング」の一言注記を添える。
