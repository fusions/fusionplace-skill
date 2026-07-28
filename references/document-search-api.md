# ドキュメント検索 API 詳細仕様

このファイルには、fusionplace-librarian が使用するドキュメント検索 API のエンドポイント・パラメータ・レスポンス形式・エラー仕様が記載されています。

**読み込むタイミング**: SKILL.md の Step 2（ドキュメント検索 API で検索する）を実行する際、実際にAPIを呼び出す前に読み込むこと。API呼び出しが不要な場合（Step 2.1のweb_search/web_fetchのみで進める場合等）は読み込む必要はない。

---

ドキュメント検索には `GET /search` を、検索結果の全文確認には `GET /documents/{document_id}` を使用します。
`/search` のレスポンスに含まれるのは各ドキュメントの抜粋（`content_preview`）のみです。
回答の根拠として引用する場合は、`/documents/{document_id}` で全文を取得してから内容を確認してください。

会社概要や活用事例については [フュージョンズ社Web](https://fusions.co.jp/) や [経営管理×ITの広場](https://fusionplace.net/) を参照してください。

## エンドポイント

```
GET https://docs-search.fusionplace.net/search
GET https://docs-search.fusionplace.net/documents/{document_id}
```

いずれも認証は不要です（公開API。APIキーやトークンの付与は不要）。

## `GET /search`: クエリパラメータ

| パラメータ     | 必須 | 型     | 説明 |
|---------------|------|--------|------|
| `q`           | ✅   | string | 検索クエリ。1〜200 文字。 |
| `lang`        | ✅   | string | 言語コード。`JA` または `EN`。 |
| `doc_category`| ✅   | string | ドキュメントカテゴリ。`user-manual`, `qanda`, `patterns` のいずれか。 |
| `top_k`       | ❌   | number | 返却件数。1〜20 の整数。デフォルト `10`。 |

## `GET /documents/{document_id}`: パスパラメータ

| パラメータ     | 必須 | 型     | 説明 |
|---------------|------|--------|------|
| `document_id` | ✅   | string | 全文を取得したいドキュメントのID。1〜200 文字。`/search` のレスポンス項目の `document_id`、または同項目の `detail_url` から取得できる。 |

## リクエスト例

```bash
curl "https://docs-search.fusionplace.net/search?lang=JA&doc_category=user-manual&q=パスワードをリセットする方法"

curl "https://docs-search.fusionplace.net/search?lang=EN&doc_category=qanda&q=reset+password&top_k=5"

# /search の結果、document_id="doc-001" が有力だった場合、全文を確認する
curl "https://docs-search.fusionplace.net/documents/doc-001"
```

**注意**: `/search` のレスポンスは大きくありません。`curl | head` のように出力を打ち切らず、
レスポンス全体（`items` 全件）を取得・確認してください。

## レスポンス

### `GET /search` 成功時 (200)

```json
{
  "request": {
    "q": "パスワードをリセットする方法",
    "lang": "JA",
    "doc_category": "user-manual",
    "top_k": 10
  },
  "meta": {
    "total_hits": 1,
    "took_ms": 8
  },
  "items": [
    {
      "document_id": "doc-001",
      "title": "パスワードリセット手順",
      "link": "https://docs.fusionplace.net/reset-password",
      "detail_url": "https://docs-search.fusionplace.net/documents/doc-001",
      "score": 1.81,
      "content_preview": "パスワードをリセットするには...(最大190文字までの抜粋)",
      "chunk_position": 0
    }
  ]
}
```

- `content_preview` は該当箇所の抜粋であり、**最大190文字に切り詰められています**。全文ではありません。
- `items` は `document_id` ごとに重複排除され、最もスコアの高いチャンクの情報のみが1件として返ります。
  同じドキュメント内の他の関連箇所を確認したい場合も `/documents/{document_id}` を使用してください。
- 該当ドキュメントが1件もない場合も `200` で `items: []` が返ります（`404` にはなりません）。

**`detail_url` と `link` の使い分け**：

- `detail_url` は本APIの内部エンドポイント（`GET /documents/{document_id}`）を指すURLです。該当ページの
  全文を確認するために**この URL へ直接アクセス**してください。
- `link` は公式ドキュメントサイト上の実ページのURLです。ユーザーへの回答で「参照：」として提示するURLは
  **常に `link` を使用**してください。`detail_url` をユーザー向けの参照URLとして提示してはいけません。

### `GET /documents/{document_id}` 成功時 (200)

```json
{
  "request": {
    "document_id": "doc-001"
  },
  "meta": {
    "total_chunks": 3,
    "took_ms": 6
  },
  "document": {
    "document_id": "doc-001",
    "title": "パスワードリセット手順",
    "link": "https://docs.fusionplace.net/reset-password",
    "chunks": [
      { "chunk_position": 0, "content": "パスワードをリセットするには...(全文)", "score": 1.81 }
    ]
  }
}
```

- `document.chunks` にドキュメントの全文（チャンク単位）が含まれます。回答作成前の自己チェック（Step 3）
  で「どのページのどの記述に基づいているか」を具体的に特定する際は、ここで得た全文を根拠にしてください。

### エラーレスポンス

エラー時のレスポンスボディは常に `{ "message": "<string>" }` の形式です。

| HTTP ステータス | 対象 | 原因 |
|----------------|------|------|
| `400 Bad Request` | `/search` | パラメータ不正（`lang` 不正、`doc_category` が許可リスト外、`q` が空または200文字超、`top_k` が範囲外） |
| `400 Bad Request` | `/documents/{document_id}` | `document_id` が空または200文字超 |
| `404 Not Found` | `/documents/{document_id}` | 指定した `document_id` のドキュメントが存在しない（`/search` はヒットなしでも200・空`items`を返すため404にはならない） |
| `500 Internal Server Error` | 両方 | API側の設定不備（呼び出し側では対処不可） |
| `502 Bad Gateway` | 両方 | 検索バックエンド（OpenSearch/Bedrock）との通信エラー |

```json
{ "message": "lang must be JA or EN" }
```

`500`・`502` が返る場合や、そもそも通信できない場合は、Step 2.1 のフォールバック（web_search/web_fetch）に進んでください。

## 利用時の注意

- **`q` の上限は 200 文字**。長い文章を渡す場合は要約・短縮してから渡してください。
- **`doc_category` は許可リスト制**。`user-manual`, `qanda`, `patterns` 以外を指定すると 400 が返ります。
- **認証は不要**（APIキー等の付与は不要な公開API）。
- **レート制限**: 20 req/秒（バースト40）。**タイムアウト**: 5秒。短時間に必要以上の並行呼び出しをしないこと。
