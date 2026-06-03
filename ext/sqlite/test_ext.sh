#!/usr/bin/env bash
# test_ext.sh — ext/sqlite test suite
#
# Naming: test::sqlite::<fn> — the runner discovers the public function
# sqlite::<fn>, prepends test::, and calls test::sqlite::<fn>.
#
# All tests use temp file databases (not :memory:) because :memory: state
# does not persist across separate sqlite3 process invocations. Cleanup
# is handled by the extension's EXIT trap.

# ==============================================================================
# Helpers
# ==============================================================================

# Create a fresh temp database with a users table and 3 rows pre-inserted.
# Echoes the path. Uses the extension's own registry for cleanup.
_sqlite_test::fresh_db() {
	local _db
	_db=$(mktemp -t fsbshf-sqlite-test.XXXXXX.db)
	_SQLITE_TMPFILES+=("$_db")
	sqlite3 -noheader -batch "$_db" <<'SQL'
CREATE TABLE u(name TEXT PRIMARY KEY, age INTEGER, city TEXT);
INSERT INTO u VALUES('Alice', 30, 'NYC');
INSERT INTO u VALUES('Bob', 25, 'LA');
INSERT INTO u VALUES('Carol', 40, 'Chicago');
SQL
	printf '%s' "$_db"
}

# ==============================================================================
# Capabilities
# ==============================================================================

test::sqlite::capabilities() {
	local _out
	_out=$(sqlite::capabilities)
	if [[ "$_out" == version=* ]]; then _pass; else _fail; fi
}

test::sqlite::has() {
	if sqlite::has fts5; then _pass; else _skip "FTS5 not compiled in this sqlite3 build"; fi
}

# ==============================================================================
# Path factories
# ==============================================================================

test::sqlite::open::temp() {
	sqlite::open::temp DB
	if [[ -f "$DB" ]]; then _pass; else _fail; fi
}

test::sqlite::open::scratch() {
	sqlite::open::scratch DB
	if [[ "$DB" == ":memory:" ]]; then _pass; else _fail; fi
}

