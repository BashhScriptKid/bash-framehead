# ext/sqlite — SQLite CLI wrapper

A stateless Bash wrapper around the `sqlite3` CLI. Every function takes a database
path as its first argument. There is no persistent connection — each function
invokes `sqlite3` directly.

Replaces ad-hoc `sqlite3 path "SQL"` calls with ergonomic, testable functions
that handle escaping, output formatting, and lifecycle for you.

## Dependencies

- **core:** `runtime` (for `runtime::has_command`)
- **external:** `sqlite3` (required at load time)

## Usage

```bash
source ./bash-framehead.sh
source ./ext/sqlite/sqlite.sh
```

## Global configuration

| Variable      | Default | Effect                                                          |
|---------------|---------|-----------------------------------------------------------------|
| `SQLITE_FIELDS` | `list`  | Output mode: `list` (tab-sep), `csv`, `tsv`, `json`, `line`    |
| `SQLITE_HEADER` | `0`     | 0/1, include column headers                                     |

## API Reference

### Capabilities

#### `sqlite::has <feature>`
Check whether a compile-time feature is available. Returns 0/1.
Supported features: `fts5`, `json1`, `rtree`, `deserialize`.

#### `sqlite::capabilities`
Print all capabilities as one line: `version=3.43.0 fts5=1 json1=0 rtree=1 deserialize=1`.

### Path factories

#### `sqlite::open::temp HANDLE`
Create a temp database file. HANDLE receives the path. Cleanup on EXIT.

```bash
sqlite::open::temp DB
sqlite::exec "$DB" "CREATE TABLE t(x)"
```

#### `sqlite::open::scratch HANDLE`
Open an in-memory scratch database. HANDLE receives `:memory:`.
No file is created; nothing to clean up.

**Note:** `:memory:` state does NOT persist across separate `sqlite3` invocations.
For persistent data within a script, use `sqlite::open::temp` or a real file path.

#### `sqlite::close [HANDLE]`
Remove a temp file (no-op for scratch or any other path). Idempotent.

### Draft namespace

#### `draft::open::lossy <source> HANDLE`
Copy source database into a working temp file using `.dump` (lossy: loses
pragmas, page layout, VACUUM state). HANDLE receives the temp path; cleanup
on EXIT.

```bash
sqlite::open::temp SRC
sqlite::exec "$SRC" "CREATE TABLE t(x); INSERT INTO t VALUES(1);"
draft::open::lossy "$SRC" DRAFT
sqlite::exec "$DRAFT" "DELETE FROM t WHERE x=1;"  # doesn't touch SRC
```

For a lossless byte-for-byte copy, use `snapshot::open` instead.

### Snapshot namespace

#### `snapshot::open <source> HANDLE`
Copy source database to a mktemp'd file (lossless: byte-for-byte `cp`).
HANDLE receives the temp path; cleanup on EXIT.

```bash
snapshot::open "$PROD_DB" SNAP
sqlite::query "$SNAP" "SELECT * FROM users;"  # safe read of prod snapshot
```

### Core operations

#### `sqlite::exec <path> <sql>`
Execute SQL with no output. DDL, INSERT, UPDATE, DELETE, PRAGMA, etc.

```bash
sqlite::exec "$DB" "CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT);"
```

#### `sqlite::query <path> <sql>`
Run a query, print rows to stdout in the configured output mode (default
tab-separated). Use `SQLITE_FIELDS=csv` for CSV output.

```bash
sqlite::query "$DB" "SELECT name FROM users WHERE age > 30;"
```

#### `sqlite::query::fast <path> <sql> <result_array>`
Fast variant: populates a caller's indexed array via nameref, one row per
element. Uses `mapfile` for collection (no extra subshell).

```bash
declare -a rows
sqlite::query::fast "$DB" "SELECT name FROM users;" rows
echo "got ${#rows[@]} rows"
```

#### `sqlite::one <path> <sql>`
Print a single scalar value (first column, first row).

