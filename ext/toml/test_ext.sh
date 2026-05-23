#!/usr/bin/env bash
# test_ext.sh — ext/toml test suite

test::toml::to_json::basic() {
    local toml='name = "test"
port = 3000
debug = true
pi = 3.14
label = "null"'

    local json
    json="$(toml::to_json "$toml")"
    _assert_contains "string" '"name":"test"'   "$json"
    _assert_contains "int"    '"port":3000'     "$json"
    _assert_contains "bool"   '"debug":true'    "$json"
    _assert_contains "float"  '"pi":3.14'       "$json"
    _assert_contains "null"   '"label":"null"'  "$json"
    _sub_done
}

test::toml::to_json::tables() {
    local toml='[db]
host = "localhost"
port = 5432

[cache]
enabled = true'

    local json
    json="$(toml::to_json "$toml")"
    _assert_contains "db host"  '"host":"localhost"' "$json"
    _assert_contains "db port"  '"port":5432'        "$json"
    _assert_contains "cache"    '"enabled":true'     "$json"
    _sub_done
}

test::toml::to_json::nested() {
    local toml='[a.b.c]
key = "deep"'

    local json
    json="$(toml::to_json "$toml")"
    _assert_contains "deep" '"key":"deep"' "$json"
    _sub_done
}

test::toml::to_json::dotted() {
    local toml='db.host = "localhost"
db.port = 5432'

    local json
    json="$(toml::to_json "$toml")"
    _assert_contains "host" '"host":"localhost"' "$json"
    _assert_contains "port" '"port":5432'        "$json"
    _sub_done
}

test::toml::to_json::inline_table() {
    local json
    json="$(toml::to_json 'point = {x = 1, y = 2}')"
    _assert_contains "x" '"x":1' "$json"
    _assert_contains "y" '"y":2' "$json"
    _sub_done
}

test::toml::to_json::array() {
    local json
    json="$(toml::to_json 'ports = [8080, 8081, 8082]')"
    _assert_contains "array" '"ports":[8080,8081,8082]' "$json"
    _sub_done
}

test::toml::to_json::mixed() {
    local toml='name = "test"
[db]
host = "localhost"
port = 5432'

    local json
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
