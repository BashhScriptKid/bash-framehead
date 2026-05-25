#!/usr/bin/env bash
# test_ext.sh — ext/toml test suite

test::toml::to_json() {
    local json

    # basic types
    local toml='name = "test"
port = 3000
debug = true
pi = 3.14
label = "null"'
    json="$(toml::to_json "$toml")"
    _assert_contains "string" '"name":"test"'   "$json"
    _assert_contains "int"    '"port":3000'     "$json"
    _assert_contains "bool"   '"debug":true'    "$json"
    _assert_contains "float"  '"pi":3.14'       "$json"
    _assert_contains "null"   '"label":"null"'  "$json"

    # tables
    toml='[db]
host = "localhost"
port = 5432

[cache]
enabled = true'
    json="$(toml::to_json "$toml")"
    _assert_contains "db host"  '"host":"localhost"' "$json"
    _assert_contains "db port"  '"port":5432'        "$json"
    _assert_contains "cache"    '"enabled":true'     "$json"

    # nested
    json="$(toml::to_json '[a.b.c]'$'\n''key = "deep"')"
    _assert_contains "deep" '"key":"deep"' "$json"

    # dotted keys
    json="$(toml::to_json 'db.host = "localhost"'$'\n''db.port = 5432')"
    _assert_contains "host" '"host":"localhost"' "$json"
    _assert_contains "port" '"port":5432'        "$json"

    # inline table
    json="$(toml::to_json 'point = {x = 1, y = 2}')"
    _assert_contains "x" '"x":1' "$json"
    _assert_contains "y" '"y":2' "$json"

    # array
    json="$(toml::to_json 'ports = [8080, 8081, 8082]')"
    _assert_contains "array" '"ports":[8080,8081,8082]' "$json"

    # mixed root + table
    toml='name = "test"
[db]
host = "localhost"
port = 5432'
    json="$(toml::to_json "$toml")"
    _assert_contains "root"  '"name":"test"'    "$json"
    _assert_contains "db"    '"db":{'           "$json"
    _assert_contains "host"  '"host":"localhost"' "$json"

    _sub_done
}

test::toml::get() {
    declare -f 'json::get' &>/dev/null || { _skip "requires ext/json"; return; }
    local toml='name = "test"
[db]
host = "localhost"
port = 5432'

    _assert "root"    'test'       "$(toml::get "$toml" name)"
    _assert "db.host" 'localhost'  "$(toml::get "$toml" db.host)"
    _assert "db.port" '5432'       "$(toml::get "$toml" db.port)"
    _sub_done
}

test::toml::global() {
    # Comments
    local json
    json="$(toml::to_json '# comment
key = "value" # inline')"
    _assert_contains "comment" '"key":"value"' "$json"

    # Quoted keys
    json="$(toml::to_json '"quoted key" = "yes"')"
    _assert_contains "qkey" '"quoted key":"yes"' "$json"

    # Hex/octal/binary
    json="$(toml::to_json 'hex = 0xFF
oct = 0o777
bin = 0b1010')"
    _assert_contains "hex" '"hex":255'  "$json"
    _assert_contains "oct" '"oct":511'  "$json"
    _assert_contains "bin" '"bin":10'   "$json"

    # Literal string
    json="$(toml::to_json "path = 'simple-path'")"
    _assert_contains "lit" '"path":"simple-path"' "$json"

    # Empty
    _assert "empty" '{}' "$(toml::to_json '')"

    _sub_done
}

test::toml::get_file() {
    declare -f 'json::get' &>/dev/null || { _skip "json extension required"; return; }
    local _tmp="/tmp/fsbshf-test-toml-getfile-$$.toml"
    printf '[db]\nhost = "localhost"\n' > "$_tmp"
    local v; v=$(toml::get_file "$_tmp" "db.host")
    rm -f "$_tmp"
    if [[ "$v" == "localhost" ]]; then _pass; else _fail "got: $v"; fi
}

test::toml::keys() {
    declare -f 'json::keys' &>/dev/null || { _skip "json extension required"; return; }
    local toml=$'[db]\nhost = "localhost"\n[cache]\nhost = "redis"'
    local keys; keys=$(toml::keys "$toml")
    if [[ "$keys" == *"db"* && "$keys" == *"cache"* ]]; then _pass; else _fail "keys: $keys"; fi
}

