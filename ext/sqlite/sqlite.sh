# shellcheck shell=bash
# ext/sqlite/sqlite.sh — SQLite CLI wrapper
#
# Stateless wrapper around the `sqlite3` CLI. Every function takes a database
# path as its first argument (or accepts one via the path-factory helpers).
# HANDLE is a path string. There is no persistent connection.
#
# CONFIGURATION:
#   SQLITE_FIELDS         Output separator for query: 'list' (default), 'csv', 'tsv', 'json', 'line'
#   SQLITE_HEADER         0/1, include column headers (default 0)
#   SQLITE_MODE           Default output mode if not overridden
#
# EXAMPLES:
#   source bash-framehead.sh
#   source ext/sqlite/sqlite.sh
#
#   # Path-factory pattern
#   sqlite::open::temp DB
#   sqlite::exec "$DB" "CREATE TABLE t(x)"
#   sqlite::query "$DB" "SELECT * FROM t"
#   sqlite::close "$DB"
#
#   # In-memory scratch
#   sqlite::open::scratch DB
#   sqlite::exec "$DB" "CREATE TABLE t(x); INSERT INTO t VALUES('hi')"
#   sqlite::query "$DB" "SELECT * FROM t"  # → hi
#
#   # Copy a database into a working draft
#   draft::open::lossless source.db DB    # full copy into :memory:
#   draft::open::lossy    source.db DB    # .dump → :memory:

# --- guard ---
declare -f 'runtime::bash_version' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
	return 1
}

_guard_core_deps=(runtime::has_command)
_guard_ext_deps=(sqlite3)

for _guard_dep in "${_guard_core_deps[@]}"; do
	declare -f "$_guard_dep" &>/dev/null || {
		echo "${BASH_SOURCE[0]}: missing core function '$_guard_dep'" >&2
		return 1
	}
done

for _guard_dep in "${_guard_ext_deps[@]}"; do
	command -v "$_guard_dep" &>/dev/null || {
		echo "${BASH_SOURCE[0]}: missing external tool '$_guard_dep'" >&2
		return 1
	}
done

unset _guard_core_deps _guard_ext_deps _guard_dep
# --- end guard ---

# --- defaults ---
: "${SQLITE_FIELDS:=list}"
: "${SQLITE_HEADER:=0}"
: "${SQLITE_MODE:=rwc}"

# --- cleanup registry ---
# Tracks temp files created by sqlite::open::temp, draft::open::lossy, and
# snapshot::open. The EXIT trap iterates this list and removes each entry.
declare -ga _SQLITE_TMPFILES=()

_sqlite::_register_tmpfile() {
	local _path="$1"
	_SQLITE_TMPFILES+=("$_path")
	# Set the cleanup trap only once; subsequent calls reuse it.
	if [[ -z "${_SQLITE_TRAP_SET:-}" ]]; then
		trap '_sqlite::_cleanup_all' EXIT
		_SQLITE_TRAP_SET=1
	fi
}

_sqlite::_cleanup_all() {
	local _f
	for _f in "${_SQLITE_TMPFILES[@]:-}"; do
		[[ -n "$_f" && -f "$_f" ]] && rm -f "$_f"
	done
	_SQLITE_TMPFILES=()
}

# --- internal ---

# Escape a string value for use inside a single-quoted SQL literal.
# Doubles single quotes (SQL standard escape).
_sqlite::_escape_string() {
	local _val="$1"
	printf '%s' "$_val" | sed "s/'/''/g"
}

# Quote an identifier (table/column name) for safe interpolation.
# Double-quotes wrap; embedded double-quotes are doubled.
_sqlite::_quote_ident() {
	local _val="$1"
	printf '"%s"' "${_val//\"/\"\"}"
}

# Internal: build sqlite3 invocation with our standard flags.
# Usage: _sqlite::_run <db> [extra-flags] -- <sql...>
# Pipes through cat to handle multi-line SQL cleanly.
_sqlite::_run() {
	local _db="$1"; shift
	sqlite3 -noheader -batch "$_db" "$@"
}

# Build a -separator/-list/-csv/-tsv/-json/-line flag from SQLITE_FIELDS.
_sqlite::_mode_flag() {
	case "${SQLITE_FIELDS:-list}" in
		list) printf -- '-list ' ;;
		csv)  printf -- '-csv ' ;;
		tsv)  printf -- '-tsv ' ;;
		json) printf -- '-json ' ;;
		line) printf -- '-line ' ;;
		*)    printf -- '-list ' ;;
	esac
}