```bash
sqlite::one "$DB" "SELECT count(*) FROM users;"  # → 42
```

#### `sqlite::exists <path> <sql>`
Return 0 if the SQL subquery returns any row, 1 otherwise.

```bash
if sqlite::exists "$DB" "SELECT 1 FROM users WHERE name='Alice'"; then
    echo "Alice exists"
fi
```

#### `sqlite::count <path> <table> [where]`
Print the row count of a table, optionally filtered by a WHERE clause.

```bash
sqlite::count "$DB" users
sqlite::count "$DB" users "age > 30"
```

### Ergonomic helpers

#### `sqlite::insert <path> <table> [key value ...]`
Insert one row from key/value pairs. Uses `INSERT OR REPLACE`.

```bash
sqlite::insert "$DB" users name Alice age 30 city NYC
```

#### `sqlite::upsert <path> <table> [key value ...]`
Insert or update one row. Uses `INSERT ... ON CONFLICT DO UPDATE`.

```bash
sqlite::upsert "$DB" users name Alice age 31 city NYC
```

#### `sqlite::select <path> <table> [where]`
Select all columns from a table, optionally filtered.

```bash
sqlite::select "$DB" users "age > 30"
```

#### `sqlite::import <path> <table> <file>`
Bulk-import a CSV/TSV file into a table. Uses sqlite3's `.import` which
handles RFC 4180 quoting correctly.

```bash
sqlite::import "$DB" users users.csv
```

#### `sqlite::export <path> <sql> <file> [mode]`
Export query results to a file. Default mode is `csv`.

```bash
sqlite::export "$DB" "SELECT * FROM users WHERE active=1" active-users.csv
```

### Schema introspection

#### `sqlite::tables <path>`
List all user tables and views, one per line.

#### `sqlite::schema <path> [name]`
Print CREATE statements. If `name` is given, only that table/view.

#### `sqlite::columns <path> <table>`
List columns of a table: `cid name type notnull default pk`.

#### `sqlite::indexes <path> <table>`
List indexes of a table.

#### `sqlite::pragma <path> <name> [value]`
Get or set a PRAGMA value.

```bash
sqlite::pragma "$DB" journal_mode              # → delete
sqlite::pragma "$DB" journal_mode WAL          # set to WAL
```

### Operational

#### `sqlite::exec_block <path>`
Read multi-statement SQL from stdin and run in a single `sqlite3` process.
Required for transactions (BEGIN/COMMIT must share connection state).

```bash
sqlite::exec_block "$DB" <<'SQL'
BEGIN;
INSERT INTO users VALUES('Alice', 30);
UPDATE stats SET count = count + 1;
COMMIT;
SQL
```

#### `sqlite::backup <path> <dest>`
Hot-backup a database to a destination file. Safe while writers are active.

#### `sqlite::vacuum <path>`
Rebuild the database file, reclaim space.

#### `sqlite::integrity_check <path>`
Run integrity check. Returns 0 if OK, prints diagnostics otherwise.

### Lifecycle helpers

#### `sqlite::with_temp <fn> [args...]`
Run a command in a disposable temp-database scope. The temp path is
prepended as the first arg to the callback. Cleanup is via `trap RETURN`,
guaranteed on error/return.

```bash
result=$(sqlite::with_temp sqlite::query "SELECT 42;")
```

#### `sqlite::schedule_close <HANDLE>`
Override the default cleanup timing for a path-factory HANDLE.
Useful inside subshells where you want cleanup at subshell exit, not
session exit.

## Examples

### Schema migration

```bash
sqlite::open::scratch DB  # not :memory: in practice; use temp
sqlite::exec "$DB" "$(cat schema.sql)"
sqlite::query "$DB" "SELECT name FROM sqlite_master;"
```

### ETL: read CSV, query, export to JSON

```bash
sqlite::open::temp DB
sqlite::import "$DB" sales data.csv
SQLITE_FIELDS=json sqlite::query "$DB" \
    "SELECT region, sum(amount) FROM sales GROUP BY region" \
    > totals.json
```

