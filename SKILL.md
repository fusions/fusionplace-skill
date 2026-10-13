---
name: fusionplace
description: |
  fusion_place（フュージョンプレイス、fusionplace、フュージョン）に関する依頼で使用する。製品の使い方・エラー・トラブル・設計相談・バージョンアップ・契約手続きなどの質問への回答、Excel-Link シートの作成・改修・解読、アプリケーション定義ファイル（.apd）からの設計内容の調査、fusion_place の MCP ツールを用いたフォーム経由のデータ取得・分析（フォーム名や POV（データの視点）を指定した集計表・予算表・PL表の作成など）に対応する。
  製品名がなくても、fusion_place 固有の用語や物が出てきたら使用する：業務責任単位、元帳、元帳版、元帳マスク、提出パッケージ、提出ルート、業務プロセス、増減科目、メンバリスト、fusion_place 実行環境（FRE）、FMC、.apd ファイル、Excel-Link、データの視点（POV）、_FUSIONPLACE_ で始まる名前定義を持つ Excel シート。
  英語の質問も対象：Participant, Ledger, Ledger Edition, Change Table, Submission Route, Excel-Link, fusion_place Runtime Environment (FRE)。
  「マネージャ」「ブラウザ」「コントリビュータ」「ディメンション」「フォーム」「fp」などの一般的な語は、fusion_place のクライアントや機能を指す文脈の場合にのみ対象とする。
  他製品（SAP、Oracle、Tableau、Power BI、Salesforce 等）や一般的な Excel・Web ブラウザ・多次元DBの話題で、fusion_place と関係しないものには使用しない。
license: MIT
compatibility: Requires network access to docs-search.fusionplace.net and docs.fusionplace.net (fallback web search/fetch also uses fusions.co.jp and fusionplace.net). Python is required for Excel-Link generation (openpyxl) and .apd parsing (standard library). Form-based data access (data_access) additionally requires a connected and authorized fusion_place MCP server for the user's environment.
metadata:
  author: fusions corporation
  version: "202610XX"
---

# fusion_place スキル（目次・ユースケース振り分け）

このファイルは、fusion_place に関する複数の支援ユースケースをまとめた**目次（ルーター）**です。
このファイル自体には各ユースケースの詳細ルールを書かない。ユーザーの依頼内容を判定し、該当するユースケースフォルダの起点ガイドを読み込んで、以降はそのガイドの指示に従うこと（複数の起点ガイドを読み込んだ場合は、下記「振り分けの手順」3に従う）。

## ユースケース一覧と振り分け表

| ユースケース|（フォルダ） | こんな依頼のとき | 読み込む起点ガイド |
|---|---|---|---|
| ライブラリアン|`knowledge/`| 使い方・エラー・トラブル・設計相談・契約・バージョンアップなど、fusion_place に関する質問全般（下記3行の「作成・解読・調査・データ取得」系の依頼を除く） | `knowledge/librarian_guide.md` |
| Excel-Link 作成・解読支援 |`excel_link/`| Excel-Link シート（.xlsx）の**作成・設定・レイアウト・解読** | `excel_link/excel_link_guide.md` |
| .apd 読解支援 |`app_definition/`| アプリケーション定義ファイル `.apd` が入手可能な場合の、アプリケーション設計内容（ディメンション構成・メンバ・元帳・期間・シナリオ・フォーム・権限など）の調査 | `app_definition/apd_reading_guide.md` |
| データアクセス・分析支援 |`data_access/`| MCP ツールでアプリケーションに接続し、フォーム経由で**実データを取得・分析**する依頼（フォーム名・業務責任単位・POV を指定した集計表／予算表／PL表の作成、データ取得、POV の確認、CSV 出力など） | `data_access/data_access_guide.md` |

> Excel-Link 作成・解読支援と .apd 読解支援は密接に関連するため、両方に該当する依頼では両方の起点ガイドを読み込む（下記「振り分けの手順」1を参照）。

## 振り分けの手順

1. **判定する**：ユーザーの依頼が上表のどのユースケースに該当するか判定する。
   - キーワードだけでなく「〜を作りたい／設定したい」（作成・生成依頼）なのか、「〜について教えて／なぜ〜」（質問・調査依頼）なのかで見分ける。例えば同じ「Excel-Link」でも、シートを新規作成・改修したいなら `excel_link/`、Excel-Link の一般的な使い方・仕様を尋ねているだけなら `knowledge/`。
   - 同じ「フォーム」でも、フォームの機能・設定方法・仕様を尋ねているなら `knowledge/`、fusion_place へのログインを要求し、特定のフォームを指定して**実データの取得・集計**を依頼しているなら `data_access/`。
   - ログインを要求しているなら、fusion_place の MCP ツールでアプリケーションに接続し、フォーム経由でデータを分析するので `data_access/`。
   - **複数のユースケースにまたがる依頼**は、必要な起点ガイドを順番に読み込んでよい。例：「.apd の内容を踏まえて Excel-Link シートを作りたい」→ まず `app_definition/apd_reading_guide.md` でディメンション構成等を把握し、続けて `excel_link/excel_link_guide.md` でシートを設計・生成する。
   - **判定に迷う場合**は、既定でライブラリアン（`knowledge/`）として扱う。
2. **読み込む**：該当する起点ガイドを `view` 等で全文読み込む（例：`excel_link/excel_link_guide.md`）。
3. **従う**：以降はその起点ガイドの手順・禁止事項・回答スタイルに従う。本ファイル（目次）の記載より、読み込んだガイドの記載を優先する。
   - **複数の起点ガイドを読み込んだ場合**は、各ガイドをそれぞれの担当範囲に適用する。依頼の最終成果物（例：Excel-Link シート、集計表、質問への回答）に対応するガイドを**主ガイド**とし、成果物の形式・手順・回答スタイルは主ガイドに従う。その他のガイドは、前提情報の取得（例：.apd からディメンション構成を読み取る）の範囲でのみ従う。
   - ガイド間で指示が食い違う場合は、主ガイドの記載を優先する。
4. **補助ファイルの扱い**：各フォルダ内の用語集・製品概要・回答パターン・API仕様・サンプルファイル等は、本ファイルからは読み込まない。起点ガイドが必要と判断したタイミングで、ガイド自身の指示に従って読み込む。

> スキルの保守・拡張ルールとフォルダ構成は `CONTRIBUTING.md` に記載している（保守担当者向け。回答・タスク実行時には読み込まない）。