# ==============================================================================
# CAPABILITIES
# ==============================================================================

# Check whether a named compile-time feature is available.
# Usage: sqlite::has fts5 | json1 | rtree | deserialize
sqlite::has() {
	local _feature="$1"
	case "$_feature" in
		fts5)
			sqlite3 :memory: \
				"SELECT sqlite_compileoption_used('ENABLE_FTS5');" 2>/dev/null \
				| grep -qx 1
			;;
		json1)
			sqlite3 :memory: \
				"SELECT sqlite_compileoption_used('ENABLE_JSON1');" 2>/dev/null \
				| grep -qx 1
			;;
		rtree)
			sqlite3 :memory: \
				"SELECT sqlite_compileoption_used('ENABLE_RTREE');" 2>/dev/null \
				| grep -qx 1
			;;
		deserialize)
			sqlite3 -deserialize </dev/null :memory: 2>/dev/null
			;;
		*)
			echo "sqlite::has: unknown feature '$_feature'" >&2
			return 1
			;;
	esac
}

# Report all capabilities as a single line: "version=X.Y.Z fts5=1 json1=1 ..."
sqlite::capabilities() {
	local _ver
	_ver=$(sqlite3 :memory: "SELECT sqlite_version();" 2>/dev/null)
	printf 'version=%s' "$_ver"
	sqlite::has fts5        && printf ' fts5=1' || printf ' fts5=0'
	sqlite::has json1       && printf ' json1=1' || printf ' json1=0'
	sqlite::has rtree       && printf ' rtree=1' || printf ' rtree=0'
	sqlite::has deserialize && printf ' deserialize=1' || printf ' deserialize=0'
	echo
}

# ==============================================================================
# PATH FACTORIES
# ==============================================================================

# Create a temp database file. HANDLE receives the mktemp path.
# The file is registered for automatic cleanup on session EXIT.
# Usage: sqlite::open::temp HANDLE
sqlite::open::temp() {
	local -n _handle="$1"
	local _db
	_db=$(mktemp -t fsbshf-sqlite.XXXXXX.db) || {
		echo "sqlite::open::temp: mktemp failed" >&2
		return 1
	}
	_handle="$_db"
	_sqlite::_register_tmpfile "$_db"
}

# Open an in-memory scratch database. HANDLE receives ":memory:".
# No file is created; nothing to clean up.
# Usage: sqlite::open::scratch HANDLE
sqlite::open::scratch() {
	local -n _handle="$1"
	_handle=":memory:"
}

# Remove a temp database file (no-op for scratch or any other path).
# Idempotent: safe to call multiple times.
# Usage: sqlite::close [HANDLE]
sqlite::close() {
	local _db="${1:-}"
	[[ -z "$_db" || "$_db" == ":memory:" ]] && return 0
	[[ -f "$_db" ]] && rm -f "$_db"
}

# ==============================================================================
# DRAFT NAMESPACE — copy a database into a working temp file
# ==============================================================================

# Copy source database into a working temp file using .dump (lossy: loses
# pragmas, page layout, VACUUM state). The resulting draft is independent
# of the source — any modifications are isolated. Cleanup is on EXIT.
#
# For a lossless byte-for-byte copy, use snapshot::open instead.
# Usage: draft::open::lossy <source> HANDLE
draft::open::lossy() {
	local _source="$1" _db="$2"
	local -n _handle="$_db"
	[[ -r "$_source" ]] || {
		echo "draft::open::lossy: cannot read '$_source'" >&2
		return 1
	}
	local _tmp
	_tmp=$(mktemp -t fsbshf-sqlite-draft.XXXXXX.db) || {
		echo "draft::open::lossy: mktemp failed" >&2
		return 1
	}
	sqlite3 "$_source" .dump | sqlite3 -noheader -batch "$_tmp"
	_handle="$_tmp"
	_sqlite::_register_tmpfile "$_tmp"
}

# ==============================================================================
# SNAPSHOT NAMESPACE — copy a database to a fresh temp file
# ==============================================================================

