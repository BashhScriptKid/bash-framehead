#!/usr/bin/env bash
# test_ext.sh — ext/json test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _sub_done / _skip are already in scope.
#
# Public API: all functions take a context (_ctx) as first parameter.
# Usage: local -A _ctx; json::get _ctx "$json" "$path"

# --- Helper: create a fresh context ---
_new_ctx() { local -n _r="$1"; declare -A _r=(); }

# ==============================================================================
# json::get
# ==============================================================================

test::json::get() {
		local -A _ctx
		_new_ctx _ctx; _assert "string"   'hello' "$(json::get _ctx '{"k":"hello"}'   k)"
		_new_ctx _ctx; _assert "number"   '42'    "$(json::get _ctx '{"k":42}'        k)"
		_new_ctx _ctx; _assert "true"     'true'  "$(json::get _ctx '{"k":true}'      k)"
		_new_ctx _ctx; _assert "false"    'false' "$(json::get _ctx '{"k":false}'     k)"
		_new_ctx _ctx; _assert "null"     'null'  "$(json::get _ctx '{"k":null}'      k)"
		_new_ctx _ctx; _assert "negative" '-17'   "$(json::get _ctx '{"k":-17}'       k)"
		_new_ctx _ctx; _assert "float"    '3.14'  "$(json::get _ctx '{"k":3.14}'      k)"
		_new_ctx _ctx; _assert "idx 0"    'a'     "$(json::get _ctx '["a","b","c"]' 0)"
		_new_ctx _ctx; _assert "idx 2"    'c'     "$(json::get _ctx '["a","b","c"]' 2)"
		_new_ctx _ctx; _assert "last"     '30'    "$(json::get _ctx '[10,20,30]' 2)"
		_new_ctx _ctx; _assert "obj.obj"  'deep'  "$(json::get _ctx '{"a":{"b":"deep"}}'  a.b)"
		_new_ctx _ctx; _assert "obj.arr"  '2'     "$(json::get _ctx '{"a":[1,2,3]}'       a.1)"
		_new_ctx _ctx; _assert "arr.obj"  'hi'    "$(json::get _ctx '[{"x":1},{"x":"hi"}]' 1.x)"
		_new_ctx _ctx; _assert "newline"  $'hello\nworld' "$(json::get _ctx '{"m":"hello\nworld"}' m)"
		_new_ctx _ctx; _assert "tab"      $'a\tb'         "$(json::get _ctx '{"m":"a\tb"}'         m)"
		_new_ctx _ctx; _assert "full obj" '{"a":1}' "$(json::get _ctx '{"a":1}' '')"
		_new_ctx _ctx; _assert "full arr" '[1,2]'   "$(json::get _ctx '[1,2]'   '')"
		_sub_done
}

# ==============================================================================
# json::type
# ==============================================================================

test::json::type() {
		local -A _ctx
		_new_ctx _ctx; _assert "object"  'object'  "$(json::type _ctx '{}'          '')"
		_new_ctx _ctx; _assert "array"   'array'   "$(json::type _ctx '[]'          '')"
		_new_ctx _ctx; _assert "string"  'string'  "$(json::type _ctx '{"a":"x"}'   a)"
		_new_ctx _ctx; _assert "number"  'number'  "$(json::type _ctx '{"a":1}'     a)"
		_new_ctx _ctx; _assert "boolean" 'boolean' "$(json::type _ctx '{"a":true}'  a)"
		_new_ctx _ctx; _assert "null"    'null'    "$(json::type _ctx '{"a":null}'  a)"
		_sub_done
}

# ==============================================================================
# json::keys
# ==============================================================================

test::json::keys() {
		local -A _ctx
		_new_ctx _ctx; _assert "obj keys"    $'a\nb\nc' "$(json::keys _ctx '{"a":1,"b":2,"c":3}')"
		_new_ctx _ctx; _assert "arr keys"    $'0\n1\n2' "$(json::keys _ctx '[10,20,30]')"
		_new_ctx _ctx; _assert "empty obj"   ''         "$(json::keys _ctx '{}')"
		_new_ctx _ctx; _assert "empty arr"   ''         "$(json::keys _ctx '[]')"
		_new_ctx _ctx; _assert "nested obj"  $'x\ny'    "$(json::keys _ctx '{"p":{"x":1,"y":2}}' p)"
		_new_ctx _ctx; _assert "nested arr"  $'0\n1'    "$(json::keys _ctx '{"a":[10,20]}' a)"
		_sub_done
}

# ==============================================================================
# json::len
# ==============================================================================

test::json::len() {
		local -A _ctx
		_new_ctx _ctx; _assert "obj"        '3' "$(json::len _ctx '{"a":1,"b":2,"c":3}')"
		_new_ctx _ctx; _assert "arr"        '4' "$(json::len _ctx '[1,2,3,4]')"
		_new_ctx _ctx; _assert "empty obj"  '0' "$(json::len _ctx '{}')"
		_new_ctx _ctx; _assert "empty arr"  '0' "$(json::len _ctx '[]')"
		_new_ctx _ctx; _assert "nested"     '2' "$(json::len _ctx '{"x":[1,2]}' x)"
		_sub_done
}

