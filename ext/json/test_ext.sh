#!/usr/bin/env bash
# test_ext.sh — ext/json test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _sub_done / _skip are already in scope.

# ==============================================================================
# json::get
# ==============================================================================

test::json::get() {
		_assert "string"   'hello' "$(json::get '{"k":"hello"}'   k)"
		_assert "number"   '42'    "$(json::get '{"k":42}'        k)"
		_assert "true"     'true'  "$(json::get '{"k":true}'      k)"
		_assert "false"    'false' "$(json::get '{"k":false}'     k)"
		_assert "null"     'null'  "$(json::get '{"k":null}'      k)"
		_assert "negative" '-17'   "$(json::get '{"k":-17}'       k)"
		_assert "float"    '3.14'  "$(json::get '{"k":3.14}'      k)"
		_assert "idx 0"    'a'     "$(json::get '["a","b","c"]' 0)"
		_assert "idx 2"    'c'     "$(json::get '["a","b","c"]' 2)"
		_assert "last"     '30'    "$(json::get '[10,20,30]' 2)"
		_assert "obj.obj"  'deep'  "$(json::get '{"a":{"b":"deep"}}'  a.b)"
		_assert "obj.arr"  '2'     "$(json::get '{"a":[1,2,3]}'       a.1)"
		_assert "arr.obj"  'hi'    "$(json::get '[{"x":1},{"x":"hi"}]' 1.x)"
		_assert "newline"  $'hello\nworld' "$(json::get '{"m":"hello\nworld"}' m)"
		_assert "tab"      $'a\tb'         "$(json::get '{"m":"a\tb"}'         m)"
		_assert "full obj" '{"a":1}' "$(json::get '{"a":1}' '')"
		_assert "full arr" '[1,2]'   "$(json::get '[1,2]'   '')"
		_sub_done
}

# ==============================================================================
# json::type
# ==============================================================================

test::json::type() {
		_assert "object"  'object'  "$(json::type '{}'          '')"
		_assert "array"   'array'   "$(json::type '[]'          '')"
		_assert "string"  'string'  "$(json::type '{"a":"x"}'   a)"
		_assert "number"  'number'  "$(json::type '{"a":1}'     a)"
		_assert "boolean" 'boolean' "$(json::type '{"a":true}'  a)"
		_assert "null"    'null'    "$(json::type '{"a":null}'  a)"
		_sub_done
}

# ==============================================================================
# json::keys
# ==============================================================================

test::json::keys() {
		_assert "obj keys"    $'a\nb\nc' "$(json::keys '{"a":1,"b":2,"c":3}')"
		_assert "arr keys"    $'0\n1\n2' "$(json::keys '[10,20,30]')"
		_assert "empty obj"   ''         "$(json::keys '{}')"
		_assert "empty arr"   ''         "$(json::keys '[]')"
		_assert "nested obj"  $'x\ny'    "$(json::keys '{"p":{"x":1,"y":2}}' p)"
		_assert "nested arr"  $'0\n1'    "$(json::keys '{"a":[10,20]}' a)"
		_sub_done
}

# ==============================================================================
# json::len
# ==============================================================================

test::json::len() {
		_assert "obj"        '3' "$(json::len '{"a":1,"b":2,"c":3}')"
		_assert "arr"        '4' "$(json::len '[1,2,3,4]')"
		_assert "empty obj"  '0' "$(json::len '{}')"
		_assert "empty arr"  '0' "$(json::len '[]')"
		_assert "nested"     '2' "$(json::len '{"x":[1,2]}' x)"
		_sub_done
}

# ==============================================================================
# json::get_file
# ==============================================================================

test::json::get_file() {
		echo '{"file":"found"}' > /tmp/json-test-file.json
		_assert "get_file" 'found' "$(json::get_file /tmp/json-test-file.json file)"
		_sub_done
}

# ==============================================================================
# json::global — error handling, edge cases, stress
# ==============================================================================

