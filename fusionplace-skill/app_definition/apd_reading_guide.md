# アプリケーション定義ファイル（.apd）の読み方

   > このファイルは `fusionplace` スキルの一ユースケースガイドです。トップレベルの `SKILL.md`（目次）から
   > 振り分けられてここに到達した場合、以降はこのファイルの指示に従ってください。
   > 複数の起点ガイドを併用している場合の優先順位は、`SKILL.md` の「振り分けの手順」に従ってください。

## このファイルは何か

`.apd`（Application Definition）は、fusion_place の **ひとつのアプリケーションに関する定義情報のすべて**を含むファイルである。アプリケーションの設計（ディメンション構成、元帳、期間・シナリオ・会計年度、フォーム、権限、業務責任単位など）を知りたい場合、**.apd が最も的確で網羅的な一次情報**である。

ユーザーがアプリケーションの設計内容（「このアプリのディメンションは」「元帳の構成は」「どんな勘定科目が」など）を尋ね、かつ .apd が入手可能なら、まずこれを読むとよい。

> 形式・スキーマは将来変更されうる。本ガイドは読解の手引きであり、保証された仕様ではない。

---

## 全体構造

XML 形式。ルートは `<entries>`、その下に `<entry type="APPLICATION" label="...">` が続く。
各設定は `entry`（type と任意の label を持つ）の入れ子で表現され、末端の値は`<content>` 要素に入る。

```
<entries>
  <entry type="APPLICATION" label="DEMO">
    <elements>
      <entry type="NAME"><content>...</content></entry>
      <entry type="DIMENSIONS">
        <elements>
          <entry type="DIMENSION" label="#ACCOUNT"> ... </entry>
          ...
```

APPLICATION 直下には、おおむね次のような設計要素が並ぶ（バージョンにより増減する）。

- `NAME` / `APPLICATION_TYPE` / `APPLICATION_SETTINGS` … 基本情報
- `PERIOD_TABLE` / `SCENARIO_TABLE` / `FISCAL_YEAR_TABLE` … 期間・シナリオ・会計年度
- `DIMENSIONS` … ディメンション（その下に各 `DIMENSION`）
- `LEDGERS` / `LEDGER_MASK` … 元帳
- `FORM_LISTS` / `FORM_LIST_PERMISSION_TABLE` … フォームと権限
- `SCRIPTS` / `TRANSLATION_TABLES` / `ACCESS_PERMISSION_TYPES` / `PARTICIPANTS` … その他

---

## 読む際の留意事項

### (1) 一部の content はネスト XML（二重エスケープされている）

`DIMENSION`・`PERIOD_TABLE`・`DOCUMENT_SPEC`・`SIMPLE_DOCUMENT_SPEC` などの `content` は、**それ自体が XML 文書をエスケープした文字列**になっている。元ファイルでは特殊文字が二重にエスケープされている（例：名称中の `&` は `&amp;amp;` として保存される）。
これは正しい二重エスケープであり、apd は XML として完全に適正である。

読み方は単純で、**外側を XML パーサで読めば `content` の値は自動的に1段アンエスケープされ、その文字列をもう一度 XML パーサに渡せば2段目も正しく処理される**。
特別な前処理は要らない。

```python
from xml.etree import ElementTree as ET

root = ET.fromstring(open('app.apd', encoding='utf-8').read())
dim_entry = root.find('.//entry[@type="DIMENSION"][@label="#ACCOUNT"]')

# content.text は外側パーサが1段アンエスケープ済み。そのまま渡すだけでよい。
dim = ET.fromstring(dim_entry.find('content').text)
```

> **注意：`html.unescape` を使わないこと。** XML の content を HTML 用の
> `html.unescape` に通すと、XML パーサが行うべき1段分を超えて余計にアンエスケープしてしまい、
> `&amp;`（本来 2段目で `&` になるべきもの）を先に裸の `&` へ戻してしまう。
> その結果、二段目のパースが `not well-formed` エラーになる。
> アンエスケープは XML パーサ（`ET.fromstring`）に任せ、自前で `html.unescape` や
> 文字列置換を行わないのが正しい。

### (2) 多言語名称は独自フォーマット（CSV流の引用符エスケープ）

`name` 要素や `NAME` の content は `言語コード;"値";言語コード;"値"` という形式。
例：`en;"Accounts";ja;"勘定科目"`。単一言語のみなら `ja;"デモンストレーション"` のように1組。

**値は必ずダブルクォートで囲まれる**。そして **値の中にダブルクォートが含まれる場合、Excel の CSV の規約に合わせて、ダブルクォート2つ（`""`）にエスケープされる**。
たとえば日本語名称が `勘定"科目` であれば `en;"Accounts";ja;"勘定""科目"` となる。