# Copy source database to a mktemp'd file. HANDLE receives the temp path.
# The snapshot is registered for automatic cleanup on session EXIT.
# Lossless: byte-for-byte copy of the source file.
# Usage: snapshot::open <source> HANDLE
snapshot::open() {
	local _source="$1" _db="$2"
	local -n _handle="$_db"
	[[ -r "$_source" ]] || {
		echo "snapshot::open: cannot read '$_source'" >&2
		return 1
	}
	local _tmp
	_tmp=$(mktemp -t fsbshf-sqlite-snapshot.XXXXXX.db) || {
		echo "snapshot::open: mktemp failed" >&2
		return 1
	}
	cp "$_source" "$_tmp" || {
		rm -f "$_tmp"
		echo "snapshot::open: cp failed" >&2
		return 1
	}
	_handle="$_tmp"
	_sqlite::_register_tmpfile "$_tmp"
}

# ==============================================================================
# CORE OPERATIONS
# ==============================================================================

# Execute SQL with no output. DDL, INSERT, UPDATE, DELETE, PRAGMA, etc.
# Usage: sqlite::exec <path> <sql>
sqlite::exec() {
	local _db="$1" _sql="$2"
	sqlite3 -noheader -batch "$_db" "$_sql"
}

# Run a query, print rows to stdout using the configured output mode.
# Default mode is 'list' (tab-separated, no header) — set SQLITE_FIELDS to
# csv, tsv, json, or line to change.
# Usage: sqlite::query <path> <sql>
sqlite::query() {
	local _db="$1" _sql="$2"
	local _flag
	_flag=$(_sqlite::_mode_flag)
	# shellcheck disable=SC2086
	sqlite3 -noheader -batch $_flag "$_db" "$_sql"
}

# Fast variant of query: populates a caller's indexed array, one row per element.
# No subshell in the collection step (uses mapfile which is built into bash).
# Usage: sqlite::query::fast <path> <sql> <result_array>
sqlite::query::fast() {
	local _db="$1" _sql="$2"
	local -n _result="$3"
	mapfile -t _result < <(sqlite3 -noheader -batch -list "$_db" "$_sql")
}

# Print a single scalar value (first column, first row) of a query.
# Usage: sqlite::one <path> <sql>
sqlite::one() {
	local _db="$1" _sql="$2"
	sqlite3 -noheader -batch "$_db" "$_sql" | head -n 1
}

# Return 0 if the SQL subquery returns any row, 1 otherwise.
# Usage: sqlite::exists <path> <sql>
sqlite::exists() {
	local _db="$1" _sql="$2"
	local _result
	_result=$(sqlite::one "$_db" "SELECT EXISTS($_sql)")
	[[ "$_result" == "1" ]]
}

# Print the row count of a table, optionally filtered by a WHERE clause.
# Usage: sqlite::count <path> <table> [where]
sqlite::count() {
	local _db="$1" _table="$2" _where="${3:-}"
	local _sql="SELECT COUNT(*) FROM $(_sqlite::_quote_ident "$_table")"
	[[ -n "$_where" ]] && _sql="$_sql WHERE $_where"
	sqlite::one "$_db" "$_sql"
}

# ==============================================================================
# ERGONOMIC HELPERS
# ==============================================================================

