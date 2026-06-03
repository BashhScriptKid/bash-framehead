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
