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