# ==============================================================================
# json::get_file
# ==============================================================================

test::json::get_file() {
		echo '{"file":"found"}' > /tmp/json-test-file.json
		local -A _ctx; _new_ctx _ctx
		_assert "get_file" 'found' "$(json::get_file _ctx /tmp/json-test-file.json file)"
		_sub_done
}

# ==============================================================================
# json::global — error handling, edge cases
# ==============================================================================

test::json::global() {
		local -A _ctx
		# --- error handling ---
		_new_ctx _ctx
		if ! json::get _ctx '{"a":1}' missing >/dev/null 2>&1; then _sub_pass "missing key"; else _sub_fail "missing key"; fi
		_new_ctx _ctx
		if ! json::type _ctx '{"a":1}' x.y >/dev/null 2>&1; then _sub_pass "bad path"; else _sub_fail "bad path"; fi
		_new_ctx _ctx
		if ! json::get _ctx '[1]' 5 >/dev/null 2>&1;       then _sub_pass "array OOB"; else _sub_fail "array OOB"; fi
		_new_ctx _ctx
		if ! json::len _ctx '"hi"' '' >/dev/null 2>&1;     then _sub_pass "len on scalar"; else _sub_fail "len on scalar"; fi

		_sub_done
}

test::json::validate() {
		local -A _ctx; _new_ctx _ctx
		if json::validate _ctx '{"a":1}'; then _pass; else _fail "valid json rejected"; fi
}

test::json::kv() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"name":"Alice","age":30,"scores":[90,95,100]}'
		local ok=0
		[[ -n "${_ctx[kv_root]:-}" ]] && ok=1
		if (( ok )); then _pass; else _fail "kv context not set"; fi
}

test::json::kv::keys() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"name":"Alice","age":30}'
		local out; out=$(json::kv::keys _ctx)
		if [[ "$out" == *"name"* && "$out" == *"age"* ]]; then _pass; else _fail "keys: $out"; fi
}

test::json::kv::keys::exists() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"name":"Alice","age":30}'
		if json::kv::keys::exists _ctx "name"; then _pass; else _fail "name not found"; fi
}

test::json::kv::keys::remove() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"name":"Alice","age":30}'
		json::kv::keys::remove _ctx "age"
		local out; out=$(json::kv::keys _ctx)
		if [[ "$out" != *"age"* ]]; then _pass; else _fail "age not removed: $out"; fi
}

test::json::kv::keys::rename() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"name":"Alice","age":30}'
		json::kv::keys::rename _ctx "age" "years"
		local out; out=$(json::kv::keys _ctx)
		if [[ "$out" == *"years"* && "$out" != *"age"* ]]; then _pass; else _fail "rename failed: $out"; fi
}

test::json::kv::value::get() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"name":"Alice","age":30}'
		local v; v=$(json::kv::value::get _ctx "name")
		_assert "get name" "Alice" "$v"
		_sub_done
}

test::json::kv::value::set() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"name":"Alice"}'
		json::kv::value::set _ctx "age" "30"
		local v; v=$(json::kv::value::get _ctx "age")
		_assert "set age" "30" "$v"
		_sub_done
}

test::json::kv::value::type() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"name":"Alice","age":30,"active":true,"tags":null}'
		_assert "type string"  "string"  "$(json::kv::value::type _ctx "name")"
		_assert "type number"  "number"  "$(json::kv::value::type _ctx "age")"
		_assert "type boolean" "boolean" "$(json::kv::value::type _ctx "active")"
		_assert "type null"    "null"    "$(json::kv::value::type _ctx "tags")"
		_sub_done
}

test::json::kv::count() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"a":1,"b":2,"c":3}'
		_assert "count 3" "3" "$(json::kv::count _ctx)"
		_sub_done
}

test::json::kv::list() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"name":"Alice","age":30}'
		local out; out=$(json::kv::list _ctx)
		if [[ -n "$out" ]]; then _pass; else _fail "empty list"; fi
}

test::json::kv::at() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"user":{"name":"Alice","scores":[90,95]}}'
		json::kv::at _ctx "user"
		local v; v=$(json::kv::value::get _ctx "name")
		_assert "nested get" "Alice" "$v"
		_sub_done
}

test::json::kv::parent() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"user":{"name":"Alice"}}'
		json::kv::at _ctx "user"
		json::kv::parent _ctx
		local out; out=$(json::kv::keys _ctx)
		if [[ "$out" == *"user"* ]]; then _pass; else _fail "parent failed: $out"; fi
}

test::json::kv::root() {
		local -A _ctx; _new_ctx _ctx
		json::kv _ctx '{"user":{"name":"Alice"}}'
		json::kv::at _ctx "user"
		json::kv::root _ctx
		local out; out=$(json::kv::keys _ctx)
		if [[ "$out" == *"user"* ]]; then _pass; else _fail "root failed: $out"; fi
}