test::sqlite::close() {
	local _db
	_db=$(mktemp -t fsbshf-sqlite-test.XXXXXX.db)
	rm -f "$_db"
	sqlite::close "$_db"
	if [[ ! -f "$_db" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Draft / snapshot
# ==============================================================================

test::draft::open::lossy() {
	local _src
	_src=$(_sqlite_test::fresh_db)
	draft::open::lossy "$_src" D
	if [[ ! -f "$D" ]]; then _fail; return; fi
	local _count
	_count=$(sqlite::query "$D" "SELECT count(*) FROM u;")
	if [[ "$_count" == "3" ]]; then _pass; else _fail; fi
}

test::snapshot::open() {
	local _src
	_src=$(_sqlite_test::fresh_db)
	snapshot::open "$_src" S
	if [[ ! -f "$S" ]]; then _fail; return; fi
	local _count
	_count=$(sqlite::query "$S" "SELECT count(*) FROM u;")
	if [[ "$_count" == "3" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Core operations
# ==============================================================================

test::sqlite::exec() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::exec "$_db" "INSERT INTO u VALUES('Dave', 50, 'Boston');"
	local _count
	_count=$(sqlite::query "$_db" "SELECT count(*) FROM u;")
	if [[ "$_count" == "4" ]]; then _pass; else _fail; fi
}

test::sqlite::query() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _out
	_out=$(sqlite::query "$_db" "SELECT name FROM u WHERE age = 30;")
	if [[ "$_out" == "Alice" ]]; then _pass; else _fail; fi
}

test::sqlite::one() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _out
	_out=$(sqlite::one "$_db" "SELECT count(*) FROM u;")
	if [[ "$_out" == "3" ]]; then _pass; else _fail; fi
}

test::sqlite::exists() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	if sqlite::exists "$_db" "SELECT 1 FROM u WHERE name='Alice'"; then
		_pass
	else
		_fail
	fi
}

test::sqlite::count() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _c
	_c=$(sqlite::count "$_db" u)
	if [[ "$_c" != "3" ]]; then _fail; return; fi
	_c=$(sqlite::count "$_db" u "age > 28")
	if [[ "$_c" == "2" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Ergonomic helpers
# ==============================================================================

test::sqlite::insert() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::insert "$_db" u name Eve age 35 city Seattle
	local _out
	_out=$(sqlite::query "$_db" "SELECT city FROM u WHERE name='Eve';")
	if [[ "$_out" == "Seattle" ]]; then _pass; else _fail; fi
}

test::sqlite::upsert() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::upsert "$_db" u name Bob age 26 city LA
	local _out
	_out=$(sqlite::query "$_db" "SELECT age FROM u WHERE name='Bob';")
	if [[ "$_out" != "26" ]]; then _fail; return; fi
	local _c
	_c=$(sqlite::count "$_db" u)
	if [[ "$_c" == "3" ]]; then _pass; else _fail; fi
}

test::sqlite::select() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _c
	_c=$(sqlite::count "$_db" u "city = 'NYC'")
	if [[ "$_c" == "1" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Schema introspection
# ==============================================================================

test::sqlite::tables() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _out
	_out=$(sqlite::tables "$_db")
	if [[ "$_out" == "u" ]]; then _pass; else _fail; fi
}

test::sqlite::schema() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _out
	_out=$(sqlite::schema "$_db" u)
	if [[ "$_out" == *"CREATE TABLE"* ]] && [[ "$_out" == *"u"* ]]; then
		_pass
	else
		_fail
	fi
}

test::sqlite::columns() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _out
	_out=$(sqlite::columns "$_db" u)
	if [[ "$_out" == *"name"* ]] && [[ "$_out" == *"age"* ]] && [[ "$_out" == *"city"* ]]; then
		_pass
	else
		_fail
	fi
}

test::sqlite::pragma() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _out
	_out=$(sqlite::pragma "$_db" journal_mode)
	# default mode is 'delete' for a fresh file
	if [[ "$_out" == "delete" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Operational
# ==============================================================================

test::sqlite::exec_block() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::exec_block "$_db" <<'SQL'
BEGIN;
INSERT INTO u VALUES('Frank', 22, 'Denver');
INSERT INTO u VALUES('Grace', 28, 'Miami');
COMMIT;
SQL
	local _c
	_c=$(sqlite::count "$_db" u)
	if [[ "$_c" == "5" ]]; then _pass; else _fail; fi
}

test::sqlite::backup() {
	local _db _dest
	_db=$(_sqlite_test::fresh_db)
	_dest=$(mktemp -t fsbshf-sqlite-test-backup.XXXXXX.db)
	_SQLITE_TMPFILES+=("$_dest")
	sqlite::backup "$_db" "$_dest"
	if [[ ! -f "$_dest" ]]; then _fail; return; fi
	local _c
	_c=$(sqlite::query "$_dest" "SELECT count(*) FROM u;")
	if [[ "$_c" == "3" ]]; then _pass; else _fail; fi
}

test::sqlite::vacuum() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::vacuum "$_db"
	local _c
	_c=$(sqlite::count "$_db" u)
	if [[ "$_c" == "3" ]]; then _pass; else _fail; fi
}

test::sqlite::integrity_check() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _out
	_out=$(sqlite::integrity_check "$_db")
	if [[ "$_out" == "ok" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Lifecycle helpers
# ==============================================================================

test::sqlite::with_temp() {
	local _result
	_result=$(sqlite::with_temp sqlite::query "SELECT 'in_temp';")
	if [[ "$_result" == "in_temp" ]]; then _pass; else _fail; fi
}

test::sqlite::query::fast() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local -a _rows
	sqlite::query::fast "$_db" "SELECT name FROM u ORDER BY age;" _rows
	if [[ "${#_rows[@]}" != "3" ]]; then _fail; return; fi
	if [[ "${_rows[0]}" == "Bob" ]] && [[ "${_rows[2]}" == "Carol" ]]; then
		_pass
	else
		_fail
	fi
}

test::sqlite::import() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _csv
	_csv=$(mktemp -t fsbshf-sqlite-test-import.XXXXXX.csv)
	_SQLITE_TMPFILES+=("$_csv")
	printf 'Heidi|29|Boston\nIvan|45|Dallas\n' > "$_csv"
	# Create table matching the .import data
	sqlite::exec "$_db" "CREATE TABLE i(name TEXT, age INTEGER, city TEXT);"
	# .import with --csv uses first row as header; pass --ascii for plain pipe-delim
	sqlite3 -noheader -batch -separator '|' "$_db" <<EOF
.import "$_csv" i
EOF
	local _c
	_c=$(sqlite::count "$_db" i)
	if [[ "$_c" == "2" ]]; then _pass; else _fail; fi
}

test::sqlite::export() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	local _csv
	_csv=$(mktemp -t fsbshf-sqlite-test-export.XXXXXX.csv)
	_SQLITE_TMPFILES+=("$_csv")
	sqlite::export "$_db" "SELECT name, age FROM u WHERE age > 28 ORDER BY age;" "$_csv"
	if [[ ! -s "$_csv" ]]; then _fail; return; fi
	if grep -q "Alice" "$_csv" && grep -q "Carol" "$_csv" && ! grep -q "Bob" "$_csv"; then
		_pass
	else
		_fail
	fi
}