test::json::global() {
		# --- error handling ---
		if ! json::get '{"a":1}' missing >/dev/null 2>&1; then _sub_pass "missing key"; else _sub_fail "missing key"; fi
		if ! json::type '{"a":1}' x.y >/dev/null 2>&1; then _sub_pass "bad path"; else _sub_fail "bad path"; fi
		if ! json::get '[1]' 5 >/dev/null 2>&1;       then _sub_pass "array OOB"; else _sub_fail "array OOB"; fi
		if ! json::len '"hi"' '' >/dev/null 2>&1;     then _sub_pass "len on scalar"; else _sub_fail "len on scalar"; fi

		_sub_done
}

test::json::validate() {
		if json::validate '{"a":1}'; then _pass; else _fail "valid json rejected"; fi
}

test::json::kv() {
		local j='{"name":"Alice","age":30,"scores":[90,95,100]}'
		json::kv "$j"
		local ok=0
		[[ -n "${_json_kv_root:-}" ]] && ok=1
		if (( ok )); then _pass; else _fail "kv context not set"; fi
}

test::json::kv::keys() {
		local j='{"name":"Alice","age":30}'
		json::kv "$j"
		local out; out=$(json::kv::keys)
		if [[ "$out" == *"name"* && "$out" == *"age"* ]]; then _pass; else _fail "keys: $out"; fi
}

test::json::kv::keys::exists() {
		local j='{"name":"Alice","age":30}'
		json::kv "$j"
		if json::kv::keys::exists "name"; then _pass; else _fail "name not found"; fi
}

test::json::kv::keys::remove() {
		local j='{"name":"Alice","age":30}'
		json::kv "$j"
		json::kv::keys::remove "age"
		local out; out=$(json::kv::keys)
		if [[ "$out" != *"age"* ]]; then _pass; else _fail "age not removed: $out"; fi
}

test::json::kv::keys::rename() {
		local j='{"name":"Alice","age":30}'
		json::kv "$j"
		json::kv::keys::rename "age" "years"
		local out; out=$(json::kv::keys)
		if [[ "$out" == *"years"* && "$out" != *"age"* ]]; then _pass; else _fail "rename failed: $out"; fi
}

test::json::kv::value::get() {
		local j='{"name":"Alice","age":30}'
		json::kv "$j"
		local v; v=$(json::kv::value::get "name")
		_assert "get name" "Alice" "$v"
		_sub_done
}

test::json::kv::value::set() {
		local j='{"name":"Alice"}'
		json::kv "$j"
		json::kv::value::set "age" "30"
		local v; v=$(json::kv::value::get "age")
		_assert "set age" "30" "$v"
		_sub_done
}

test::json::kv::value::type() {
		local j='{"name":"Alice","age":30,"active":true,"tags":null}'
		json::kv "$j"
		_assert "type string"  "string"  "$(json::kv::value::type "name")"
		_assert "type number"  "number"  "$(json::kv::value::type "age")"
		_assert "type boolean" "boolean" "$(json::kv::value::type "active")"
		_assert "type null"    "null"    "$(json::kv::value::type "tags")"
		_sub_done
}

test::json::kv::count() {
		local j='{"a":1,"b":2,"c":3}'
		json::kv "$j"
		_assert "count 3" "3" "$(json::kv::count)"
		_sub_done
}

test::json::kv::list() {
		local j='{"name":"Alice","age":30}'
		json::kv "$j"
		local out; out=$(json::kv::list)
		if [[ -n "$out" ]]; then _pass; else _fail "empty list"; fi
}

test::json::kv::at() {
		local j='{"user":{"name":"Alice","scores":[90,95]}}'
		json::kv "$j"
		json::kv::at "user"
		local v; v=$(json::kv::value::get "name")
		_assert "nested get" "Alice" "$v"
		_sub_done
}

test::json::kv::parent() {
		local j='{"user":{"name":"Alice"}}'
		json::kv "$j"
		json::kv::at "user"
		json::kv::parent
		local out; out=$(json::kv::keys)
		if [[ "$out" == *"user"* ]]; then _pass; else _fail "parent failed: $out"; fi
}

test::json::kv::root() {
		local j='{"user":{"name":"Alice"}}'
		json::kv "$j"
		json::kv::at "user"
		json::kv::root
		local out; out=$(json::kv::keys)
		if [[ "$out" == *"user"* ]]; then _pass; else _fail "root failed: $out"; fi
}