### Snapshot before destructive operation

```bash
snapshot::open "$PROD_DB" SNAP
sqlite::exec "$PROD_DB" "DELETE FROM users WHERE last_login < '2020-01-01';"
# SNAP is unchanged if you need to roll back
```

## Notes

- `:memory:` databases do not persist across separate `sqlite3` invocations.
  Each function spawns a new process, so use temp files for stateful work.
- Bash variables cannot hold NUL bytes, so BLOBs are not directly supported.
  Read/write BLOBs via `xxd` or base64 if needed.
- For very large result sets in `query::fast`, the entire result is loaded
  into memory. Use `sqlite::query` with output redirection for streaming.

## FTS5 sub-namespace

Full-text search via SQLite's FTS5 virtual table. All functions check
`sqlite::has fts5` and return an error if the build lacks FTS5.

### `sqlite::fts::create <path> <table> <col> [col ...]`

Create an FTS5 virtual table. At least one column is required.

```bash
sqlite::fts::create "$DB" docs title body
sqlite::fts::create "$DB" notes title
```

### `sqlite::fts::index <path> <table> <column> <content> [id]`

Index a single document into a column. The optional `id` lets you re-index
or assign a known rowid.

```bash
sqlite::fts::index "$DB" docs title "the quick brown fox"
sqlite::fts::index "$DB" notes title "meeting notes for monday" 42
```

### `sqlite::fts::search <path> <table> <column> <query>`

Full-text search using FTS5 query syntax. Prints rows as
`rowid<TAB>content<TAB>rank` (one per match).

```bash
sqlite::fts::search "$DB" docs title "fox"
# 1|the quick brown fox|-1.0e-06

sqlite::fts::search "$DB" docs title "hello*"
sqlite::fts::search "$DB" docs title "NEAR(quick fox)"
```

### `sqlite::fts::snippet <path> <table> <column> <query>`

Search with highlighted snippet. Prints `rowid<TAB>content<TAB>snippet`
where the snippet has `<b>...</b>` markers around matches.

```bash
sqlite::fts::snippet "$DB" docs title "fox"
# 1|the quick brown fox jumps over the lazy dog|the quick brown <b>fox</b>...
```

### `sqlite::fts::delete <path> <table> <rowid>`

Delete a single document by rowid.

```bash
sqlite::fts::delete "$DB" docs 1
```

### `sqlite::fts::rebuild <path> <table>`

Optimize the FTS5 index after many insertions or updates. Internally issues
the `INSERT INTO t(t) VALUES('rebuild')` optimize command.

```bash
sqlite::fts::rebuild "$DB" docs
```

### `sqlite::fts::drop <path> <table>`

Drop the FTS5 virtual table.

```bash
sqlite::fts::drop "$DB" docs
```

### Notes (FTS5)

- The column name argument is required because FTS5 does not allow indexing
  into a table using the table name as a column alias.
- FTS5 tokenizes by default (porter tokenizer, ascii lowercasing). For other
  behaviors, run raw `sqlite::exec` with the desired FTS5 options.
- `search` and `snippet` both return their full result set via stdout
  redirection. Pipe to `head` or `sort` for large corpora.

## json1 sub-namespace

Helpers for the SQLite JSON1 extension. All functions check `sqlite::has json1`
and return an error if the build lacks json1.

### `sqlite::json::extract <path> <table> <column> <json_path> [where]`

Extract a JSON value at a path from a column. Returns the scalar value
(or JSON fragment for objects/arrays).

```bash
sqlite::json::extract "$DB" users data '$.email'
sqlite::json::extract "$DB" users data '$.name' "id = 7"
```

### `sqlite::json::each <path> <table> <column> [where]`

Iterate JSON via `json_each`. Returns columns: id, key, value, type, atom.

```bash
sqlite::json::each "$DB" users data | head -5
```

### `sqlite::json::contains <path> <table> <column> <json_value>`

