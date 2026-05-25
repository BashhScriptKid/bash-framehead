#!/usr/bin/env bash
# test_ext.sh — ext/dotenv test suite

test::dotenv::get() {
    local env='HOST=localhost
PORT=3000
DEBUG=true
NAME="John Doe"
CITY='"'"'New York'"'"'
export VERSION=1.0'

    _assert "simple"    'localhost'  "$(dotenv::get "$env" HOST)"
    _assert "port"      '3000'       "$(dotenv::get "$env" PORT)"
    _assert "bool"      'true'       "$(dotenv::get "$env" DEBUG)"
    _assert "quoted dq" 'John Doe'   "$(dotenv::get "$env" NAME)"
    _assert "quoted sq" 'New York'   "$(dotenv::get "$env" CITY)"
    _assert "exported"  '1.0'        "$(dotenv::get "$env" VERSION)"

    # Inline comments
    local comments='KEY=value # this is a comment'
    _assert "comment" 'value' "$(dotenv::get "$comments" KEY)"

    # Missing key
    if ! dotenv::get "$env" MISSING >/dev/null 2>&1; then
        _sub_pass "missing key"
    else
        _sub_fail "missing key"
    fi

    _sub_done
}

test::dotenv::keys() {
    local env='A=1
B=2
# comment
C=3'

    _assert "keys" $'A\nB\nC' "$(dotenv::keys "$env")"
    _sub_done
}

test::dotenv::get_file() {
    printf 'NAME=test\nPORT=3000\n' > /tmp/dotenv-test.env
    _assert "from file" 'test' "$(dotenv::get_file /tmp/dotenv-test.env NAME)"
    _sub_done
}

test::dotenv::to_json() {
    local env='HOST=localhost
PORT=3000'

    local json
    json="$(dotenv::to_json "$env")"
    _assert_contains "host" '"HOST":"localhost"' "$json"
    _assert_contains "port" '"PORT":"3000"'   "$json"
    _sub_done
}

test::dotenv::global() {
    # Escaped quotes in value
    local esc='MSG="hello \"world\""'
    _assert "escaped dq" 'hello "world"' "$(dotenv::get "$esc" MSG)"

    # Empty value
    local empty='KEY='
    _assert "empty" '' "$(dotenv::get "$empty" KEY)"

    # Multiline value (literal \n in quoted string)
    local ml='LINES="line1\nline2"'
    _assert "multiline" $'line1\nline2' "$(dotenv::get "$ml" LINES)"

    # Tab in value
    local tab='SEP="a\tb"'
    _assert "tab" $'a\tb' "$(dotenv::get "$tab" SEP)"

    # Spaces around =
    local spaces='KEY = value'
    _assert "spaces" 'value' "$(dotenv::get "$spaces" KEY)"

    _sub_done
}

test::dotenv::load() {
    local _tmp="/tmp/fsbshf-test-dotenv-load-$$.env"
    printf 'TEST_HOST=localhost\nTEST_PORT=8080\n' > "$_tmp"
    dotenv::load "$_tmp"
    local ok=0
    [[ "${TEST_HOST:-}" == "localhost" ]] && [[ "${TEST_PORT:-}" == "8080" ]] && ok=1
    rm -f "$_tmp"
    unset TEST_HOST TEST_PORT 2>/dev/null || true
    if (( ok )); then _pass; else _fail "vars not loaded"; fi
}

test::dotenv::load_assoc() {
    local _tmp="/tmp/fsbshf-test-dotenv-loadassoc-$$.env"
    printf 'DB_HOST=db.local\nDB_PORT=5432\n' > "$_tmp"
    local -A cfg
    dotenv::load_assoc "$_tmp" cfg
    local ok=0
    [[ "${cfg[DB_HOST]:-}" == "db.local" ]] && [[ "${cfg[DB_PORT]:-}" == "5432" ]] && ok=1
    rm -f "$_tmp"
    if (( ok )); then _pass; else _fail "assoc not loaded"; fi
}
