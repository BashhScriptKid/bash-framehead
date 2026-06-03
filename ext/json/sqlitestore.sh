# shellcheck shell=bash
# ext/json/sqlitestore.sh — JSON document store backed by SQLite
#
# Each document is stored as a JSON string in a SQLite table. The table
# is auto-created on first open. Useful for "structured but
# schemaless" persistence — documents can have any shape, queries
# can use json_extract to navigate nested fields.
#
# Loaded by ext/json/json.sh (conditionally, if sqlite3 is available).
#
# Requires: runtime (runtime::has_command), json, sqlite3 (external)

# --- guard ---
declare -f 'json::validate' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: json.sh not found — source it first" >&2
	return 1
}
declare -f 'runtime::has_command' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
	return 1
}
command -v sqlite3 &>/dev/null || {
	echo "${BASH_SOURCE[0]}: requires sqlite3" >&2
	return 1
}
# --- end guard ---

# --- internal ---

# Quote an identifier (table name, column name) for safe interpolation.
_json_sqlitestore::_quote_ident() {
	local _val="$1"
	printf '"%s"' "${_val//\"/\"\"}"
}

# Escape a string value for use inside a single-quoted SQL literal.
_json_sqlitestore::_escape_string() {
	local _val="$1"
	printf '%s' "$_val" | sed "s/'/''/g"
}

# Internal: ensure the store table exists for the given (db, table) pair.
_json_sqlitestore::_ensure_table() {
	local _db="$1" _table="$2"
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	sqlite3 -noheader -batch "$_db" \
		"CREATE TABLE IF NOT EXISTS $_qtable (
			id TEXT PRIMARY KEY,
			data TEXT NOT NULL,
			created_at TEXT DEFAULT (datetime('now')),
			updated_at TEXT DEFAULT (datetime('now'))
		);" 2>/dev/null
}

# ==============================================================================
# PUBLIC API
# ==============================================================================

# Open a SQLite database for use as a JSON document store. Creates the
# store table for <table> if it doesn't exist. No HANDLE — pass <db>
# and <table> to subsequent calls.
#
# Usage: json::sqlitestore::open <path> <table>
json::sqlitestore::open() {
	local _db="$1" _table="$2"
	[[ -n "$_db" ]] || {
		echo "json::sqlitestore::open: path required" >&2
		return 1
	}
	[[ -n "$_table" ]] || {
		echo "json::sqlitestore::open: table required" >&2
		return 1
	}
	# Create the database file if it doesn't exist
	[[ -f "$_db" ]] || sqlite3 -noheader -batch "$_db" "" 2>/dev/null
	_json_sqlitestore::_ensure_table "$_db" "$_table"
}

# Store or replace a JSON document. <json> must be a valid JSON string.
# Usage: json::sqlitestore::put <path> <table> <key> <json>
json::sqlitestore::put() {
	local _db="$1" _table="$2" _key="$3" _json="$4"
	[[ -n "$_key" ]] || {
		echo "json::sqlitestore::put: key required" >&2
		return 1
	}
	[[ -n "$_json" ]] || {
		echo "json::sqlitestore::put: json required" >&2
		return 1
	}
	_json_sqlitestore::_ensure_table "$_db" "$_table"
	local _qtable _ekey _ejson
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ekey=$(_json_sqlitestore::_escape_string "$_key")
	_ejson=$(_json_sqlitestore::_escape_string "$_json")
	sqlite3 -noheader -batch "$_db" \
		"INSERT OR REPLACE INTO $_qtable (id, data, updated_at)
		 VALUES ('$_ekey', '$_ejson', datetime('now'));"
}

# Retrieve a JSON document by key. Prints the JSON string to stdout.
# Returns 1 (no output) if the key doesn't exist.
# Usage: json::sqlitestore::get <path> <table> <key>
json::sqlitestore::get() {
	local _db="$1" _table="$2" _key="$3"
	local _qtable _ekey
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ekey=$(_json_sqlitestore::_escape_string "$_key")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT data FROM $_qtable WHERE id = '$_ekey';"
}

# Delete a document by key. Returns 0 if removed, 1 if not found.
# Usage: json::sqlitestore::delete <path> <table> <key>
json::sqlitestore::delete() {
	local _db="$1" _table="$2" _key="$3"
	local _qtable _ekey
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ekey=$(_json_sqlitestore::_escape_string "$_key")
	sqlite3 -noheader -batch "$_db" \
		"DELETE FROM $_qtable WHERE id = '$_ekey';"
}

# List all keys in the store. One per line.
# Usage: json::sqlitestore::list <path> <table>
json::sqlitestore::list() {
	local _db="$1" _table="$2"
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT id FROM $_qtable ORDER BY id;"
}