# Insert (or replace on conflict) a row from key/value pairs.
# Usage: sqlite::insert <path> <table> [key value ...]
sqlite::insert() {
	local _db="$1" _table="$2"
	shift 2
	local _cols=() _vals=() _i=0 _qtable
	_qtable=$(_sqlite::_quote_ident "$_table")
	while (( $# >= 2 )); do
		_cols+=("$(_sqlite::_quote_ident "$1")")
		_vals+=("'$(_sqlite::_escape_string "$2")'")
		shift 2
		((_i++))
	done
	if (( _i == 0 )); then
		echo "sqlite::insert: no key/value pairs given" >&2
		return 1
	fi
	local _sql
	printf -v _sql 'INSERT OR REPLACE INTO %s (%s) VALUES (%s)' \
		"$_qtable" \
		"$(IFS=,; echo "${_cols[*]}")" \
		"$(IFS=,; echo "${_vals[*]}")"
	sqlite::exec "$_db" "$_sql"
}

# Insert (or update on conflict) a row from key/value pairs.
# Uses INSERT ... ON CONFLICT ... DO UPDATE.
# Usage: sqlite::upsert <path> <table> [key value ...]
sqlite::upsert() {
	local _db="$1" _table="$2"
	shift 2
	local _cols=() _vals=() _updates=() _i=0 _col _val _qtable
	_qtable=$(_sqlite::_quote_ident "$_table")
	while (( $# >= 2 )); do
		_col=$(_sqlite::_quote_ident "$1")
		_val="'$(_sqlite::_escape_string "$2")'"
		_cols+=("$_col")
		_vals+=("$_val")
		_updates+=("$_col = excluded.$_col")
		shift 2
		((_i++))
	done
	if (( _i == 0 )); then
		echo "sqlite::upsert: no key/value pairs given" >&2
		return 1
	fi
	local _sql
	printf -v _sql 'INSERT INTO %s (%s) VALUES (%s) ON CONFLICT DO UPDATE SET %s' \
		"$_qtable" \
		"$(IFS=,; echo "${_cols[*]}")" \
		"$(IFS=,; echo "${_vals[*]}")" \
		"$(IFS=,; echo "${_updates[*]}")"
	sqlite::exec "$_db" "$_sql"
}

# Select all rows (or filtered) from a table. Equivalent to
# `SELECT * FROM <table> [WHERE <where>]`.
# Usage: sqlite::select <path> <table> [where]
sqlite::select() {
	local _db="$1" _table="$2" _where="${3:-}"
	local _sql="SELECT * FROM $(_sqlite::_quote_ident "$_table")"
	[[ -n "$_where" ]] && _sql="$_sql WHERE $_where"
	sqlite::query "$_db" "$_sql"
}

# Bulk-import a CSV/TSV file into a table. Uses sqlite3's .import which
# handles RFC 4180 quoting correctly.
# Usage: sqlite::import <path> <table> <file> [separator]
sqlite::import() {
	local _db="$1" _table="$2" _file="$3" _sep="${4:-,}"
	[[ -r "$_file" ]] || {
		echo "sqlite::import: cannot read '$_file'" >&2
		return 1
	}
	local _qtable
	_qtable=$(_sqlite::_quote_ident "$_table")
	sqlite3 -noheader -batch -separator "$_sep" "$_db" \
		<<EOF
.import "$_file" $_qtable
EOF
}

# Export query results to a file. Wraps `.once` for clean output.
# Usage: sqlite::export <path> <sql> <file> [mode]
sqlite::export() {
	local _db="$1" _sql="$2" _file="$3" _mode="${4:-csv}"
	local _arg
	case "$_mode" in
		csv)  _arg='-csv' ;;
		tsv)  _arg='-tsv' ;;
		json) _arg='-json' ;;
		*)    _arg='-list' ;;
	esac
	# shellcheck disable=SC2086
	sqlite3 -noheader -batch $_arg "$_db" <<EOF
.once "$_file"
$_sql
EOF
}

# ==============================================================================
# SCHEMA INTROSPECTION
# ==============================================================================

# List all user tables (and views) in the database. One per line.
# Usage: sqlite::tables <path>
sqlite::tables() {
	local _db="$1"
	sqlite::query "$_db" \
		"SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' ORDER BY name;"
}

# Print CREATE statements for the database (or a specific table/view).
# Usage: sqlite::schema <path> [name]
sqlite::schema() {
	local _db="$1" _name="${2:-}"
	if [[ -n "$_name" ]]; then
		sqlite::query "$_db" \
			"SELECT sql FROM sqlite_master WHERE name = '$_name' AND sql IS NOT NULL;"
	else
		sqlite::query "$_db" \
			"SELECT sql || ';' FROM sqlite_master WHERE sql IS NOT NULL ORDER BY type, name;"
	fi
}

# List columns of a table as: name type notnull default (one per line).
# Usage: sqlite::columns <path> <table>
sqlite::columns() {
	local _db="$1" _table="$2"
	sqlite::query "$_db" "PRAGMA table_info($_table);"
}

# List indexes of a table. One per line: name unique(0/1) columns...
# Usage: sqlite::indexes <path> <table>
sqlite::indexes() {
	local _db="$1" _table="$2"
	sqlite::query "$_db" "PRAGMA index_list($_table);"
}