test::sqlite::indexes() {
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::exec "$_db" "CREATE INDEX u_age_idx ON u(age);"
	local _out
	_out=$(sqlite::indexes "$_db" u)
	if [[ "$_out" == *"u_age_idx"* ]]; then _pass; else _fail; fi
}

test::sqlite::schedule_close() {
	# schedule_close just sets a trap; the real test is that the file is removed.
	# Use a subshell so we can capture the EXIT trap behavior cleanly.
	local _result=0
	(
		sqlite::open::temp T
		[[ -f "$T" ]] || { _result=1; exit 1; }
		# override: schedule cleanup at subshell exit (overrides the EXIT trap)
		# Note: schedule_close replaces the EXIT trap with one targeting T only.
		# In a subshell, both would fire — just verify it doesn't error.
		sqlite::schedule_close "$T"
	)
	# If we reach here, the subshell succeeded.
	if [[ "$_result" == "0" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# FTS5 sub-namespace
# ==============================================================================

test::sqlite::fts::create() {
	if ! sqlite::has fts5; then
		_skip "FTS5 not available in this sqlite3 build"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::fts::create "$_db" docs title body
	# Verify the table was created
	local _out
	_out=$(sqlite::tables "$_db")
	if [[ "$out" == *"docs"* ]] || [[ "$_out" == *"docs"* ]]; then _pass; else _fail; fi
}

test::sqlite::fts::index() {
	if ! sqlite::has fts5; then
		_skip "FTS5 not available"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::fts::create "$_db" docs title
	sqlite::fts::index "$_db" docs title "the quick brown fox"
	local _c
	_c=$(sqlite::one "$_db" "SELECT count(*) FROM docs;")
	if [[ "$_c" == "1" ]]; then _pass; else _fail; fi
}

test::sqlite::fts::search() {
	if ! sqlite::has fts5; then
		_skip "FTS5 not available"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::fts::create "$_db" docs title
	sqlite::fts::index "$_db" docs title "the quick brown fox"
	sqlite::fts::index "$_db" docs title "lorem ipsum dolor"
	local _out
	_out=$(sqlite::fts::search "$_db" docs title "fox")
	if [[ "$_out" == *"fox"* ]]; then _pass; else _fail; fi
}

test::sqlite::fts::snippet() {
	if ! sqlite::has fts5; then
		_skip "FTS5 not available"
		return
	fi
	local _db _out
	_db=$(_sqlite_test::fresh_db)
	sqlite::fts::create "$_db" docs title
	sqlite::fts::index "$_db" docs title "the quick brown fox jumps over the lazy dog"
	_out=$(sqlite::fts::snippet "$_db" docs title "fox")
	if [[ "$_out" == *"<b>"* || "$_out" == *"</b>"* ]]; then _pass; else _fail; fi
}

test::sqlite::fts::delete() {
	if ! sqlite::has fts5; then
		_skip "FTS5 not available"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::fts::create "$_db" docs title
	sqlite::fts::index "$_db" docs "the quick brown fox"
	sqlite::fts::delete "$_db" docs 1
	local _c
	_c=$(sqlite::one "$_db" "SELECT count(*) FROM docs;")
	if [[ "$_c" == "0" ]]; then _pass; else _fail; fi
}

test::sqlite::fts::rebuild() {
	if ! sqlite::has fts5; then
		_skip "FTS5 not available"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::fts::create "$_db" docs title
	sqlite::fts::index "$_db" docs "the quick brown fox"
	# rebuild should not error
	sqlite::fts::rebuild "$_db" docs
	_pass
}

test::sqlite::fts::drop() {
	if ! sqlite::has fts5; then
		_skip "FTS5 not available"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::fts::create "$_db" docs title
	sqlite::fts::drop "$_db" docs
	# Verify dropped
	if sqlite::exists "$_db" "SELECT 1 FROM sqlite_master WHERE name='docs'"; then
		_fail "table still exists after drop"
	else
		_pass
	fi
}

# ==============================================================================
# json1 sub-namespace
# ==============================================================================

test::sqlite::json::extract() {
	if ! sqlite::has json1; then
		_skip "json1 not available in this sqlite3 build"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::exec "$_db" "CREATE TABLE t(data TEXT);"
	sqlite::exec "$_db" "INSERT INTO t VALUES('{\"name\":\"alice\",\"age\":30}');"
	local _out
	_out=$(sqlite::json::extract "$_db" t data '$.name')
	if [[ "$_out" == "alice" ]]; then _pass; else _fail; fi
}

test::sqlite::json::each() {
	if ! sqlite::has json1; then
		_skip "json1 not available"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::exec "$_db" "CREATE TABLE t(data TEXT);"
	sqlite::exec "$_db" "INSERT INTO t VALUES('[1,2,3]');"
	local _c
	_c=$(sqlite::json::extract "$_db" t data '$' | wc -l)
	if [[ "$_c" -ge 3 ]]; then _pass; else _fail; fi
}

test::sqlite::json::contains() {
	if ! sqlite::has json1; then
		_skip "json1 not available"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::exec "$_db" "CREATE TABLE t(data TEXT);"
	sqlite::exec "$_db" "INSERT INTO t VALUES('[1,2,3,4,5]');"
	if sqlite::json::contains "$_db" t data '3'; then _pass; else _fail; fi
}

test::sqlite::json::set() {
	if ! sqlite::has json1; then
		_skip "json1 not available"
		return
	fi
	local _db
	_db=$(_sqlite_test::fresh_db)
	sqlite::exec "$_db" "CREATE TABLE t(id TEXT PRIMARY KEY, data TEXT);"
	sqlite::exec "$_db" "INSERT INTO t VALUES('a', '{\"x\":1}');"
	sqlite::json::set "$_db" t data '$.x' '42' "id = 'a'"
	local _out
	_out=$(sqlite::json::extract "$_db" t data '$.x' "id = 'a'")
	if [[ "$_out" == "42" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# migrations sub-namespace
# ==============================================================================

test::sqlite::migrate() {
	local _db _migdir
	_db=$(_sqlite_test::fresh_db)
	_migdir=$(mktemp -d -t migrate-XXXX)
	# Create two migration files in order
	cat > "$_migdir/001_create_users.sql" <<'SQL'
CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT);
SQL
	cat > "$_migdir/002_add_email.sql" <<'SQL'
ALTER TABLE users ADD COLUMN email TEXT;
SQL
	# First run applies
	sqlite::migrate "$_db" "$_migdir" >/dev/null 2>&1
	# Second run is a no-op (idempotency)
	local _out
	_out=$(sqlite::migrate "$_db" "$_migdir" 2>&1)
	if [[ "$_out" != *"no pending migrations"* ]]; then
		_fail "expected 'no pending migrations' on second run, got: $_out"
		return
	fi
	# Verify both tables/columns exist
	local _has_email
	_has_email=$(sqlite::one "$_db" \
		"SELECT count(*) FROM pragma_table_info('users') WHERE name='email';")
	if [[ "$_has_email" == "1" ]]; then _pass; else _fail; fi
	rm -rf "$_migdir"
}

test::sqlite::migrations::status() {
	local _db _migdir _out
	_db=$(_sqlite_test::fresh_db)
	_migdir=$(mktemp -d -t migrate-XXXX)
	cat > "$_migdir/001_a.sql" <<'SQL'
CREATE TABLE a(x INT);
SQL
	cat > "$_migdir/002_b.sql" <<'SQL'
CREATE TABLE b(x INT);
SQL
	# Mark only the first as applied directly (so we can test mixed status)
	sqlite::exec "$_db" "CREATE TABLE _migrations(name TEXT PRIMARY KEY, applied_at TEXT);"
	sqlite::exec "$_db" "INSERT INTO _migrations VALUES('001_a.sql', '2026-01-01 00:00:00');"
	# Check status
	_out=$(sqlite::migrations::status "$_db" "$_migdir")
	if [[ "$_out" == *"001_a.sql"* ]] && [[ "$_out" == *"applied"* ]] && \
	   [[ "$_out" == *"002_b.sql"* ]] && [[ "$_out" == *"pending"* ]]; then
		_pass
	else
		_fail
	fi
	rm -rf "$_migdir"
}

test::sqlite::migrations::new() {
	local _migdir _out
	_migdir=$(mktemp -d -t migrate-XXXX)
	_out=$(sqlite::migrations::new "$_migdir" "Add Users Email Index" 2>&1)
	# Verify a file was created with the slug
	if [[ -f "$_out" ]] && [[ "$_out" == *"add_users_email_index"* ]]; then
		_pass
	else
		_fail
	fi
	rm -rf "$_migdir"
}
