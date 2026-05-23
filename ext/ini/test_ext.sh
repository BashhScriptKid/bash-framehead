#!/usr/bin/env bash
# test_ext.sh — ext/ini test suite
#
# Sourced by the test runner after tester.sh and the extension are loaded.
# _pass / _fail / _assert / _assert_contains / _sub_done / _skip are in scope.

# ==============================================================================
# ini::get
# ==============================================================================

test::ini::get() {
    local ini='host=localhost
port=3306
[database]
user=admin
pass=secret
[server]
host=10.0.0.1'

    _assert "global key"        'localhost' "$(ini::get "$ini" host)"
    _assert "global key2"       '3306'      "$(ini::get "$ini" port)"
    _assert "section key"       'admin'     "$(ini::get "$ini" user database)"
    _assert "section key2"      'secret'    "$(ini::get "$ini" pass database)"
    _assert "shadowed key"      '10.0.0.1'  "$(ini::get "$ini" host server)"
    _assert "shadowed key2"     '10.0.0.1'  "$(ini::get "$ini" host server)"

    # Whitespace handling
    local spaced='key =  value with spaces  '
    _assert "spaced value" 'value with spaces' "$(ini::get "$spaced" key)"

    # Quoted values
    local quoted='name="John Doe"
city='"'"'New York'"'"
    _assert "dq value" 'John Doe' "$(ini::get "$quoted" name)"
    _assert "sq value" 'New York' "$(ini::get "$quoted" city)"

    # Inline comments
    local comments='user=root ; admin account
pass=1234 # insecure'
    _assert "semicolon comment" 'root' "$(ini::get "$comments" user)"
    _assert "hash comment"      '1234' "$(ini::get "$comments" pass)"

    # Comment lines and blank lines
    local with_comments='; this is a comment
# another comment

key=value'
    _assert "skip comments" 'value' "$(ini::get "$with_comments" key)"

    _sub_done
}

# ==============================================================================
# ini::sections
# ==============================================================================

test::ini::sections() {
    local ini='[database]
db=mysql
[server]
host=0.0.0.0
[cache]
type=redis'

    _assert "section list" $'database\nserver\ncache' "$(ini::sections "$ini")"
    _sub_done
}

# ==============================================================================
# ini::keys
# ==============================================================================

test::ini::keys() {
    local ini='a=1
b=2
[section]
x=10
y=20'

    _assert "global keys"  $'a\nb' "$(ini::keys "$ini")"
    _assert "section keys" $'x\ny' "$(ini::keys "$ini" section)"
    _sub_done
}

# ==============================================================================
# ini::get_file
# ==============================================================================

test::ini::get_file() {
    printf 'name=cfg\n[db]\nhost=db.local\n' > /tmp/ini-test-file.ini
    _assert "from file" 'db.local' "$(ini::get_file /tmp/ini-test-file.ini host db)"
    _sub_done
}

# ==============================================================================
# ini::to_json
# ==============================================================================

test::ini::to_json() {
    local ini='name=test
port=3000
[db]
host=localhost'

    local json
    json="$(ini::to_json "$ini")"
    _assert_contains "global key in json"  '"name":"test"'   "$json"
    _assert_contains "global key2 in json" '"port":"3000"'   "$json"
    _assert_contains "section in json"     '"db":{'          "$json"
    _assert_contains "section key in json" '"host":"localhost"' "$json"
    _sub_done
}

# ==============================================================================
# ini::global — edge cases
# ==============================================================================

test::ini::global() {
    # Case sensitivity
    local case_ini='Key=value
[key]
Key=section_value'
    _assert "case sensitive global" 'value'         "$(ini::get "$case_ini" Key)"
    _assert "case sensitive section" 'section_value' "$(ini::get "$case_ini" Key key)"

    # Missing key returns error
    if ! ini::get "$case_ini" nonexistent >/dev/null 2>&1; then
        _sub_pass "missing key"
    else
        _sub_fail "missing key"
    fi

    # Section with brackets in name
    local brack='[[section with brackets]]
key=yes'
    _assert "bracketed section" 'yes' "$(ini::get "$brack" key '[section with brackets]')"

    # CRLF line endings
    local crlf=$'[s]\r\nk=v\r\n'
    _assert "crlf" 'v' "$(ini::get "$crlf" k s)"

    # Empty value
    _assert "empty value" '' "$(ini::get 'k=' k)"

    # Empty INI
    _assert "empty ini sections" '' "$(ini::sections '')"

    _sub_done
}