Returns 0/1 (true/false) — does the column contain the given value?

```bash
sqlite::json::contains "$DB" users data '"alice"'
```

### `sqlite::json::set <path> <table> <column> <json_path> <value> <row_where>`

Set a JSON path within a column to a new value. The `<row_where>` argument
is required to avoid accidentally updating every row.

```bash
sqlite::json::set "$DB" users data '$.age' '31' "id = 7"
```

### Notes (json1)

- The local sqlite3 3.53.0 build on this machine lacks json1. Tests are
  skipped when `sqlite::has json1` returns false.
- The `extract` and `each` functions stream their full result set via stdout.

## Migrations sub-namespace

Schema versioning via ordered SQL files. Applied migrations are tracked in
a `_migrations` table inside the database. Idempotent: re-running has no
effect once all migrations are applied.

### `sqlite::migrate <path> <migrations_dir>`

Apply all pending migrations in a directory. Migration files are named
with a sortable prefix like `001_init.sql`, `002_users.sql`, or for the
`new` generator, `<unix_ts>_<slug>.sql`. Each file's contents are run as
a single batch.

```bash
mkdir -p ./migrations
cat > ./migrations/001_users.sql <<'SQL'
CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT);
SQL
cat > ./migrations/002_emails.sql <<'SQL'
ALTER TABLE users ADD COLUMN email TEXT;
SQL

sqlite::migrate "$DB" ./migrations
# applying: 001_users.sql
#   ok
# applying: 002_emails.sql
#   ok
```

### `sqlite::migrations::status <path> <migrations_dir>`

Show applied vs pending migrations. Prints lines as
`<name>\t<status>\t<applied_at>`.

```bash
sqlite::migrations::status "$DB" ./migrations
# 001_users.sql  applied  2026-06-03 16:40:47
# 002_emails.sql applied  2026-06-03 16:40:47
```

### `sqlite::migrations::new <migrations_dir> <description>`

Generate a new migration file with a timestamped name. Slugifies the
description, prefixes it with the current Unix timestamp. Returns the
file path on stdout.

```bash
file=$(sqlite::migrations::new ./migrations "Add user email index")
# Creates: ./migrations/1700000000_add_user_email_index.sql
#   -- Migration: Add user email index
#   -- Created: 2026-...
#
# Edit the file, then:
sqlite::migrate "$DB" ./migrations
```

### Notes (Migrations)

- File ordering is by filename sort, so `001_`, `002_`, `003_` works, and
  timestamp prefixes also work (lexicographic = chronological).
- The `_migrations` table is created automatically on first use.
- The `migrate` function uses `sqlite3 -bail`, so a SQL error halts and
  no migration is recorded for the failed file.

## Benchmarks

Run `./ext/sqlite/benchmark.sh` to reproduce. Sample output (sqlite3 3.53.0,
bash 5.x, 1000 rows / 100 iterations):

| Operation                          | Total (ms) | Per-op (ms) |
|------------------------------------|-----------:|------------:|
| `sqlite::query`     (COUNT(*))     |      652.1 |        6.52 |
| `sqlite::query::fast` (COUNT(*))   |      591.8 |        5.92 |
| `sqlite::query`     (multi-col)    |      869.2 |        8.69 |
| `sqlite::query::fast` (multi-col)  |      993.3 |        9.93 |
| `sqlite::fts::search` (100 docs)   |     1990.5 |       19.91 |

**Takeaways**:

- `query::fast` wins on scalar results (saves a subshell pipe). Roughly
  10% faster on `COUNT(*)` over 1000 rows.
- `query::fast` loses on multi-row results because `mapfile` per line
  costs more than streaming stdout via `query`. Use `query` (stdout
  pipe) when you don't need the array, or when rows exceed a few thousand.
- FTS5 search is dominated by the `sqlite3` process spawn cost (~20ms
  per call) at this corpus size. For high-throughput FTS, batch queries
  with `exec_block` instead of calling `fts::search` in a loop.