# ==============================================================================
# json::sqlitestore::*
# ==============================================================================
#
# Tests use a temp file database. Cleanup tracked via _SQLITE_TMPFILES so
# the sqlite extension's registry handles removal at script exit.

_json_sqlitestore_test::fresh_db() {
	local _db
	_db=$(mktemp -t fsbshf-json-store-test.XXXXXX.db)
	_SQLITE_TMPFILES+=("$_db")
	printf '%s' "$_db"
}

test::json::sqlitestore::open() {
	local _db
	_db=$(_json_sqlitestore_test::fresh_db)
	json::sqlitestore::open "$_db" docs
	if [[ -f "$_db" ]]; then _pass; else _fail; fi
}

test::json::sqlitestore::put() {
	local _db
	_db=$(_json_sqlitestore_test::fresh_db)
	json::sqlitestore::open "$_db" docs
	json::sqlitestore::put "$_db" docs alice '{"name":"Alice","age":30}'
	local _count
	_count=$(json::sqlitestore::count "$_db" docs)
	if [[ "$_count" == "1" ]]; then _pass; else _fail; fi
}

test::json::sqlitestore::get() {
	local _db
	_db=$(_json_sqlitestore_test::fresh_db)
	json::sqlitestore::open "$_db" docs
	json::sqlitestore::put "$_db" docs alice '{"name":"Alice"}'
	local _out
	_out=$(json::sqlitestore::get "$_db" docs alice)
	if [[ "$_out" == '{"name":"Alice"}' ]]; then _pass; else _fail; fi
}

test::json::sqlitestore::delete() {
	local _db
	_db=$(_json_sqlitestore_test::fresh_db)
	json::sqlitestore::open "$_db" docs
	json::sqlitestore::put "$_db" docs alice '{"name":"Alice"}'
	json::sqlitestore::put "$_db" docs bob '{"name":"Bob"}'
	json::sqlitestore::delete "$_db" docs bob
	local _count
	_count=$(json::sqlitestore::count "$_db" docs)
	if [[ "$_count" == "1" ]]; then _pass; else _fail; fi
}

test::json::sqlitestore::list() {
	local _db
	_db=$(_json_sqlitestore_test::fresh_db)
	json::sqlitestore::open "$_db" docs
	json::sqlitestore::put "$_db" docs alice '{"name":"Alice"}'
	json::sqlitestore::put "$_db" docs bob '{"name":"Bob"}'
	local _out
	_out=$(json::sqlitestore::list "$_db" docs)
	if [[ "$_out" == *"alice"* ]] && [[ "$_out" == *"bob"* ]]; then
		_pass
	else
		_fail
	fi
}

test::json::sqlitestore::count() {
	local _db
	_db=$(_json_sqlitestore_test::fresh_db)
	json::sqlitestore::open "$_db" docs
	json::sqlitestore::put "$_db" docs alice '{"name":"Alice"}'
	json::sqlitestore::put "$_db" docs bob '{"name":"Bob"}'
	json::sqlitestore::put "$_db" docs carol '{"name":"Carol"}'
	local _out
	_out=$(json::sqlitestore::count "$_db" docs)
	if [[ "$_out" == "3" ]]; then _pass; else _fail; fi
}

test::json::sqlitestore::query() {
	if ! sqlite3 :memory: "SELECT sqlite_compileoption_used('ENABLE_JSON1');" 2>/dev/null | grep -qx 1; then
		_skip "json1 not available in this sqlite3 build"
		return
	fi
	local _db
	_db=$(_json_sqlitestore_test::fresh_db)
	json::sqlitestore::open "$_db" docs
	json::sqlitestore::put "$_db" docs alice '{"name":"Alice","age":30}'
	json::sqlitestore::put "$_db" docs bob '{"name":"Bob","age":25}'
	local _out
	_out=$(json::sqlitestore::query "$_db" docs '$.age' '30')
	if [[ "$_out" == *"Alice"* ]]; then _pass; else _fail; fi
}

test::json::sqlitestore::search() {
	if ! sqlite3 :memory: "SELECT sqlite_compileoption_used('ENABLE_FTS5');" 2>/dev/null | grep -qx 1; then
		_skip "FTS5 not available in this sqlite3 build"
		return
	fi
	if ! sqlite3 :memory: "SELECT sqlite_compileoption_used('ENABLE_JSON1');" 2>/dev/null | grep -qx 1; then
		_skip "json1 not available (required for search indexing)"
		return
	fi
	local _db
	_db=$(_json_sqlitestore_test::fresh_db)
	json::sqlitestore::open "$_db" docs
	json::sqlitestore::put "$_db" docs alice '{"name":"Alice","bio":"loves cats"}'
	json::sqlitestore::put "$_db" docs bob '{"name":"Bob","bio":"loves dogs"}'
	local _out
	_out=$(json::sqlitestore::search "$_db" docs 'cats')
	if [[ "$_out" == *"Alice"* ]] && [[ "$_out" != *"Bob"* ]]; then
		_pass
	else
		_fail
	fi
}
