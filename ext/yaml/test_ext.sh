#!/usr/bin/env bash
# test_ext.sh — ext/yaml test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _assert_contains / _sub_done / _skip are in scope.
#
# Naming: test::yaml::<fn> matches the public function yaml::<fn>.

# ==============================================================================
# yaml::to_json
# ==============================================================================

test::yaml::to_json() {
    local json

    # Simple map
    json="$(yaml::to_json $'name: test\nport: 3000')"
    _assert_contains "simple name"   '"name":"test"' "$json"
    _assert_contains "simple port"   '"port":3000'   "$json"

    # Nested map
    json="$(yaml::to_json $'server:\n  host: localhost\n  port: 8080')"
    _assert_contains "nested host" '"host":"localhost"' "$json"
    _assert_contains "nested port" '"port":8080'        "$json"

    # Deeply nested
    json="$(yaml::to_json $'a:\n  b:\n    c: deep')"
    _assert_contains "deep" '"c":"deep"' "$json"

    # Sequence
    json="$(yaml::to_json $'fruits:\n  - apple\n  - banana')"
    _assert_contains "array" '["apple","banana"]' "$json"

    # Sequence of objects
    json="$(yaml::to_json $'users:\n  - name: Alice\n    age: 30\n  - name: Bob\n    age: 25')"
    _assert_contains "alice" '"name":"Alice","age":30' "$json"
    _assert_contains "bob"   '"name":"Bob","age":25'   "$json"

    # Top-level sequence
    json="$(yaml::to_json $'- red\n- green\n- blue')"
    _assert_contains "toplevel" '["red","green","blue"]' "$json"

    # Types
    json="$(yaml::to_json $'debug: true\nretries: 5\npi: 3.14\nlabel: null\nflag: yes\noff: false')"
    _assert_contains "bool"   '"debug":true' "$json"
    _assert_contains "int"    '"retries":5'  "$json"
    _assert_contains "float"  '"pi":3.14'    "$json"
    _assert_contains "null"   '"label":null' "$json"
    _assert_contains "yes"    '"flag":true'  "$json"
    _assert_contains "off"    '"off":false'  "$json"

    # Quoted strings
    json="$(yaml::to_json $'name: "John Doe"\ncity: '"'"'New York'"'"'')"
    _assert_contains "dq" '"name":"John Doe"' "$json"
    _assert_contains "sq" '"city":"New York"' "$json"

    # Comments
    json="$(yaml::to_json $'# header\nkey: value # inline\nport: 3000')"
    _assert_contains "cmt key"  '"key":"value"' "$json"
    _assert_contains "cmt port" '"port":3000'   "$json"

    _sub_done
}

# ==============================================================================
# yaml::get
# ==============================================================================

test::yaml::get() {
    # yaml::get requires the json extension — ensure it's loaded
    declare -f 'json::get' &>/dev/null || {
        _skip "requires ext/json (not loaded by test runner for ext/yaml)"
        return
    }

    local yaml=$'server:\n  host: localhost\n  port: 8080\n  features:\n    - ssl\n    - gzip'

    _assert "simple" 'localhost' "$(yaml::get "$yaml" server.host)"
    _assert "int"    '8080'      "$(yaml::get "$yaml" server.port)"
    _assert "array 0" 'ssl'     "$(yaml::get "$yaml" server.features.0)"
    _sub_done
}

# ==============================================================================
# yaml::global — edge cases
# ==============================================================================

test::yaml::global() {
    local json

    # Empty
    _assert "empty" '{}' "$(yaml::to_json '')"

    # Null value
    json="$(yaml::to_json 'key: ~')"
    _assert_contains "null" '"key":null' "$json"

    # Quoted key
    json="$(yaml::to_json '"quoted key": yes')"
    _assert_contains "qkey" '"quoted key":true' "$json"

    # Complex nested
    json="$(yaml::to_json $'app: myapp\nserver:\n  host: 0.0.0.0\n  port: 8080\n  features:\n    - ssl\n    - gzip\ndatabase:\n  primary:\n    host: db1.local\n    port: 5432\n  replicas:\n    - host: rep1.local\n    - host: rep2.local')"
    _assert_contains "app"      '"app":"myapp"'     "$json"
    _assert_contains "server"   '"server":{'        "$json"
    _assert_contains "features" '"features":["ssl","gzip"]' "$json"
    _assert_contains "primary"  '"primary":{"host":"db1.local","port":5432}' "$json"
    _assert_contains "rep2"     '"host":"rep2.local"' "$json"

    _sub_done
}