# Get or set a PRAGMA value.
#   sqlite::pragma <path> journal_mode           # get
#   sqlite::pragma <path> journal_mode WAL       # set
# Usage: sqlite::pragma <path> <name> [value]
sqlite::pragma() {
	local _db="$1" _name="$2" _val="${3:-}"
	if [[ -n "$_val" ]]; then
		sqlite::exec "$_db" "PRAGMA $_name = $_val;"
		return $?
	else
		sqlite::query "$_db" "PRAGMA $_name;"
	fi
}

# ==============================================================================
# OPERATIONAL
# ==============================================================================

# Run a multi-statement SQL block in a single sqlite3 process.
# Useful for transactions (BEGIN; ... COMMIT;) or any time multiple
# statements must share connection state.
#
# Reads SQL from stdin. All statements run in one process; transaction
# state, temporary tables, etc. persist across statements.
#
# Usage:
#   sqlite::exec_block <path> <<'SQL'
#   BEGIN;
#   INSERT INTO t VALUES(1);
#   COMMIT;
#   SQL
sqlite::exec_block() {
	local _db="$1"
	sqlite3 -noheader -batch "$_db"
}

# Hot-backup a database to a destination file. Safe while writers are active.
# Usage: sqlite::backup <path> <dest>
sqlite::backup() {
	local _db="$1" _dest="$2"
	sqlite3 -noheader -batch "$_db" ".backup '$_dest'"
}

# Vacuum the database (rebuild file, reclaim space).
# Usage: sqlite::vacuum <path>
sqlite::vacuum() {
	local _db="$1"
	sqlite::exec "$_db" "VACUUM;"
}

# Run integrity check. Returns 0 if ok, prints diagnostics to stdout.
# Usage: sqlite::integrity_check <path>
sqlite::integrity_check() {
	local _db="$1"
	local _result
	_result=$(sqlite::query "$_db" "PRAGMA integrity_check;")
	printf '%s\n' "$_result"
	[[ "$_result" == "ok" ]]
}

# ==============================================================================
# LIFECYCLE HELPERS
# ==============================================================================

# Run a command in a disposable temp-database scope. The temp file is
# created before the command runs and removed when this function returns
# (via the RETURN trap, so cleanup is guaranteed on error/return).
# The temp path is prepended as the first argument to the callback, so
# `sqlite::with_temp sqlite::query "SELECT 1"` becomes
# `sqlite::query /tmp/...db "SELECT 1"`.
# Usage: result=$(sqlite::with_temp <fn> [args...])
sqlite::with_temp() {
	local _db
	_db=$(mktemp -t fsbshf-sqlite.XXXXXX.db) || {
		echo "sqlite::with_temp: mktemp failed" >&2
		return 1
	}
	trap 'rm -f "$_db"' RETURN
	"$1" "$_db" "${@:2}"
}

# Override the default cleanup timing for a path-factory HANDLE.
# Default cleanup is at session EXIT (registered by sqlite::open::temp and
# snapshot::open). Use this to force cleanup at a different point — e.g.
# inside a subshell, where the EXIT trap would persist.
# Usage: sqlite::schedule_close <HANDLE>
sqlite::schedule_close() {
	local _db="$1"
	[[ -z "$_db" || "$_db" == ":memory:" ]] && return 0
	trap "rm -f '$_db'" EXIT
}

# ==============================================================================
# FTS5 SUB-NAMESPACE — full-text search
# ==============================================================================
#
# Wraps SQLite's FTS5 virtual table. All functions check sqlite::has fts5
# at call time and return an error if unavailable.