ダブルクォートで囲まれた中では、**ダブルクォート以外の文字はすべてその文字自身**として扱われる。区切りに見えるセミコロンも、改行文字も、引用符内にあれば値の一部である（エスケープが必要なのはダブルクォートだけ）。

このため、`split(';')` と `strip('"')` による素朴なパースは不十分（値内のセミコロンや`""` エスケープで壊れる）。引用符の状態を追って読む。値は引用符で囲まれているので、区切りのセミコロンと値内のセミコロンも正しく区別できる。

```python
def parse_multilang(s):
    """言語コード;"値";... をパース。値内の "" は " にデコードする。"""
    result = {}
    i, n = 0, len(s)
    while i < n:
        semi = s.index(';', i)          # 言語コードの直後の区切り
        lang = s[i:semi]; i = semi + 1
        if s[i] != '"': break           # 値は必ず " で始まる
        i += 1; buf = []
        while i < n:
            if s[i] == '"':
                if i+1 < n and s[i+1] == '"':   # "" はエスケープされた "
                    buf.append('"'); i += 2; continue
                i += 1; break                   # 閉じ引用符
            buf.append(s[i]); i += 1
        result[lang] = ''.join(buf)
        if i < n and s[i] == ';': i += 1        # ペア間の区切り
    return result

# parse_multilang('en;"Accounts";ja;"勘定""科目"') → {'en': 'Accounts', 'ja': '勘定"科目'}
```

### (3) メンバツリーは id 参照で表現

ディメンションのメンバ階層は、入れ子ではなく **フラットな `member` 要素の並び＋ID参照**で表現される。
- 各 `member` は `id`・`label`・`name`・`pv-list`（プロパティ）・`child-ids`（子のID, カンマ区切り）を持つ。
- ディメンション直下の `root-ids` がツリーの根のID群（カンマ区切り）。
- ツリーを復元するには、root-ids から `child-ids` を再帰的に辿る。

```
<dimension>
  <root-ids>1,6</root-ids>
  <member id="1" label="SHOHIN_KEI"><name>...</name>
    <pv-list>{#LEAF=FALSE,...}</pv-list><child-ids>2,3,4</child-ids></member>
  <member id="2" label="M01">...</member>
  ...
```

### (4) プロパティは pv-list の独自記法

`pv-list` は `{#KEY=VALUE,#KEY=VALUE,...}` の形。よく使うもの：
- `#LEAF=TRUE/FALSE` … リーフ（末端メンバ）か集計メンバか
- `#DATA_TYPE=...` … データ型（ACCOUNT など）
- `#MEMBER_TYPE=...` … メンバ種別

正規表現等でキーを取り出す（例：`#LEAF=TRUE` の有無でリーフ判定）。

---

## 最小の読解例（ディメンションのメンバツリー）

```python
from xml.etree import ElementTree as ET

def parse_nested(text):
    # content.text は外側パーサが1段アンエスケープ済み。そのまま渡せばよい。
    return ET.fromstring(text)

def parse_multilang(s):
    # 言語コード;"値";... をパース。値内の "" は " にデコード（(2)参照）。
    result = {}; i, n = 0, len(s)
    while i < n:
        semi = s.index(';', i); lang = s[i:semi]; i = semi + 1
        if s[i] != '"': break
        i += 1; buf = []
        while i < n:
            if s[i] == '"':
                if i+1 < n and s[i+1] == '"': buf.append('"'); i += 2; continue
                i += 1; break
            buf.append(s[i]); i += 1
        result[lang] = ''.join(buf)
        if i < n and s[i] == ';': i += 1
    return result

def name_in(elem, lang='ja'):
    n = elem.find('name')
    if n is None or not n.text: return ''
    return parse_multilang(n.text).get(lang, n.text)

root = ET.fromstring(open('app.apd', encoding='utf-8').read())
app = root.find('.//entry[@type="APPLICATION"]')
dims = app.find('./elements/entry[@type="DIMENSIONS"]')

d = dims.find('./elements/entry[@type="DIMENSION"][@label="#ACCOUNT"]')
dim = parse_nested(d.find('content').text)

members = {}
for m in dim.findall('member'):
    ci = m.find('child-ids')
    members[m.get('id')] = {
        'label': m.get('label'),
        'name': name_in(m),
        'children': ci.text.split(',') if ci is not None and ci.text else [],
        'leaf': '#LEAF=TRUE' in (m.findtext('pv-list') or ''),
    }

def show(mid, depth=0):
    m = members[mid]
    print('  '*depth + f"{m['label']} ({m['name']})" + ('' if m['leaf'] else ' [集計]'))
    for c in m['children']:
        if c in members: show(c, depth+1)

for r in dim.find('root-ids').text.split(','):
    if r in members: show(r)
```