# Count documents in the store.
# Usage: json::sqlitestore::count <path> <table>
json::sqlitestore::count() {
	local _db="$1" _table="$2"
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT count(*) FROM $_qtable;"
}

# Query documents by JSON path. <path> is a json_extract path (e.g.
# '$.name', '$.tags[0]'). <value> is the value to match (string compare).
# Prints matching documents' full JSON, one per line.
# Usage: json::sqlitestore::query <path> <table> <json_path> <value>
json::sqlitestore::query() {
	local _db="$1" _table="$2" _jpath="$3" _value="$4"
	[[ -n "$_jpath" ]] || {
		echo "json::sqlitestore::query: json path required" >&2
		return 1
	}
	if ! sqlite3 :memory: "SELECT sqlite_compileoption_used('ENABLE_JSON1');" 2>/dev/null | grep -qx 1; then
		echo "json::sqlitestore::query: requires json1 (not available in this sqlite3 build)" >&2
		return 1
	fi
	local _qtable _ejpath _evalue
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ejpath=$(_json_sqlitestore::_escape_string "$_jpath")
	_evalue=$(_json_sqlitestore::_escape_string "$_value")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT data FROM $_qtable
		 WHERE json_extract(data, '$_ejpath') = '$_evalue';"
}

# Full-text search across JSON documents. Requires FTS5.
# Creates a contentless FTS5 index on first call, keeps it in sync on
# put/delete. <query> uses FTS5 syntax (e.g. 'hello world', 'hello*').
#
# Note: this is a simple "rebuild on every call" implementation. For
# large stores, consider a trigger-based FTS index instead.
# Usage: json::sqlitestore::search <path> <table> <query>
json::sqlitestore::search() {
	local _db="$1" _table="$2" _query="$3"
	[[ -n "$_query" ]] || {
		echo "json::sqlitestore::search: query required" >&2
		return 1
	}
	if ! sqlite3 :memory: "SELECT sqlite_compileoption_used('ENABLE_FTS5');" 2>/dev/null | grep -qx 1; then
		echo "json::sqlitestore::search: FTS5 not available in this sqlite3 build" >&2
		return 1
	fi
	local _qtable _ftstable _equery
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	_ftstable="${_qtable}_fts"
	_equery=$(_json_sqlitestore::_escape_string "$_query")
	# Create FTS5 contentless table if missing
	sqlite3 -noheader -batch "$_db" \
		"CREATE VIRTUAL TABLE IF NOT EXISTS $_ftstable USING fts5(data, content='$_table', content_rowid='rowid');" 2>/dev/null
	# Rebuild index from main table (simple but safe)
	sqlite3 -noheader -batch "$_db" \
		"INSERT INTO $_ftstable($_ftstable) VALUES('rebuild');" 2>/dev/null
	# Search
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT $_qtable.data
		 FROM $_ftstable
		 JOIN $_qtable ON $_qtable.rowid = $_ftstable.rowid
		 WHERE $_ftstable MATCH '$_equery'
		 ORDER BY rank;"
}

# Import a JSON array from a file. Each element becomes a document
# with index-based key ("0", "1", "2", ...).
# Usage: json::sqlitestore::import <path> <table> <file>
json::sqlitestore::import() {
	local _db="$1" _table="$2" _file="$3"
	[[ -r "$_file" ]] || {
		echo "json::sqlitestore::import: cannot read '$_file'" >&2
		return 1
	}
	_json_sqlitestore::_ensure_table "$_db" "$_table"
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	# Use sqlite3's json1 + readfile to ingest a JSON array.
	# Each element is inserted with its array index as the key.
	if ! sqlite3 :memory: "SELECT sqlite_compileoption_used('ENABLE_JSON1');" 2>/dev/null | grep -qx 1; then
		echo "json::sqlitestore::import: requires json1 (not available in this sqlite3 build)" >&2
		return 1
	fi
	sqlite3 -noheader -batch "$_db" <<EOF
DELETE FROM $_qtable;
INSERT INTO $_qtable (id, data)
SELECT
	CAST(json_each.key AS TEXT),
	json_each.value
FROM json_each(readfile('$_file'));
EOF
}

# Export all documents as a JSON array. Prints to stdout.
# Usage: json::sqlitestore::export <path> <table>
json::sqlitestore::export() {
	local _db="$1" _table="$2"
	if ! sqlite3 :memory: "SELECT sqlite_compileoption_used('ENABLE_JSON1');" 2>/dev/null | grep -qx 1; then
		echo "json::sqlitestore::export: requires json1 (not available in this sqlite3 build)" >&2
		return 1
	fi
	local _qtable
	_qtable=$(_json_sqlitestore::_quote_ident "$_table")
	sqlite3 -noheader -batch -list "$_db" \
		"SELECT '[' || group_concat(data, ',') || ']'
		 FROM (SELECT data FROM $_qtable ORDER BY id);"
}