# Create an FTS5 virtual table over one or more columns.
# Usage: sqlite::fts::create <path> <table> <col> [col ...]
sqlite::fts::create() {
	local _db="$1" _table="$2"
	shift 2
	if ! sqlite::has fts5; then
		echo "sqlite::fts::create: FTS5 not available in this sqlite3 build" >&2
		return 1
	fi
	[[ $# -gt 0 ]] || {
		echo "sqlite::fts::create: at least one column required" >&2
		return 1
	}
	local _qtable _qcols
	_qtable=$(_sqlite::_quote_ident "$_table")
	_qcols="$(_sqlite::_quote_ident "$1")"
	shift
	for _c in "$@"; do
		_qcols+=",$(_sqlite::_quote_ident "$_c")"
	done
	sqlite::exec "$_db" \
		"CREATE VIRTUAL TABLE IF NOT EXISTS $_qtable USING fts5($_qcols);"
}

# Index a single document. <column> is the FTS5 column to index into.
# <content> is the text to index. [id] is the optional rowid.
#
# For tables with a single column, <column> can be the same as <table>.
# For multi-column tables, index into the appropriate column.
# Usage: sqlite::fts::index <path> <table> <column> <content> [id]
sqlite::fts::index() {
	local _db="$1" _table="$2" _column="$3" _content="$4" _id="${5:-}"
	if ! sqlite::has fts5; then
		echo "sqlite::fts::index: FTS5 not available" >&2
		return 1
	fi
	local _qtable _qcol _econtent
	_qtable=$(_sqlite::_quote_ident "$_table")
	_qcol=$(_sqlite::_quote_ident "$_column")
	_econtent=$(_sqlite::_escape_string "$_content")
	if [[ -n "$_id" ]]; then
		sqlite::exec "$_db" \
			"INSERT OR REPLACE INTO $_qtable(rowid, $_qcol) VALUES($_id, '$_econtent');"
	else
		sqlite::exec "$_db" \
			"INSERT INTO $_qtable($_qcol) VALUES('$_econtent');"
	fi
}

# Search the FTS5 table. <query> uses FTS5 syntax (e.g. 'hello*', 'NEAR(a b)').
# <column> is the column to search/match against. Prints: rowid<TAB>content<TAB>rank.
# Usage: sqlite::fts::search <path> <table> <column> <query>
sqlite::fts::search() {
	local _db="$1" _table="$2" _column="$3" _query="$4"
	if ! sqlite::has fts5; then
		echo "sqlite::fts::search: FTS5 not available" >&2
		return 1
	fi
	[[ -n "$_query" ]] || {
		echo "sqlite::fts::search: query required" >&2
		return 1
	}
	local _qtable _qcol _equery
	_qtable=$(_sqlite::_quote_ident "$_table")
	_qcol=$(_sqlite::_quote_ident "$_column")
	_equery=$(_sqlite::_escape_string "$_query")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT rowid, $_qcol, rank FROM $_qtable WHERE $_qcol MATCH '$_equery' ORDER BY rank;"
}

# Search with highlighted snippet. <query> is the FTS5 query, <column> is
# the column to match. Prints: rowid<TAB>content<TAB>snippet with <b>...</b>.
# Usage: sqlite::fts::snippet <path> <table> <column> <query>
sqlite::fts::snippet() {
	local _db="$1" _table="$2" _column="$3" _query="$4"
	if ! sqlite::has fts5; then
		echo "sqlite::fts::snippet: FTS5 not available" >&2
		return 1
	fi
	local _qtable _qcol _equery
	_qtable=$(_sqlite::_quote_ident "$_table")
	_qcol=$(_sqlite::_quote_ident "$_column")
	_equery=$(_sqlite::_escape_string "$_query")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT rowid, $_qcol, snippet($_qtable, '<b>', '</b>', '...', -1, 32)
		 FROM $_qtable WHERE $_qcol MATCH '$_equery' ORDER BY rank;"
}

# Delete a document by rowid.
# Usage: sqlite::fts::delete <path> <table> <rowid>
sqlite::fts::delete() {
	local _db="$1" _table="$2" _id="$3"
	if ! sqlite::has fts5; then
		echo "sqlite::fts::delete: FTS5 not available" >&2
		return 1
	fi
	local _qtable
	_qtable=$(_sqlite::_quote_ident "$_table")
	sqlite::exec "$_db" "DELETE FROM $_qtable WHERE rowid = $_id;"
}

# Rebuild the FTS5 index (optimizes after many updates).
# Usage: sqlite::fts::rebuild <path> <table>
sqlite::fts::rebuild() {
	local _db="$1" _table="$2"
	if ! sqlite::has fts5; then
		echo "sqlite::fts::rebuild: FTS5 not available" >&2
		return 1
	fi
	local _qtable
	_qtable=$(_sqlite::_quote_ident "$_table")
	sqlite::exec "$_db" "INSERT INTO $_qtable($_qtable) VALUES('rebuild');"
}

# Drop an FTS5 virtual table.
# Usage: sqlite::fts::drop <path> <table>
sqlite::fts::drop() {
	local _db="$1" _table="$2"
	local _qtable
	_qtable=$(_sqlite::_quote_ident "$_table")
	sqlite::exec "$_db" "DROP TABLE IF EXISTS $_qtable;"
}

# ==============================================================================
# JSON1 SUB-NAMESPACE — helpers for the SQLite JSON1 extension
# ==============================================================================
#
# Wraps SQLite's JSON1 SQL functions. All functions check sqlite::has json1
# at call time and return an error if unavailable.

# Extract a JSON value at a path from a column. <path> uses json_extract
# syntax ('$.foo', '$.items[0].name'). Returns the extracted value as text.
# Usage: sqlite::json::extract <path> <column_expr> <json_path>
#   column_expr can be a column name or any SQL expression
#   example: sqlite::json::extract "$DB" "data" '$.name' FROM mytable
#
# Actually for simple use, the function extracts from a single column of
# a specific table:
# Usage: sqlite::json::extract <path> <table> <column> <json_path> [where]
sqlite::json::extract() {
	local _db="$1" _table="$2" _column="$3" _jpath="$4" _where="${5:-}"
	if ! sqlite::has json1; then
		echo "sqlite::json::extract: json1 not available" >&2
		return 1
	fi
	local _qtable _qcol _ejpath
	_qtable=$(_sqlite::_quote_ident "$_table")
	_qcol=$(_sqlite::_quote_ident "$_column")
	_ejpath=$(_sqlite::_escape_string "$_jpath")
	local _sql="SELECT json_extract($_qcol, '$_ejpath') FROM $_qtable"
	[[ -n "$_where" ]] && _sql="$_sql WHERE $_where"
	sqlite::query "$_db" "$_sql"
}

# Iterate a JSON array/object via json_each. Returns rows with columns:
# id, key, value, type, atom, parent, fullkey, path.
# Usage: sqlite::json::each <path> <table> <column> [where]
sqlite::json::each() {
	local _db="$1" _table="$2" _column="$3" _where="${4:-}"
	if ! sqlite::has json1; then
		echo "sqlite::json::each: json1 not available" >&2
		return 1
	fi
	local _qtable _qcol
	_qtable=$(_sqlite::_quote_ident "$_table")
	_qcol=$(_sqlite::_quote_ident "$_column")
	local _sql="SELECT je.id, je.key, je.value, je.type, je.atom
	             FROM $_qtable, json_each($_qcol) AS je"
	[[ -n "$_where" ]] && _sql="$_sql WHERE $_where"
	sqlite::query "$_db" "$_sql"
}

# Check if a JSON column contains a given value.
# Usage: sqlite::json::contains <path> <table> <column> <json_value>
sqlite::json::contains() {
	local _db="$1" _table="$2" _column="$3" _value="$4"
	if ! sqlite::has json1; then
		echo "sqlite::json::contains: json1 not available" >&2
		return 1
	fi
	local _qtable _qcol _evalue
	_qtable=$(_sqlite::_quote_ident "$_table")
	_qcol=$(_sqlite::_quote_ident "$_column")
	_evalue=$(_sqlite::_escape_string "$_value")
	sqlite::exists "$_db" \
		"SELECT 1 FROM $_qtable WHERE json_contains($_qcol, '$_evalue')"
}

# Set a JSON path within a column to a new value. Writes back to the row.
# <row_id_expr> is the WHERE clause expression (e.g. "id = 'alice'").
# Usage: sqlite::json::set <path> <table> <column> <json_path> <value> <row_id_expr>
sqlite::json::set() {
	local _db="$1" _table="$2" _column="$3" _jpath="$4" _value="$5" _where="$6"
	if ! sqlite::has json1; then
		echo "sqlite::json::set: json1 not available" >&2
		return 1
	fi
	[[ -n "$_where" ]] || {
		echo "sqlite::json::set: WHERE expression required to avoid updating all rows" >&2
		return 1
	}
	local _qtable _qcol _ejpath _evalue
	_qtable=$(_sqlite::_quote_ident "$_table")
	_qcol=$(_sqlite::_quote_ident "$_column")
	_ejpath=$(_sqlite::_escape_string "$_jpath")
	_evalue=$(_sqlite::_escape_string "$_value")
	sqlite::exec "$_db" \
		"UPDATE $_qtable SET $_qcol = json_set($_qcol, '$_ejpath', '$_evalue') WHERE $_where;"
}
