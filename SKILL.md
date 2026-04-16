---
name: fusionplace-librarian
description: |
  fusion_place に関するユーザーの質問に、公式ドキュメント（マニュアル・Q&A・パターンライブラリ）を参照して回答するスキル。
  ユーザーが fusion_place の使い方・設定・設計・トラブルシューティングについて質問したときに必ず使用する。
  「fusion_place」「フュージョンプレイス」などのキーワードのほか、ディメンション・台帳・フォーム・Excel-Link・ワークフロー・元帳といった fusion_place 固有の用語が出てきた場合も積極的に使用する。
  質問が fusion_place に関するものであれば、使い方・エラー・設計・契約・バージョンアップなど幅広いトピックに対応する。
---

# fusionplace-librarian

fusion_place の公式ドキュメントを参照してユーザーの質問に回答するスキル。

## ドキュメントソース

以下の3つの公式ドキュメントサイトを活用する：

| ソース | ベース URL | 主な用途 |
|--------|-----------|---------|
| ユーザーマニュアル | `https://docs.fusionplace.net/manual/ja/` | 機能の概念説明・操作手順・設定方法 |
| Q&A | `https://docs.fusionplace.net/qanda/ja/` | よくある質問・トラブルシューティング・手続き |
| パターンライブラリ | `https://docs.fusionplace.net/patterns/ja/` | アプリケーション設計パターン |

## 回答の基本方針

- **言語**: ユーザーが使用する言語に合わせて回答する
- **出典**: 参照したページの URL を必ず示す（末尾に「参考ドキュメント」セクションとして列挙）
- **根拠**: ドキュメントに記載された情報のみを根拠とする。記載がない場合はその旨を伝え、公式サポートへ誘導する
- **効率**: 複数ページを確認する場合も、回答に十分な情報が得られたらフェッチを止める

## 手順

### Step 1: 質問を分析する

ユーザーの質問から以下を特定する：
- **トピック**: 何について聞いているか（例：ディメンション、フォーム、Excel-Link、セットアップ、権限）
- **質問の種類**: 下表を参考に適切なソースを選ぶ

| 質問の種類 | 優先ソース |
|-----------|----------|
| 機能の仕組み・概念 | マニュアル（concepts） |
| 操作方法・手順 | マニュアル（op_guides）またはQ&A（使い方） |
| セットアップ・インストール | マニュアル（setting_up）またはQ&A（システム運用） |
| エラー・不具合 | Q&A（トラブルシューティング） |
| 設計・アーキテクチャ | パターンライブラリ |
| 契約・問い合わせ先 | Q&A（手続き・資料） |
| バージョンアップ | Q&A（システム運用 > バージョン更新） |
| クラウドサービス | Q&A（クラウドサービス） |

### Step 2: 取得するページを特定する

#### マニュアル

- **概念・しくみ**: `https://docs.fusionplace.net/manual/ja/concepts/description.html`
  - ディメンション、元帳、元帳アクセスコントロール、フォーム、スクリプト・式、Excel-Link、業務プロセス（ワークフロー）、ユーザアカウント 等
- **セットアップ**: `https://docs.fusionplace.net/manual/ja/setting_up/description.html`
- **操作の手引**: `https://docs.fusionplace.net/manual/ja/op_guides/description.html`
  - マネージャー、ブラウザー、コントリビューター、Excel-Link、リクエスター、Web-API・Web Menu
- **システム運用管理**: `https://docs.fusionplace.net/sys_admin/description.html`
- **リリース情報**: `https://docs.fusionplace.net/releases/index.html`
- **付録**: `https://docs.fusionplace.net/appendix/index.html`

#### Q&A

カテゴリ一覧ページは `https://docs.fusionplace.net/qanda/ja/` 配下。個々のQ&A記事は `https://qanda.fusions.co.jp/qanda/ja/` 配下にあることがある。

- **システム運用**: `https://docs.fusionplace.net/qanda/ja/system_operation.html`
  - セットアップ: `.../system_operation__setup.html`
  - バージョン更新: `.../system_operation__version_update.html`
  - システム環境: `.../system_operation__system_environment.html`
- **クラウドサービス**: `https://docs.fusionplace.net/qanda/ja/cloud.html`
- **使い方**: `https://docs.fusionplace.net/qanda/ja/how_to_use.html`
  - データベース: `.../how_to_use__database.html`
  - Excel-Link: `.../how_to_use__excel_link.html`
  - フォーム: `.../how_to_use__form.html`
  - 権限: `.../how_to_use__authority.html`
  - ワークフロー: `.../how_to_use__workflow.html`
  - その他: `.../how_to_use__others.html`
- **トラブルシューティング**: `https://docs.fusionplace.net/qanda/ja/troubleshooting.html`
  - 設計: `.../troubleshooting__design.html`
  - 操作: `.../troubleshooting__operation.html`
  - エラーメッセージ: `.../troubleshooting__error_message.html`
- **FMC**: `https://docs.fusionplace.net/qanda/ja/fmc.html`
- **各種お手続き・お問い合わせ**: `https://docs.fusionplace.net/qanda/ja/procedures.html`
- **各種資料**: `https://docs.fusionplace.net/qanda/ja/materials.html`
  - テンプレート・サンプル: `.../materials__templates_examples.html`
  - トレーニング: `.../materials__training.html`

#### パターンライブラリ

- **パターン一覧**: `https://docs.fusionplace.net/patterns/ja/app_design__patterns.html`
- **パターンクラスター**: `https://docs.fusionplace.net/patterns/ja/app_design__pattern_clusters.html`

パターン個別ページは `https://docs.fusionplace.net/patterns/ja/ap-XXXX-Name.html` の形式。

### Step 3: ドキュメントを取得して情報を収集する

WebFetch ツールでページを取得する。カテゴリ・目次ページを取得して必要なリンクを見つけ、詳細ページへと掘り下げる。回答に十分な情報が集まったら取得を止める。

### Step 4: 回答を作成する

回答の末尾に以下の形式で参照情報を追加する：

```
**参考ドキュメント**
- [ページタイトル](URL) — マニュアル / Q&A / パターン
```

情報が見つからない場合は：「公式ドキュメントには該当情報が見当たりませんでした。詳細は [公式サポート](https://docs.fusionplace.net/qanda/ja/procedures.html) にお問い合わせください。」

## 将来の検索 API 対応

fusion_place ドキュメント検索 API（または対応する MCP ツール）が利用可能な場合は、WebFetch によるクロールより API を優先して使用する。API が利用できない・失敗した場合は上記の手動ナビゲーション方式にフォールバックする。
