# ドキュメント検索 API 詳細仕様
 
このファイルには、fusionplace-librarian が使用するドキュメント検索 API のエンドポイント・パラメータ・レスポンス形式・エラー仕様が記載されています。
 
**読み込むタイミング**: SKILL.md の Step 2（ドキュメント検索 API で検索する）を実行する際、実際にAPIを呼び出す前に読み込むこと。API呼び出しが不要な場合（Step 2.1のweb_search/web_fetchのみで進める場合等）は読み込む必要はない。
 
---
 
検索にはドキュメント検索 API (GET /search) を使用します。
全文検索とベクタ検索を統合したハイブリッド検索を提供します。
 
会社概要や活用事例については [フュージョンズ社Web](https://fusions.co.jp/) や [経営管理×ITの広場](https://fusionplace.net/) を参照してください。
 
## エンドポイント
 
```
GET https://docs-search.fusionplace.net/search
```
 
## クエリパラメータ
 
| パラメータ     | 必須 | 型     | 説明 |
|---------------|------|--------|------|
| `q`           | ✅   | string | 検索クエリ。1〜200 文字。 |
| `lang`        | ✅   | string | 言語コード。`JA` または `EN`。 |
| `doc_category`| ✅   | string | ドキュメントカテゴリ。`user-manual`, `qanda`, `patterns` のいずれか。 |
| `top_k`       | ❌   | number | 返却件数。1〜20 の整数。デフォルト `10`。 |
 
## リクエスト例
 
```bash
curl "https://docs-search.fusionplace.net/search?lang=JA&doc_category=user-manual&q=パスワードをリセットする方法"
 
curl "https://docs-search.fusionplace.net/search?lang=EN&doc_category=qanda&q=reset+password&top_k=5"
```
 
## レスポンス
 
### 成功 (200)
 
```json
{
  "request": {
    "q": "パスワードをリセットする方法",
    "lang": "JA",
    "doc_category": "user-manual",
    "top_k": 10,
    "mode": "hybrid"
  },
  "meta": {
    "total_hits": 3,
    "took_ms": 45
  },
  "items": [
    {
      "id": "opensearch-doc-id",
      "score": 0.987,
      "document_id": "doc-001",
      "title": "パスワードリセット手順",
      "link": "https://docs.fusionplace.net/reset-password",
      "lang": "ja",
      "doc_category": "user-manual",
      "content": "パスワードをリセットするには...",
      "tag": ["account", "security"]
    }
  ]
}
```
 
### エラーレスポンス
 
| HTTP ステータス | 原因 |
|----------------|------|
| `400 Bad Request` | パラメータ不正（`lang` 不正、`doc_category` 不正、`q` が空または 200 文字超、`top_k` が範囲外） |
| `502 Bad Gateway` | 検索バックエンドとの通信エラー |
 
```json
{ "message": "lang must be JA or EN" }
```
 
## 利用時の注意
 
- **`q` の上限は 200 文字**。長い文章を渡す場合は要約・短縮してから渡してください。
- **`doc_category` は許可リスト制**。`user-manual`, `qanda`, `patterns` 以外を指定すると 400 が返ります。
 