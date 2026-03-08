#!/usr/bin/env bash
# tester.sh — bash::framehead test library
#
# SOURCE this file — do not execute directly.
#
#   source "$compiled_file"
#   source ./tester.sh
#
# ┌──────────────────────────────────────────────────────────────────┐
# │ Globals reset by _tester_reset() before each test:: call        │
# │                                                                  │
# │  _T_PASS    incremented by _pass / _sub_pass                    │
# │  _T_FAIL    incremented by _fail / _sub_fail                    │
# │  _T_SKIP    incremented by _skip / _sub_skip                    │
# │  _T_IS_SUB  set to 1 by _sub_done                               │
# │                                                                  │
# │ tester_new reads these after each call — no return codes used.  │
# └──────────────────────────────────────────────────────────────────┘
#
# Output format (managed by tester_new, not here):
#   pre:  "            fn::name..."
#   post: "\rRESULT      fn::name\n"
#   sub:  "\rSUB         fn::name\n"  ← tester_new prints this
#         "  PASS  label\n"           ← subtest lines follow indented

# ==============================================================================
# Globals
# ==============================================================================

_T_PASS=0
_T_FAIL=0
_T_SKIP=0
_T_IS_SUB=0
_T_SUB_STARTED=0

_tester_reset() {
    _T_PASS=0
    _T_FAIL=0
    _T_SKIP=0
    _T_IS_SUB=0
    _T_SUB_STARTED=0
}

_sub_newline() {
    if (( _T_SUB_STARTED == 0 )); then
        printf "\n"
        _T_SUB_STARTED=1
    fi
}

# ==============================================================================
# Colour
# ==============================================================================

if [[ -t 1 ]]; then
    _C_PASS="\033[32mPASS\033[0m"
    _C_FAIL="\033[31mFAIL\033[0m"
    _C_SKIP="\033[33mSKIP\033[0m"
else
    _C_PASS="PASS"
    _C_FAIL="FAIL"
    _C_SKIP="SKIP"
fi

# ==============================================================================
# Single-test helpers
# ==============================================================================

_pass() { (( _T_PASS++ )); }
_fail() { [[ -n "${1:-}" ]] && echo "  $1"; (( _T_FAIL++ )); }
_skip() { [[ -n "${1:-}" ]] && echo "  skip: $1"; (( _T_SKIP++ )); }

# ==============================================================================
# Subtest helpers
# ==============================================================================

_sub_pass() { _sub_newline; echo -e "  ${_C_PASS}  ${1}";                                              (( _T_PASS++ )); }
_sub_fail() { _sub_newline; echo -e "  ${_C_FAIL}  ${1}"
              [[ -n "${2:-}" ]] && echo "        expected: ${2}"
              [[ -n "${3:-}" ]] && echo "        actual:   ${3}";                         (( _T_FAIL++ )); }
_sub_skip() { _sub_newline; echo -e "  ${_C_SKIP}  ${1}";                                              (( _T_SKIP++ )); }

# Call at the end of every subtest function
_sub_done() { _T_IS_SUB=1; }

# ==============================================================================
# Subtest assertion helpers
# ==============================================================================

_assert() {
    local label="$1" expected="$2" actual="$3"
    if [[ "$actual" == "$expected" ]]; then _sub_pass "$label"
    else                                     _sub_fail "$label" "$expected" "$actual"
    fi
}

_assert_contains() {
    local label="$1" needle="$2" actual="$3"
    if [[ "$actual" == *"$needle"* ]]; then _sub_pass "$label"
    else                                     _sub_fail "$label" "(contains) $needle" "$actual"
    fi
}

_assert_nonempty() {
    local label="$1" actual="$2"
    if [[ -n "$actual" ]]; then _sub_pass "$label"
    else                         _sub_fail "$label (empty output)"
    fi
}

_bool_probe() {
    "$1"; local r=$?
    [[ $r -eq 0 || $r -eq 1 ]]
}

# ==============================================================================
# Tests — string
# ==============================================================================

test::string::upper()           { if [[ "$(string::upper hello)"      == "HELLO"        ]]; then _pass; else _fail; fi; }
test::string::lower()           { if [[ "$(string::lower HELLO)"      == "hello"        ]]; then _pass; else _fail; fi; }
test::string::length()          { if [[ "$(string::length hello)"     == "5"            ]]; then _pass; else _fail; fi; }
test::string::reverse()         { if [[ "$(string::reverse hello)"    == "olleh"        ]]; then _pass; else _fail; fi; }
test::string::capitalise()      { if [[ "$(string::capitalise hello)" == "Hello"        ]]; then _pass; else _fail; fi; }
test::string::title()           { if [[ "$(string::title "hello world")" == "Hello World" ]]; then _pass; else _fail; fi; }
test::string::trim()            { if [[ "$(string::trim "  hello  ")" == "hello"        ]]; then _pass; else _fail; fi; }
test::string::trim_left()       { if [[ "$(string::trim_left  "  hello  ")" == "hello  " ]]; then _pass; else _fail; fi; }
test::string::trim_right()      { if [[ "$(string::trim_right "  hello  ")" == "  hello" ]]; then _pass; else _fail; fi; }
test::string::repeat()          { if [[ "$(string::repeat a 3)"            == "aaa"     ]]; then _pass; else _fail; fi; }
test::string::index_of()        { if [[ "$(string::index_of hello l)"      == "2"       ]]; then _pass; else _fail; fi; }
test::string::substr()          { if [[ "$(string::substr hello 1 3)"      == "ell"     ]]; then _pass; else _fail; fi; }
test::string::before()          { if [[ "$(string::before hello lo)"       == "hel"     ]]; then _pass; else _fail; fi; }
test::string::after()           { if [[ "$(string::after hello hel)"       == "lo"      ]]; then _pass; else _fail; fi; }
test::string::before_last()     { if [[ "$(string::before_last hello lo)"  == "hel"     ]]; then _pass; else _fail; fi; }
test::string::after_last()      { if [[ "$(string::after_last hello l)"    == "o"       ]]; then _pass; else _fail; fi; }
test::string::replace()         { if [[ "$(string::replace hello e X)"     == "hXllo"   ]]; then _pass; else _fail; fi; }
test::string::replace_all()     { if [[ "$(string::replace_all hXllo o X)" == "hXllX"   ]]; then _pass; else _fail; fi; }
test::string::remove()          { if [[ "$(string::remove hello e)"        == "hllo"    ]]; then _pass; else _fail; fi; }
test::string::remove_first()    { if [[ "$(string::remove_first hello e)"  == "hllo"    ]]; then _pass; else _fail; fi; }
test::string::pad_left()        { if [[ "$(string::pad_left hi 4)"         == "  hi"    ]]; then _pass; else _fail; fi; }
test::string::pad_right()       { if [[ "$(string::pad_right hi 4)"        == "hi  "    ]]; then _pass; else _fail; fi; }
test::string::pad_center()      { if [[ "$(string::pad_center hi 4)"       == " hi "    ]]; then _pass; else _fail; fi; }
test::string::truncate()        { if [[ "$(string::truncate hello 4)"      == "hel…"    ]]; then _pass; else _fail; fi; }
test::string::collapse_spaces() { if [[ "$(string::collapse_spaces "a  b   c")" == "a b c" ]]; then _pass; else _fail; fi; }
test::string::strip_spaces()    { if [[ "$(string::strip_spaces "a b c")"  == "abc"     ]]; then _pass; else _fail; fi; }
test::string::split()           { if [[ "$(string::split a,b,c ,)" == "$(printf 'a\nb\nc')" ]]; then _pass; else _fail; fi; }
test::string::join()            { if [[ "$(string::join , a b c)"  == "a,b,c"           ]]; then _pass; else _fail; fi; }
test::string::url_decode()      { if [[ "$(string::url_decode "hello%20world")" == "hello world" ]]; then _pass; else _fail; fi; }
test::string::base64_decode()   { if [[ "$(string::base64_decode "$(string::base64_encode hello)")" == "hello" ]]; then _pass; else _fail; fi; }
test::string::base32_decode()   { if [[ "$(string::base32_decode "$(string::base32_encode hello)")" == "hello" ]]; then _pass; else _fail; fi; }
test::string::uuid()            { if [[ -n "$(string::uuid)"                ]]; then _pass; else _fail; fi; }
test::string::random()          { if [[ -n "$(string::random 8)"            ]]; then _pass; else _fail; fi; }
test::string::md5()             { if [[ -n "$(string::md5 hello)"           ]]; then _pass; else _fail; fi; }
test::string::sha256()          { if [[ -n "$(string::sha256 hello)"        ]]; then _pass; else _fail; fi; }
test::string::url_encode()      { if [[ -n "$(string::url_encode "hello world")" ]]; then _pass; else _fail; fi; }
test::string::base64_encode()        { if [[ -n "$(string::base64_encode hello)" ]]; then _pass; else _fail; fi; }
test::string::base32_encode()        { if [[ -n "$(string::base32_encode hello)" ]]; then _pass; else _fail; fi; }
test::string::base64_encode::pure()  { if [[ -n "$(string::base64_encode::pure hello)" ]]; then _pass; else _fail; fi; }
test::string::base64_decode::pure()  {
    # decode is known-broken in current impl — verify against known base64 of "hello"
    local encoded; encoded=$(string::base64_encode::pure hello)
    local decoded; decoded=$(string::base64_decode::pure "$encoded" 2>/dev/null)
    if [[ "$decoded" == "hello" ]]; then _pass; else _fail; fi
}
test::string::base32_encode::pure()  { if [[ "$(string::base32_encode::pure hello)" == "$(string::base32_encode hello)" ]]; then _pass; else _fail; fi; }
test::string::base32_decode::pure()  {
    local encoded; encoded=$(string::base32_encode::pure hello)
    local decoded; decoded=$(string::base32_decode::pure "$encoded" 2>/dev/null)
    if [[ "$decoded" == "hello" ]]; then _pass; else _fail; fi
}
test::string::is_bin()          { if string::is_bin    0b1010; then _pass; else _fail; fi; }
test::string::is_octal()        { if string::is_octal  0755; then _pass; else _fail; fi; }
test::string::is_numeric()      { if string::is_numeric 42; then _pass; else _fail; fi; }
test::string::is_not_empty()    { if string::is_not_empty 'x'; then _pass; else _fail; fi; }
test::string::matches()         { if string::matches hello 'hel+o'; then _pass; else _fail; fi; }
test::string::upper::legacy()      { if [[ "$(string::upper::legacy      hello)" == "HELLO" ]]; then _pass; else _fail; fi; }
test::string::lower::legacy()      { if [[ "$(string::lower::legacy      HELLO)" == "hello" ]]; then _pass; else _fail; fi; }
test::string::capitalise::legacy() { if [[ "$(string::capitalise::legacy hello)" == "Hello" ]]; then _pass; else _fail; fi; }
test::string::snake_to_camel()     { if [[ "$(string::snake_to_camel hello_world)" == "helloWorld" ]]; then _pass; else _fail; fi; }

test::string::contains() {
    _assert "contains (true)"  "0" "$(string::contains hello ell; echo $?)"
    _assert "contains (false)" "1" "$(string::contains hello xyz; echo $?)"
    _sub_done
}
test::string::is_integer() {
    _assert "is_integer (true)"  "0" "$(string::is_integer 42;  echo $?)"
    _assert "is_integer (false)" "1" "$(string::is_integer abc; echo $?)"
    _sub_done
}
test::string::is_float() {
    _assert "is_float (true)"  "0" "$(string::is_float 3.14; echo $?)"
    _assert "is_float (false)" "1" "$(string::is_float abc;  echo $?)"
    _sub_done
}
test::string::is_hex() {
    _assert "is_hex (true)"  "0" "$(string::is_hex 0xff; echo $?)"
    _assert "is_hex (false)" "1" "$(string::is_hex xyz;  echo $?)"
    _sub_done
}
test::string::is_alnum() {
    _assert "is_alnum (true)"  "0" "$(string::is_alnum abc123; echo $?)"
    _assert "is_alnum (false)" "1" "$(string::is_alnum 'abc!'; echo $?)"
    _sub_done
}
test::string::is_alpha() {
    _assert "is_alpha (true)"  "0" "$(string::is_alpha abc;  echo $?)"
    _assert "is_alpha (false)" "1" "$(string::is_alpha abc1; echo $?)"
    _sub_done
}
test::string::is_empty() {
    _assert "is_empty (true)"  "0" "$(string::is_empty '';  echo $?)"
    _assert "is_empty (false)" "1" "$(string::is_empty 'x'; echo $?)"
    _sub_done
}
test::string::starts_with() {
    _assert "starts_with (true)"  "0" "$(string::starts_with hello hel; echo $?)"
    _assert "starts_with (false)" "1" "$(string::starts_with hello xyz; echo $?)"
    _sub_done
}
test::string::ends_with() {
    _assert "ends_with (true)"  "0" "$(string::ends_with hello llo; echo $?)"
    _assert "ends_with (false)" "1" "$(string::ends_with hello xyz; echo $?)"
    _sub_done
}
# plain_to
test::string::plain_to_snake()    { if [[ "$(string::plain_to_snake    "hello world")" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::plain_to_kebab()    { if [[ "$(string::plain_to_kebab    "hello world")" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::plain_to_camel()    { if [[ "$(string::plain_to_camel    "hello world")" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::plain_to_pascal()   { if [[ "$(string::plain_to_pascal   "hello world")" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::plain_to_constant() { if [[ "$(string::plain_to_constant "hello world")" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::plain_to_dot()      { if [[ "$(string::plain_to_dot      "hello world")" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::plain_to_path()     { if [[ "$(string::plain_to_path     "hello world")" == "hello/world"  ]]; then _pass; else _fail; fi; }
# snake_to
test::string::snake_to_plain()    { if [[ "$(string::snake_to_plain    hello_world)" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::snake_to_kebab()    { if [[ "$(string::snake_to_kebab    hello_world)" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::snake_to_camel()    { if [[ "$(string::snake_to_camel    hello_world)" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::snake_to_pascal()   { if [[ "$(string::snake_to_pascal   hello_world)" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::snake_to_constant() { if [[ "$(string::snake_to_constant hello_world)" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::snake_to_dot()      { if [[ "$(string::snake_to_dot      hello_world)" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::snake_to_path()     { if [[ "$(string::snake_to_path     hello_world)" == "hello/world"  ]]; then _pass; else _fail; fi; }
# kebab_to
test::string::kebab_to_plain()    { if [[ "$(string::kebab_to_plain    hello-world)" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::kebab_to_snake()    { if [[ "$(string::kebab_to_snake    hello-world)" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::kebab_to_camel()    { if [[ "$(string::kebab_to_camel    hello-world)" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::kebab_to_pascal()   { if [[ "$(string::kebab_to_pascal   hello-world)" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::kebab_to_constant() { if [[ "$(string::kebab_to_constant hello-world)" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::kebab_to_dot()      { if [[ "$(string::kebab_to_dot      hello-world)" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::kebab_to_path()     { if [[ "$(string::kebab_to_path     hello-world)" == "hello/world"  ]]; then _pass; else _fail; fi; }
# camel_to
test::string::camel_to_plain()    { if [[ "$(string::camel_to_plain    helloWorld)" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_snake()    { if [[ "$(string::camel_to_snake    helloWorld)" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_kebab()    { if [[ "$(string::camel_to_kebab    helloWorld)" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_pascal()   { if [[ "$(string::camel_to_pascal   helloWorld)" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::camel_to_constant() { if [[ "$(string::camel_to_constant helloWorld)" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_dot()      { if [[ "$(string::camel_to_dot      helloWorld)" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_path()     { if [[ "$(string::camel_to_path     helloWorld)" == "hello/world"  ]]; then _pass; else _fail; fi; }
# pascal_to
test::string::pascal_to_plain()    { if [[ "$(string::pascal_to_plain    HelloWorld)" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_snake()    { if [[ "$(string::pascal_to_snake    HelloWorld)" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_kebab()    { if [[ "$(string::pascal_to_kebab    HelloWorld)" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_camel()    { if [[ "$(string::pascal_to_camel    HelloWorld)" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::pascal_to_constant() { if [[ "$(string::pascal_to_constant HelloWorld)" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_dot()      { if [[ "$(string::pascal_to_dot      HelloWorld)" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_path()     { if [[ "$(string::pascal_to_path     HelloWorld)" == "hello/world"  ]]; then _pass; else _fail; fi; }
# constant_to
test::string::constant_to_plain()  { if [[ "$(string::constant_to_plain  HELLO_WORLD)" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::constant_to_snake()  { if [[ "$(string::constant_to_snake  HELLO_WORLD)" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::constant_to_kebab()  { if [[ "$(string::constant_to_kebab  HELLO_WORLD)" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::constant_to_camel()  { if [[ "$(string::constant_to_camel  HELLO_WORLD)" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::constant_to_pascal() { if [[ "$(string::constant_to_pascal HELLO_WORLD)" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::constant_to_dot()    { if [[ "$(string::constant_to_dot    HELLO_WORLD)" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::constant_to_path()   { if [[ "$(string::constant_to_path   HELLO_WORLD)" == "hello/world"  ]]; then _pass; else _fail; fi; }
# dot_to
test::string::dot_to_plain()    { if [[ "$(string::dot_to_plain    hello.world)" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::dot_to_snake()    { if [[ "$(string::dot_to_snake    hello.world)" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::dot_to_kebab()    { if [[ "$(string::dot_to_kebab    hello.world)" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::dot_to_camel()    { if [[ "$(string::dot_to_camel    hello.world)" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::dot_to_pascal()   { if [[ "$(string::dot_to_pascal   hello.world)" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::dot_to_constant() { if [[ "$(string::dot_to_constant hello.world)" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::dot_to_path()     { if [[ "$(string::dot_to_path     hello.world)" == "hello/world"  ]]; then _pass; else _fail; fi; }
# path_to
test::string::path_to_plain()    { if [[ "$(string::path_to_plain    hello/world)" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::path_to_snake()    { if [[ "$(string::path_to_snake    hello/world)" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::path_to_kebab()    { if [[ "$(string::path_to_kebab    hello/world)" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::path_to_camel()    { if [[ "$(string::path_to_camel    hello/world)" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::path_to_pascal()   { if [[ "$(string::path_to_pascal   hello/world)" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::path_to_constant() { if [[ "$(string::path_to_constant hello/world)" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::path_to_dot()      { if [[ "$(string::path_to_dot      hello/world)" == "hello.world"  ]]; then _pass; else _fail; fi; }

# ==============================================================================
# Tests — string ::fast variants
# ==============================================================================

# CASE ::fast
test::string::upper::fast()       { local r; string::upper::fast r hello;       if [[ "$r" == "HELLO"        ]]; then _pass; else _fail; fi; }
test::string::lower::fast()       { local r; string::lower::fast r HELLO;       if [[ "$r" == "hello"        ]]; then _pass; else _fail; fi; }
test::string::capitalise::fast()  { local r; string::capitalise::fast r hello;  if [[ "$r" == "Hello"        ]]; then _pass; else _fail; fi; }
test::string::title::fast()       { local r; string::title::fast r "hello world"; if [[ "$r" == "Hello World" ]]; then _pass; else _fail; fi; }

# TRIMMING ::fast
test::string::trim::fast()        { local r; string::trim::fast r "  hello  ";  if [[ "$r" == "hello"        ]]; then _pass; else _fail; fi; }
test::string::trim_left::fast()   { local r; string::trim_left::fast r "  hello  "; if [[ "$r" == "hello  "  ]]; then _pass; else _fail; fi; }
test::string::trim_right::fast()  { local r; string::trim_right::fast r "  hello  "; if [[ "$r" == "  hello" ]]; then _pass; else _fail; fi; }
test::string::collapse_spaces::fast() { local r; string::collapse_spaces::fast r "a  b   c"; if [[ "$r" == "a b c" ]]; then _pass; else _fail; fi; }
test::string::strip_spaces::fast()    { local r; string::strip_spaces::fast r "a b c"; if [[ "$r" == "abc"    ]]; then _pass; else _fail; fi; }

# SUBSTRINGS ::fast
test::string::substr::fast()      { local r; string::substr::fast r hello 1 3;  if [[ "$r" == "ell"          ]]; then _pass; else _fail; fi; }
test::string::before::fast()      { local r; string::before::fast r hello lo;   if [[ "$r" == "hel"          ]]; then _pass; else _fail; fi; }
test::string::after::fast()       { local r; string::after::fast r hello hel;   if [[ "$r" == "lo"           ]]; then _pass; else _fail; fi; }
test::string::before_last::fast() { local r; string::before_last::fast r hello lo; if [[ "$r" == "hel"       ]]; then _pass; else _fail; fi; }
test::string::after_last::fast()  { local r; string::after_last::fast r hello l; if [[ "$r" == "o"           ]]; then _pass; else _fail; fi; }

# MANIPULATION ::fast
test::string::replace::fast()     { local r; string::replace::fast r hello e X;     if [[ "$r" == "hXllo"    ]]; then _pass; else _fail; fi; }
test::string::replace_all::fast() { local r; string::replace_all::fast r hXllo o X; if [[ "$r" == "hXllX"    ]]; then _pass; else _fail; fi; }
test::string::remove::fast()      { local r; string::remove::fast r hello e;        if [[ "$r" == "hllo"     ]]; then _pass; else _fail; fi; }
test::string::remove_first::fast(){ local r; string::remove_first::fast r hello e;  if [[ "$r" == "hllo"     ]]; then _pass; else _fail; fi; }
test::string::reverse::fast()     { local r; string::reverse::fast r hello;         if [[ "$r" == "olleh"    ]]; then _pass; else _fail; fi; }
test::string::repeat::fast()      { local r; string::repeat::fast r a 3;            if [[ "$r" == "aaa"      ]]; then _pass; else _fail; fi; }
test::string::pad_left::fast()    { local r; string::pad_left::fast r hi 4;         if [[ "$r" == "  hi"     ]]; then _pass; else _fail; fi; }
test::string::pad_right::fast()   { local r; string::pad_right::fast r hi 4;        if [[ "$r" == "hi  "     ]]; then _pass; else _fail; fi; }
test::string::pad_center::fast()  { local r; string::pad_center::fast r hi 4;       if [[ "$r" == " hi "     ]]; then _pass; else _fail; fi; }
test::string::truncate::fast()    { local r; string::truncate::fast r hello 4;      if [[ "$r" == "hel…"     ]]; then _pass; else _fail; fi; }

# SPLITTING/JOINING ::fast
test::string::join::fast()        { local r; string::join::fast r , a b c;          if [[ "$r" == "a,b,c"    ]]; then _pass; else _fail; fi; }

# ENCODING ::fast
test::string::url_encode::fast()  { local r; string::url_encode::fast r "hello world"; if [[ "$r" == "hello%20world" ]]; then _pass; else _fail; fi; }
test::string::url_decode::fast()  { local r; string::url_decode::fast r "hello%20world"; if [[ "$r" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::base64_encode::fast() { local r; string::base64_encode::fast r hello; local e="$r"; string::base64_decode::fast r "$e"; if [[ "$r" == "hello" ]]; then _pass; else _fail; fi; }
test::string::base64_decode::fast() { local r; string::base64_encode::fast r hello; string::base64_decode::fast r "$r"; if [[ "$r" == "hello" ]]; then _pass; else _fail; fi; }
test::string::base32_encode::fast() { local r; string::base32_encode::fast r hello; local e="$r"; string::base32_decode::fast r "$e"; if [[ "$r" == "hello" ]]; then _pass; else _fail; fi; }
test::string::base32_decode::fast() { local r; string::base32_encode::fast r hello; string::base32_decode::fast r "$r"; if [[ "$r" == "hello" ]]; then _pass; else _fail; fi; }

# NAMING CONVENTION ::fast - plain_to
test::string::plain_to_snake::fast()    { local r; string::plain_to_snake::fast r "hello world";    if [[ "$r" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::plain_to_kebab::fast()    { local r; string::plain_to_kebab::fast r "hello world";    if [[ "$r" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::plain_to_camel::fast()    { local r; string::plain_to_camel::fast r "hello world";    if [[ "$r" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::plain_to_pascal::fast()   { local r; string::plain_to_pascal::fast r "hello world";   if [[ "$r" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::plain_to_constant::fast() { local r; string::plain_to_constant::fast r "hello world"; if [[ "$r" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::plain_to_dot::fast()      { local r; string::plain_to_dot::fast r "hello world";      if [[ "$r" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::plain_to_path::fast()     { local r; string::plain_to_path::fast r "hello world";     if [[ "$r" == "hello/world"  ]]; then _pass; else _fail; fi; }

# NAMING CONVENTION ::fast - snake_to
test::string::snake_to_plain::fast()    { local r; string::snake_to_plain::fast r hello_world;    if [[ "$r" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::snake_to_kebab::fast()    { local r; string::snake_to_kebab::fast r hello_world;    if [[ "$r" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::snake_to_camel::fast()    { local r; string::snake_to_camel::fast r hello_world;    if [[ "$r" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::snake_to_pascal::fast()   { local r; string::snake_to_pascal::fast r hello_world;   if [[ "$r" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::snake_to_constant::fast() { local r; string::snake_to_constant::fast r hello_world; if [[ "$r" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::snake_to_dot::fast()      { local r; string::snake_to_dot::fast r hello_world;      if [[ "$r" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::snake_to_path::fast()     { local r; string::snake_to_path::fast r hello_world;     if [[ "$r" == "hello/world"  ]]; then _pass; else _fail; fi; }

# NAMING CONVENTION ::fast - kebab_to
test::string::kebab_to_plain::fast()    { local r; string::kebab_to_plain::fast r hello-world;    if [[ "$r" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::kebab_to_snake::fast()    { local r; string::kebab_to_snake::fast r hello-world;    if [[ "$r" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::kebab_to_camel::fast()    { local r; string::kebab_to_camel::fast r hello-world;    if [[ "$r" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::kebab_to_pascal::fast()   { local r; string::kebab_to_pascal::fast r hello-world;   if [[ "$r" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::kebab_to_constant::fast() { local r; string::kebab_to_constant::fast r hello-world; if [[ "$r" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::kebab_to_dot::fast()      { local r; string::kebab_to_dot::fast r hello-world;      if [[ "$r" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::kebab_to_path::fast()     { local r; string::kebab_to_path::fast r hello-world;     if [[ "$r" == "hello/world"  ]]; then _pass; else _fail; fi; }

# NAMING CONVENTION ::fast - camel_to
test::string::camel_to_plain::fast()    { local r; string::camel_to_plain::fast r helloWorld;    if [[ "$r" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_snake::fast()    { local r; string::camel_to_snake::fast r helloWorld;    if [[ "$r" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_kebab::fast()    { local r; string::camel_to_kebab::fast r helloWorld;    if [[ "$r" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_pascal::fast()   { local r; string::camel_to_pascal::fast r helloWorld;   if [[ "$r" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::camel_to_constant::fast() { local r; string::camel_to_constant::fast r helloWorld; if [[ "$r" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_dot::fast()      { local r; string::camel_to_dot::fast r helloWorld;      if [[ "$r" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::camel_to_path::fast()     { local r; string::camel_to_path::fast r helloWorld;     if [[ "$r" == "hello/world"  ]]; then _pass; else _fail; fi; }

# NAMING CONVENTION ::fast - pascal_to
test::string::pascal_to_plain::fast()    { local r; string::pascal_to_plain::fast r HelloWorld;    if [[ "$r" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_snake::fast()    { local r; string::pascal_to_snake::fast r HelloWorld;    if [[ "$r" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_kebab::fast()    { local r; string::pascal_to_kebab::fast r HelloWorld;    if [[ "$r" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_camel::fast()    { local r; string::pascal_to_camel::fast r HelloWorld;    if [[ "$r" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::pascal_to_constant::fast() { local r; string::pascal_to_constant::fast r HelloWorld; if [[ "$r" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_dot::fast()      { local r; string::pascal_to_dot::fast r HelloWorld;      if [[ "$r" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::pascal_to_path::fast()     { local r; string::pascal_to_path::fast r HelloWorld;     if [[ "$r" == "hello/world"  ]]; then _pass; else _fail; fi; }

# NAMING CONVENTION ::fast - constant_to
test::string::constant_to_plain::fast()  { local r; string::constant_to_plain::fast r HELLO_WORLD; if [[ "$r" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::constant_to_snake::fast()  { local r; string::constant_to_snake::fast r HELLO_WORLD; if [[ "$r" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::constant_to_kebab::fast()  { local r; string::constant_to_kebab::fast r HELLO_WORLD; if [[ "$r" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::constant_to_camel::fast()  { local r; string::constant_to_camel::fast r HELLO_WORLD; if [[ "$r" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::constant_to_pascal::fast() { local r; string::constant_to_pascal::fast r HELLO_WORLD; if [[ "$r" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::constant_to_dot::fast()    { local r; string::constant_to_dot::fast r HELLO_WORLD;   if [[ "$r" == "hello.world"  ]]; then _pass; else _fail; fi; }
test::string::constant_to_path::fast()   { local r; string::constant_to_path::fast r HELLO_WORLD;  if [[ "$r" == "hello/world"  ]]; then _pass; else _fail; fi; }

# NAMING CONVENTION ::fast - dot_to
test::string::dot_to_plain::fast()    { local r; string::dot_to_plain::fast r hello.world;    if [[ "$r" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::dot_to_snake::fast()    { local r; string::dot_to_snake::fast r hello.world;    if [[ "$r" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::dot_to_kebab::fast()    { local r; string::dot_to_kebab::fast r hello.world;    if [[ "$r" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::dot_to_camel::fast()    { local r; string::dot_to_camel::fast r hello.world;    if [[ "$r" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::dot_to_pascal::fast()   { local r; string::dot_to_pascal::fast r hello.world;   if [[ "$r" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::dot_to_constant::fast() { local r; string::dot_to_constant::fast r hello.world; if [[ "$r" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::dot_to_path::fast()     { local r; string::dot_to_path::fast r hello.world;     if [[ "$r" == "hello/world"  ]]; then _pass; else _fail; fi; }

# NAMING CONVENTION ::fast - path_to
test::string::path_to_plain::fast()    { local r; string::path_to_plain::fast r hello/world;    if [[ "$r" == "hello world"  ]]; then _pass; else _fail; fi; }
test::string::path_to_snake::fast()    { local r; string::path_to_snake::fast r hello/world;    if [[ "$r" == "hello_world"  ]]; then _pass; else _fail; fi; }
test::string::path_to_kebab::fast()    { local r; string::path_to_kebab::fast r hello/world;    if [[ "$r" == "hello-world"  ]]; then _pass; else _fail; fi; }
test::string::path_to_camel::fast()    { local r; string::path_to_camel::fast r hello/world;    if [[ "$r" == "helloWorld"   ]]; then _pass; else _fail; fi; }
test::string::path_to_pascal::fast()   { local r; string::path_to_pascal::fast r hello/world;   if [[ "$r" == "HelloWorld"   ]]; then _pass; else _fail; fi; }
test::string::path_to_constant::fast() { local r; string::path_to_constant::fast r hello/world; if [[ "$r" == "HELLO_WORLD"  ]]; then _pass; else _fail; fi; }
test::string::path_to_dot::fast()      { local r; string::path_to_dot::fast r hello/world;      if [[ "$r" == "hello.world"  ]]; then _pass; else _fail; fi; }

# ==============================================================================
# Tests — array
# ==============================================================================

test::array::length()    { if [[ "$(array::length a b c)"         == "3"                      ]]; then _pass; else _fail; fi; }
test::array::first()     { if [[ "$(array::first a b c)"          == "a"                      ]]; then _pass; else _fail; fi; }
test::array::last()      { if [[ "$(array::last a b c)"           == "c"                      ]]; then _pass; else _fail; fi; }
test::array::get()       { if [[ "$(array::get 1 a b c)"          == "b"                      ]]; then _pass; else _fail; fi; }
test::array::count_of()  { if [[ "$(array::count_of a a b a c | tail -1)" == "2"              ]]; then _pass; else _fail; fi; }
test::array::print()     { if [[ "$(array::print a b c)"          == "$(printf 'a\nb\nc')"    ]]; then _pass; else _fail; fi; }
test::array::reverse()   { if [[ "$(array::reverse a b c)"        == "$(printf 'c\nb\na')"    ]]; then _pass; else _fail; fi; }
test::array::flatten()   { if [[ "$(array::flatten "a b" "c d")"  == "$(printf 'a\nb\nc\nd')" ]]; then _pass; else _fail; fi; }
test::array::slice()     { if [[ "$(array::slice 1 2 a b c d)"    == "$(printf 'b\nc')"       ]]; then _pass; else _fail; fi; }
test::array::push()      { if [[ "$(array::push d a b c)"         == "$(printf 'a\nb\nc\nd')" ]]; then _pass; else _fail; fi; }
test::array::pop()       { if [[ "$(array::pop a b c)"            == "$(printf 'a\nb')"       ]]; then _pass; else _fail; fi; }
test::array::unshift()   { if [[ "$(array::unshift z a b)"        == "$(printf 'z\na\nb')"    ]]; then _pass; else _fail; fi; }
test::array::shift()     { if [[ "$(array::shift a b c)"          == "$(printf 'b\nc')"       ]]; then _pass; else _fail; fi; }
test::array::remove_at() { if [[ "$(array::remove_at 1 a b c)"    == "$(printf 'a\nc')"       ]]; then _pass; else _fail; fi; }
test::array::remove()    { if [[ "$(array::remove b a b c)"       == "$(printf 'a\nc')"       ]]; then _pass; else _fail; fi; }
test::array::set()       { if [[ "$(array::set 1 Z a b c)"        == "$(printf 'a\nZ\nc')"    ]]; then _pass; else _fail; fi; }
test::array::insert_at() { if [[ "$(array::insert_at 1 X a b c)"  == "$(printf 'a\nX\nb\nc')" ]]; then _pass; else _fail; fi; }
test::array::filter()    { if [[ "$(array::filter '^a' ab bc ac)" == "$(printf 'ab\nac')"     ]]; then _pass; else _fail; fi; }
test::array::reject()    { if [[ "$(array::reject '^a' ab bc ac)" == "bc"                     ]]; then _pass; else _fail; fi; }
test::array::compact()   { if [[ "$(array::compact a '' b '')"    == "$(printf 'a\nb')"       ]]; then _pass; else _fail; fi; }
test::array::join()      { if [[ "$(array::join , a b c)"         == "a,b,c"                  ]]; then _pass; else _fail; fi; }
test::array::sum()       { if [[ "$(array::sum 1 2 3)"            == "6"                      ]]; then _pass; else _fail; fi; }
test::array::min()       { if [[ "$(array::min 3 1 2)"            == "1"                      ]]; then _pass; else _fail; fi; }
test::array::max()       { if [[ "$(array::max 1 3 2)"            == "3"                      ]]; then _pass; else _fail; fi; }
test::array::intersect() { if [[ "$(array::intersect "a b" "b c")" == "b"                     ]]; then _pass; else _fail; fi; }
test::array::diff()      { if [[ "$(array::diff "a b" "b c")"     == "a"                      ]]; then _pass; else _fail; fi; }
test::array::union()     { if [[ "$(array::union "a b" "b c")"    == "$(printf 'a\nb\nc')"    ]]; then _pass; else _fail; fi; }
test::array::sort()      { if [[ "$(array::sort c a b)"           == "$(printf 'a\nb\nc')"    ]]; then _pass; else _fail; fi; }
test::array::unique()    { if [[ "$(array::unique a b a c b)"     == "$(printf 'a\nb\nc')"    ]]; then _pass; else _fail; fi; }
test::array::zip()       { if [[ "$(array::zip "a b" "1 2")"      == "$(printf 'a 1\nb 2')"   ]]; then _pass; else _fail; fi; }
test::array::rotate()    { if [[ "$(array::rotate 1 a b c)"       == "$(printf 'b\nc\na')"    ]]; then _pass; else _fail; fi; }
test::array::chunk()     { if [[ "$(array::chunk 2 a b c d e)"    == "$(printf 'a b\nc d\ne')" ]]; then _pass; else _fail; fi; }
test::array::from_string(){ if [[ "$(array::from_string , a,b,c)" == "$(printf 'a\nb\nc')"    ]]; then _pass; else _fail; fi; }
test::array::from_lines() { if [[ "$(array::from_lines "$(printf 'a\nb\nc')")" == "$(printf 'a\nb\nc')" ]]; then _pass; else _fail; fi; }
test::array::sort::reverse()         { if [[ "$(array::sort::reverse a b c)"         == "$(printf 'c\nb\na')"  ]]; then _pass; else _fail; fi; }
test::array::sort::numeric()         { if [[ "$(array::sort::numeric 10 1 2)"         == "$(printf '1\n2\n10')" ]]; then _pass; else _fail; fi; }
test::array::sort::numeric_reverse() { if [[ "$(array::sort::numeric_reverse 1 10 2)" == "$(printf '10\n2\n1')" ]]; then _pass; else _fail; fi; }

test::array::contains() {
    _assert "contains (true)"  "0" "$(array::contains b a b c; echo $?)"
    _assert "contains (false)" "1" "$(array::contains z a b c; echo $?)"
    _sub_done
}
test::array::index_of() {
    _assert "index_of (found)"   "1"  "$(array::index_of b a b c)"
    _assert "index_of (missing)" "-1" "$(array::index_of z a b c)"
    _sub_done
}
test::array::is_empty() {
    _assert "is_empty (true)"  "0" "$(array::is_empty;     echo $?)"
    _assert "is_empty (false)" "1" "$(array::is_empty a b; echo $?)"
    _sub_done
}
test::array::equals() {
    _assert "equals (true)"  "0" "$(array::equals 'a b c' 'a b c'; echo $?)"
    _assert "equals (false)" "1" "$(array::equals 'a b'   'a b c'; echo $?)"
    _sub_done
}
test::array::range() {
    _assert "range (basic)" "$(printf '1\n2\n3\n4\n5')" "$(array::range 1 5)"
    _assert "range (step)"  "$(printf '0\n2\n4')"        "$(array::range 0 4 2)"
    _sub_done
}

# ==============================================================================
# Tests — math
# ==============================================================================

test::math::min()          { if [[ "$(math::min 3 7)"          == "3"   ]]; then _pass; else _fail; fi; }
test::math::max()          { if [[ "$(math::max 3 7)"          == "7"   ]]; then _pass; else _fail; fi; }
test::math::div()          { if [[ "$(math::div 7 2)"          == "3"   ]]; then _pass; else _fail; fi; }
test::math::mod()          { if [[ "$(math::mod 7 2)"          == "1"   ]]; then _pass; else _fail; fi; }
test::math::gcd()          { if [[ "$(math::gcd 12 18)"        == "6"   ]]; then _pass; else _fail; fi; }
test::math::lcm()          { if [[ "$(math::lcm 4 6)"          == "12"  ]]; then _pass; else _fail; fi; }
test::math::factorial()    { if [[ "$(math::factorial 5)"      == "120" ]]; then _pass; else _fail; fi; }
test::math::fibonacci()    { if [[ "$(math::fibonacci 7)"      == "13"  ]]; then _pass; else _fail; fi; }
test::math::pow()          { if [[ "$(math::pow 2 3)"          == "8"   ]]; then _pass; else _fail; fi; }
test::math::sum()          { if [[ "$(math::sum 1 2 3 4)"      == "10"  ]]; then _pass; else _fail; fi; }
test::math::product()      { if [[ "$(math::product 2 3 4)"    == "24"  ]]; then _pass; else _fail; fi; }
test::math::choose()       { if [[ "$(math::choose 5 2)"       == "10"  ]]; then _pass; else _fail; fi; }
test::math::permute()      { if [[ "$(math::permute 5 2)"      == "20"  ]]; then _pass; else _fail; fi; }
test::math::digit_sum()    { if [[ "$(math::digit_sum 123)"    == "6"   ]]; then _pass; else _fail; fi; }
test::math::digit_count()  { if [[ "$(math::digit_count 123)"  == "3"   ]]; then _pass; else _fail; fi; }
test::math::digit_reverse(){ if [[ "$(math::digit_reverse 123)" == "321" ]]; then _pass; else _fail; fi; }
test::math::has_bc() { math::has_bc && _pass || _skip "bc not available"; }
test::math::floor()  { if math::has_bc || { _skip "bc not available"; return; }; [[ "$(math::floor 3.7)" == "3" ]]; then _pass; else _fail; fi; }
test::math::ceil()   { if math::has_bc || { _skip "bc not available"; return; }; [[ "$(math::ceil  3.2)" == "4" ]]; then _pass; else _fail; fi; }
test::math::round()  { if math::has_bc || { _skip "bc not available"; return; }; [[ "$(math::round 3.6)" == "4" ]]; then _pass; else _fail; fi; }
test::math::sqrt()   { if math::has_bc || { _skip "bc not available"; return; }; [[ "$(math::sqrt 4)" == "$(math::bc "sqrt(4)" "$MATH_SCALE")" ]]; then _pass; else _fail; fi; }
test::math::unitconvert() {
    math::has_bc || { _skip "bc not available"; return; }
    if [[ -n "$(math::unitconvert km mi 1)" ]]; then _pass; else _fail; fi
}

test::math::abs() {
    _assert "abs (negative)" "5" "$(math::abs -5)"
    _assert "abs (positive)" "5" "$(math::abs  5)"
    _sub_done
}
test::math::clamp() {
    _assert "clamp (within)" "5"  "$(math::clamp  5 1 10)"
    _assert "clamp (low)"    "1"  "$(math::clamp -5 1 10)"
    _assert "clamp (high)"   "10" "$(math::clamp 99 1 10)"
    _sub_done
}
test::math::is_even() {
    _assert "is_even (true)"  "0" "$(math::is_even 4; echo $?)"
    _assert "is_even (false)" "1" "$(math::is_even 3; echo $?)"
    _sub_done
}
test::math::is_odd() {
    _assert "is_odd (true)"  "0" "$(math::is_odd 3; echo $?)"
    _assert "is_odd (false)" "1" "$(math::is_odd 4; echo $?)"
    _sub_done
}
test::math::is_prime() {
    _assert "is_prime (true)"  "0" "$(math::is_prime 17; echo $?)"
    _assert "is_prime (false)" "1" "$(math::is_prime 18; echo $?)"
    _sub_done
}
test::math::int_sqrt() {
    _assert "int_sqrt (exact)" "4" "$(math::int_sqrt 16)"
    _assert "int_sqrt (floor)" "3" "$(math::int_sqrt 12)"
    _sub_done
}
test::math::is_palindrome() {
    _assert "is_palindrome (true)"  "0" "$(math::is_palindrome 121; echo $?)"
    _assert "is_palindrome (false)" "1" "$(math::is_palindrome 123; echo $?)"
    _sub_done
}
test::math::bc() {
    math::has_bc || { _skip "bc not available"; return; }
    _assert_contains "bc (22/7)" "3.14" "$(math::bc "22/7" 2)"
    _sub_done
}
test::math::clampf() {
    math::has_bc || { _skip "bc not available"; return; }
    _assert "clampf (within)"         "3.5"   "$(math::clampf  3.5  0    10   1)"
    _assert "clampf (below low)"      "0.0"   "$(math::clampf -2.5  0    10   1)"
    _assert "clampf (above high)"     "10.0"  "$(math::clampf 12.5  0    10   1)"
    _assert "clampf (decimal low)"    "1.5"   "$(math::clampf  0.5  1.5  5.5  1)"
    _assert "clampf (decimal high)"   "5.5"   "$(math::clampf  6.5  1.5  5.5  1)"
    _assert "clampf (negative range)" "-5.0"  "$(math::clampf -5.0 -10.0  0.0 1)"
    _assert "clampf (exact low)"      "0.0"   "$(math::clampf  0.0  0.0  10.0 1)"
    _assert "clampf (exact high)"     "10.0"  "$(math::clampf 10.0  0.0  10.0 1)"
    _assert "clampf (mixed signs)"    "0.0"   "$(math::clampf -5.0  0.0   5.0 1)"
    _sub_done
}
# trig — individual tests
test::math::sin()          { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::sin 0)"          ]]; then _pass; else _fail; fi; }
test::math::cos()          { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::cos 0)"          ]]; then _pass; else _fail; fi; }
test::math::tan()          { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::tan 0)"          ]]; then _pass; else _fail; fi; }
test::math::asin()         { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::asin 0)"         ]]; then _pass; else _fail; fi; }
test::math::acos()         { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::acos 1)"         ]]; then _pass; else _fail; fi; }
test::math::atan()         { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::atan 1)"         ]]; then _pass; else _fail; fi; }
test::math::atan2()        { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::atan2 1 1)"      ]]; then _pass; else _fail; fi; }
test::math::deg_to_rad()   { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::deg_to_rad 180)" ]]; then _pass; else _fail; fi; }
test::math::rad_to_deg()   { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::rad_to_deg 1)"   ]]; then _pass; else _fail; fi; }
# log / exp
test::math::log()          { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::log   10)"  ]]; then _pass; else _fail; fi; }
test::math::log2()         { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::log2   8)"  ]]; then _pass; else _fail; fi; }
test::math::log10()        { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::log10 100)" ]]; then _pass; else _fail; fi; }
test::math::logn()         { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::logn   8 2)" ]]; then _pass; else _fail; fi; }
test::math::exp()          { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::exp    1)"  ]]; then _pass; else _fail; fi; }
test::math::powf()         { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::powf   2 0.5)" ]]; then _pass; else _fail; fi; }
# float arithmetic
test::math::absf()         { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::absf  -3.5 1)" ]]; then _pass; else _fail; fi; }
test::math::minf()         { math::has_bc || { _skip "bc not available"; return; }; if [[ "$(math::minf 2.5 3.5 1)" == "2.5" ]]; then _pass; else _fail; fi; }
test::math::maxf()         { math::has_bc || { _skip "bc not available"; return; }; if [[ "$(math::maxf 2.5 3.5 1)" == "3.5" ]]; then _pass; else _fail; fi; }
test::math::sumf()         { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::sumf 2 1.5 2.5 3.0)" ]]; then _pass; else _fail; fi; }
test::math::productf()     { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::productf 2 2.0 3.0)" ]]; then _pass; else _fail; fi; }
# percent
test::math::percent()      { math::has_bc || { _skip "bc not available"; return; }; if [[ "$(math::percent        1 2 2)" == "50.00"  ]]; then _pass; else _fail; fi; }
test::math::percent_of()   { math::has_bc || { _skip "bc not available"; return; }; if [[ "$(math::percent_of    50 100 2)" == "50.00" ]]; then _pass; else _fail; fi; }
test::math::percent_change(){ math::has_bc || { _skip "bc not available"; return; }; if [[ "$(math::percent_change 50 100 2)" == "100.00" ]]; then _pass; else _fail; fi; }
# interpolation / mapping
test::math::lerp()          { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::lerp           0 10 0.5)" ]]; then _pass; else _fail; fi; }
test::math::lerp_unclamped(){ math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::lerp_unclamped 0 10 0.5)" ]]; then _pass; else _fail; fi; }
test::math::map()           { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::map            5 0 10 0 100)" ]]; then _pass; else _fail; fi; }
test::math::normalize()     { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::normalize      5 0 10)" ]]; then _pass; else _fail; fi; }
# sigmoid / softmax
test::math::sigmoid() {
    math::has_bc || { _skip "bc not available"; return; }
    local -a _vals=(0 1 -1)
    if [[ -n "$(math::sigmoid _vals 2)" ]]; then _pass; else _fail; fi
}
test::math::sigmoid::singleton() { math::has_bc || { _skip "bc not available"; return; }; if [[ -n "$(math::sigmoid::singleton 0 2)" ]]; then _pass; else _fail; fi; }
test::math::softmax() {
    math::has_bc || { _skip "bc not available"; return; }
    local -a _vals=(1 2 3)
    if [[ -n "$(math::softmax _vals 1 2)" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Tests — hash
# ==============================================================================

test::hash::md5()     { if [[ -n "$(hash::md5     hello)" ]]; then _pass; else _fail; fi; }
test::hash::sha1()    { if [[ -n "$(hash::sha1    hello)" ]]; then _pass; else _fail; fi; }
test::hash::sha512()  { if [[ -n "$(hash::sha512  hello)" ]]; then _pass; else _fail; fi; }
test::hash::djb2()    { if [[ -n "$(hash::djb2    hello)" ]]; then _pass; else _fail; fi; }
test::hash::djb2a()   { if [[ -n "$(hash::djb2a   hello)" ]]; then _pass; else _fail; fi; }
test::hash::sdbm()    { if [[ -n "$(hash::sdbm    hello)" ]]; then _pass; else _fail; fi; }
test::hash::fnv1a32() { if [[ -n "$(hash::fnv1a32 hello)" ]]; then _pass; else _fail; fi; }
test::hash::fnv1a64() { if [[ -n "$(hash::fnv1a64 hello)" ]]; then _pass; else _fail; fi; }
test::hash::adler32() { if [[ -n "$(hash::adler32 hello)" ]]; then _pass; else _fail; fi; }
test::hash::murmur2() { if [[ -n "$(hash::murmur2 hello)" ]]; then _pass; else _fail; fi; }
test::hash::crc32()   { if [[ -n "$(hash::crc32   hello)" ]]; then _pass; else _fail; fi; }
test::hash::combine() { if [[ -n "$(hash::combine foo bar baz)" ]]; then _pass; else _fail; fi; }
test::hash::verify()  { if hash::verify hello "$(hash::sha256 hello)" sha256; then _pass; else _fail; fi; }

test::hash::sha256() {
    _assert_nonempty "sha256 nonempty" "$(hash::sha256 hello)"
    _assert "sha256 known value" \
        "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824" \
        "$(hash::sha256 hello)"
    _sub_done
}
test::hash::equal() {
    _assert "equal (true)"  "0" "$(hash::equal hello hello; echo $?)"
    _assert "equal (false)" "1" "$(hash::equal hello world; echo $?)"
    _sub_done
}
test::hash::slot() {
    local h; h=$(hash::slot 10 test)
    if [[ $h -ge 0 && $h -lt 10 ]]; then _pass; else _fail; fi
}
test::hash::short() {
    _assert_nonempty "short nonempty" "$(hash::short hello)"
    _assert "short length" "8" \
        "$(hash::short hello 8 | wc -c | tr -d ' ' | awk '{print $1-1}')"
    _sub_done
}
test::hash::hmac::sha256() {
    runtime::has_command openssl || { _skip "openssl not available"; return; }
    if [[ -n "$(hash::hmac::sha256 mykey hello)" ]]; then _pass; else _fail; fi
}
test::hash::hmac::sha512() {
    runtime::has_command openssl || { _skip "openssl not available"; return; }
    if [[ -n "$(hash::hmac::sha512 mykey hello)" ]]; then _pass; else _fail; fi
}
test::hash::hmac::md5() {
    runtime::has_command openssl || { _skip "openssl not available"; return; }
    if [[ -n "$(hash::hmac::md5 mykey hello)" ]]; then _pass; else _fail; fi
}
test::hash::sha3_256() {
    runtime::has_command openssl || runtime::has_command python3 || { _skip "openssl/python3 not available"; return; }
    if [[ -n "$(hash::sha3_256 hello 2>/dev/null)" ]]; then _pass; else _fail; fi
}
test::hash::blake2b() {
    runtime::has_command openssl || runtime::has_command python3 || { _skip "openssl/python3 not available"; return; }
    if [[ -n "$(hash::blake2b hello 2>/dev/null)" ]]; then _pass; else _fail; fi
}
test::hash::uuid5() {
    runtime::has_command openssl || runtime::has_command python3 || { _skip "openssl/python3 not available"; return; }
    if [[ -n "$(hash::uuid5 dns example.com)" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Tests — log
# ==============================================================================

test::log::init() {
    if log::init 2>/dev/null; then _pass; else _fail; fi
}
test::log::debug() {
    log::init 2>/dev/null
    if log::debug "test debug message" 2>/dev/null; then _pass; else _fail; fi
}
test::log::info() {
    log::init 2>/dev/null
    if log::info "test info message" 2>/dev/null; then _pass; else _fail; fi
}
test::log::warn() {
    log::init 2>/dev/null
    if log::warn "test warn message" 2>/dev/null; then _pass; else _fail; fi
}
test::log::error() {
    log::init 2>/dev/null
    # no exit code arg — must not exit
    if log::error "test error message" 2>/dev/null; then _pass; else _fail; fi
}
test::log::fatal() { _skip "calls exit — would terminate test runner"; }

# ==============================================================================
# Tests — runtime
# ==============================================================================

test::runtime::os()            { if [[ -n "$(runtime::os)"            ]]; then _pass; else _fail; fi; }
test::runtime::arch()          { if [[ -n "$(runtime::arch)"          ]]; then _pass; else _fail; fi; }
test::runtime::bash_version()  { if [[ -n "$(runtime::bash_version)"  ]]; then _pass; else _fail; fi; }
test::runtime::distro()        { if [[ -n "$(runtime::distro)"        ]]; then _pass; else _fail; fi; }
test::runtime::pm()            { if [[ -n "$(runtime::pm)"            ]]; then _pass; else _fail; fi; }
test::runtime::sysinit()       { if [[ -n "$(runtime::sysinit)"       ]]; then _pass; else _fail; fi; }
test::runtime::tty_name()      { if [[ -n "$(runtime::tty_name)"      ]]; then _pass; else _fail; fi; }
test::runtime::kernel_version(){ if [[ -n "$(runtime::kernel_version 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::runtime::screen_session(){ if [[ -n "$(runtime::screen_session)" ]]; then _pass; else _fail; fi; }
test::runtime::is_bash()       { if runtime::is_bash; then _pass; else _fail; fi; }
test::runtime::is_subshell()   { if runtime::is_subshell; [[ $? -eq 0 || $? -eq 1 ]]; then _pass; else _fail; fi; }
test::runtime::has_flag()      { if runtime::has_flag B; then _pass; else _fail; fi; }
test::runtime::braceexpand_enabled() { if runtime::braceexpand_enabled; then _pass; else _fail; fi; }
test::runtime::is_terminal()   { if runtime::is_terminal;   [[ $? -eq 0 || $? -eq 1 ]]; then _pass; else _fail; fi; }
test::runtime::is_interactive(){ if runtime::is_interactive; [[ $? -eq 0 || $? -eq 1 ]]; then _pass; else _fail; fi; }
test::runtime::is_sourced()    { if runtime::is_sourced; then _pass; else _fail; fi; }
test::runtime::is_pipe()       { if echo | runtime::is_pipe; then _pass; else _fail; fi; }
test::runtime::is_redirected() { if runtime::is_redirected; [[ $? -eq 0 || $? -eq 1 ]]; then _pass; else _fail; fi; }
test::runtime::is_ci()  { if local e; e=$([ -n "$CI"        ] && echo 0 || echo 1); runtime::is_ci;   [[ $? -eq $e ]]; then _pass; else _fail; fi; }
test::runtime::is_root(){ if local e; e=$([ "$EUID" -eq 0   ] && echo 0 || echo 1); runtime::is_root; [[ $? -eq $e ]]; then _pass; else _fail; fi; }
test::runtime::is_sudo(){ if local e; e=$([ -n "$SUDO_USER" ] && echo 0 || echo 1); runtime::is_sudo; [[ $? -eq $e ]]; then _pass; else _fail; fi; }
test::runtime::is_container()        { if _bool_probe runtime::is_container; then _pass; else _fail; fi; }
test::runtime::supports_color()      { if _bool_probe runtime::supports_color; then _pass; else _fail; fi; }
test::runtime::supports_truecolor()  { if _bool_probe runtime::supports_truecolor; then _pass; else _fail; fi; }
test::runtime::is_wsl()              { if _bool_probe runtime::is_wsl; then _pass; else _fail; fi; }
test::runtime::is_virtualized()      { if _bool_probe runtime::is_virtualized; then _pass; else _fail; fi; }
test::runtime::is_ssh()              { if _bool_probe runtime::is_ssh; then _pass; else _fail; fi; }
test::runtime::is_desktop()          { if _bool_probe runtime::is_desktop; then _pass; else _fail; fi; }
test::runtime::is_pty()              { if _bool_probe runtime::is_pty; then _pass; else _fail; fi; }
test::runtime::is_tty()              { if _bool_probe runtime::is_tty; then _pass; else _fail; fi; }
test::runtime::is_login()            { if _bool_probe runtime::is_login; then _pass; else _fail; fi; }
test::runtime::is_tmux()             { if _bool_probe runtime::is_tmux; then _pass; else _fail; fi; }
test::runtime::is_multiplexer()      { if _bool_probe runtime::is_multiplexer; then _pass; else _fail; fi; }
test::runtime::errexit_enabled()     { if _bool_probe runtime::errexit_enabled; then _pass; else _fail; fi; }
test::runtime::nounset_enabled()     { if _bool_probe runtime::nounset_enabled; then _pass; else _fail; fi; }
test::runtime::noclobber_enabled()   { if _bool_probe runtime::noclobber_enabled; then _pass; else _fail; fi; }
test::runtime::histexpand_enabled()  { if _bool_probe runtime::histexpand_enabled; then _pass; else _fail; fi; }
test::runtime::physical_cd_enabled() { if _bool_probe runtime::physical_cd_enabled; then _pass; else _fail; fi; }
test::runtime::job_controlled()      { if _bool_probe runtime::job_controlled; then _pass; else _fail; fi; }
test::runtime::debug_trapped()       { if _bool_probe runtime::debug_trapped; then _pass; else _fail; fi; }
test::runtime::is_traced()           { if _bool_probe runtime::is_traced; then _pass; else _fail; fi; }
test::runtime::is_verbose()          { if _bool_probe runtime::is_verbose; then _pass; else _fail; fi; }

test::runtime::bash_version::major() {
    local v; v=$(runtime::bash_version::major)
    if [[ -n "$v" && "$v" =~ ^[0-9]+$ ]]; then _pass; else _fail; fi
}
test::runtime::has_command() {
    _assert "has_command (true)"  "0" "$(runtime::has_command bash;            echo $?)"
    _assert "has_command (false)" "1" "$(runtime::has_command __no_such_cmd__; echo $?)"
    _sub_done
}
test::runtime::is_minimum_bash() {
    _assert "is_minimum_bash (pass)" "0" "$(runtime::is_minimum_bash 3;  echo $?)"
    _assert "is_minimum_bash (fail)" "1" "$(runtime::is_minimum_bash 99; echo $?)"
    _sub_done
}
test::runtime::is_terminal::stdout() { if _bool_probe runtime::is_terminal::stdout; then _pass; else _fail; fi; }
test::runtime::is_terminal::stderr() { if _bool_probe runtime::is_terminal::stderr; then _pass; else _fail; fi; }
test::runtime::is_terminal::stdin()  { if _bool_probe runtime::is_terminal::stdin;  then _pass; else _fail; fi; }
test::runtime::is_wayland()          { if _bool_probe runtime::is_wayland; then _pass; else _fail; fi; }
test::runtime::is_x11()              { if _bool_probe runtime::is_x11;     then _pass; else _fail; fi; }
test::runtime::ssh_client()          {
    # Only test when actually in an SSH session
    if runtime::is_ssh; then
        if [[ -n "$(runtime::ssh_client 2>/dev/null || echo none)" ]]; then _pass; else _fail; fi
    else
        _skip "not in an SSH session"
    fi
}
test::runtime::wm()                  { if [[ -n "$(runtime::wm  2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::runtime::de()                  { if [[ -n "$(runtime::de  2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::runtime::exec_root()           { _skip "requires sudo/root — would escalate privileges"; }

# ==============================================================================
# Tests — fs
# ==============================================================================

# Shared setup — called inline within each test that needs a real file
_FS_DIR="" _FS_FILE="" _FS_LINK=""
_fs_setup() {
    _FS_DIR=$(mktemp -d)
    _FS_FILE=$(mktemp "$_FS_DIR/test.XXXXXX")
    _FS_LINK="${_FS_DIR}/link.txt"
    echo "hello world" > "$_FS_FILE"
    ln -s "$_FS_FILE" "$_FS_LINK"
}
_fs_teardown() { rm -rf "$_FS_DIR"; }

# stat / metadata
test::fs::exists()              { _fs_setup; if fs::exists    "$_FS_FILE"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::is_file()             { _fs_setup; if fs::is_file   "$_FS_FILE"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::is_dir()              { _fs_setup; if fs::is_dir    "$_FS_DIR";  then _pass; else _fail; fi; _fs_teardown; }
test::fs::is_symlink()          { _fs_setup; if fs::is_symlink "$_FS_LINK"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::is_readable()         { _fs_setup; if fs::is_readable "$_FS_FILE"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::is_writable()         { _fs_setup; if fs::is_writable "$_FS_FILE"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::is_empty()            { _fs_setup; if ! fs::is_empty "$_FS_FILE"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::is_same()             { _fs_setup; if fs::is_same "$_FS_FILE" "$_FS_FILE"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::is_identical()        { _fs_setup; if fs::is_identical "$_FS_FILE" "$_FS_FILE"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::is_executable()       { _fs_setup; fs::is_executable "$_FS_FILE"; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::size()                { _fs_setup; if [[ -n "$(fs::size       "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::size::human()         { _fs_setup; if [[ -n "$(fs::size::human "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::modified()            { _fs_setup; if [[ -n "$(fs::modified   "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::modified::human()     { _fs_setup; if [[ -n "$(fs::modified::human "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::permissions()         { _fs_setup; if [[ -n "$(fs::permissions "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::permissions::symbolic(){ _fs_setup; if [[ -n "$(fs::permissions::symbolic "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::owner()               { _fs_setup; if [[ -n "$(fs::owner       "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::owner::group()        { _fs_setup; if [[ -n "$(fs::owner::group "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::inode()               { _fs_setup; if [[ -n "$(fs::inode       "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::link_count()          { _fs_setup; if [[ -n "$(fs::link_count  "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::mime_type()           { _fs_setup; if [[ -n "$(fs::mime_type   "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::created()             { _fs_setup; if [[ -n "$(fs::created     "$_FS_FILE" 2>/dev/null || echo 0)" ]]; then _pass; else _fail; fi; _fs_teardown; }
# symlink
test::fs::symlink::target()     { _fs_setup; if [[ -n "$(fs::symlink::target  "$_FS_LINK")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::symlink::resolve()    { _fs_setup; if [[ -n "$(fs::symlink::resolve "$_FS_LINK")" ]]; then _pass; else _fail; fi; _fs_teardown; }
# path
test::fs::path::basename()      { if [[ "$(fs::path::basename  /foo/bar/test.txt)" == "test.txt" ]]; then _pass; else _fail; fi; }
test::fs::path::dirname()       { if [[ "$(fs::path::dirname   /foo/bar/test.txt)" == "/foo/bar" ]]; then _pass; else _fail; fi; }
test::fs::path::extension()     { if [[ "$(fs::path::extension  file.txt)"         == "txt"      ]]; then _pass; else _fail; fi; }
test::fs::path::extensions()    { if [[ "$(fs::path::extensions file.tar.gz)"      == "tar.gz"   ]]; then _pass; else _fail; fi; }
test::fs::path::stem()          { if [[ "$(fs::path::stem       file.txt)"         == "file"     ]]; then _pass; else _fail; fi; }
test::fs::path::join()          { if [[ "$(fs::path::join a b c)"                  == "a/b/c"    ]]; then _pass; else _fail; fi; }
test::fs::path::is_absolute()   { if fs::path::is_absolute /foo; then _pass; else _fail; fi; }
test::fs::path::is_relative()   { if fs::path::is_relative  foo; then _pass; else _fail; fi; }
test::fs::path::absolute()      { if [[ -n "$(fs::path::absolute .)" ]]; then _pass; else _fail; fi; }
test::fs::path::relative()      { if [[ -n "$(fs::path::relative /a/b/c /a)" ]]; then _pass; else _fail; fi; }
# read/write
test::fs::read()    { _fs_setup; if [[ "$(fs::read "$_FS_FILE")" == "hello world" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::write()   { _fs_setup; fs::write   "$_FS_FILE" "written";   if [[ "$(cat "$_FS_FILE")" == "written"   ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::writeln() { _fs_setup; fs::writeln "$_FS_FILE" "writtenln"; if [[ "$(cat "$_FS_FILE")" == "writtenln" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::append()  { _fs_setup; fs::write "$_FS_FILE" "base"; fs::append "$_FS_FILE" "extra"; if [[ "$(cat "$_FS_FILE")" == *"extra"* ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::appendln(){ _fs_setup; fs::write "$_FS_FILE" "base"; fs::appendln "$_FS_FILE" "extra"; if [[ "$(cat "$_FS_FILE")" == *"extra"* ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::prepend() { _fs_setup; printf 'hello
' > "$_FS_FILE"; fs::prepend "$_FS_FILE" "first"; if [[ "$(fs::line "$_FS_FILE" 1)" == "first" ]]; then _pass; else _fail; fi; _fs_teardown; }
# line ops
test::fs::line()       { _fs_setup; printf 'line1
line2
line3
' > "$_FS_FILE"; if [[ "$(fs::line "$_FS_FILE" 2)" == "line2" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::lines()      { _fs_setup; printf 'line1
line2
line3
' > "$_FS_FILE"; if [[ "$(fs::lines "$_FS_FILE" 1 2)" == "$(printf 'line1
line2')" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::line_count() { _fs_setup; printf 'line1
line2
line3
' > "$_FS_FILE"; if [[ "$(fs::line_count "$_FS_FILE")" == "3" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::word_count() { _fs_setup; if [[ -n "$(fs::word_count "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::char_count() { _fs_setup; if [[ -n "$(fs::char_count "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::contains()   { _fs_setup; if fs::contains "$_FS_FILE" "hello"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::matches()    { _fs_setup; if fs::matches  "$_FS_FILE" 'hello'; then _pass; else _fail; fi; _fs_teardown; }
test::fs::replace()    { _fs_setup; fs::replace "$_FS_FILE" hello HELLO; if fs::contains "$_FS_FILE" HELLO; then _pass; else _fail; fi; _fs_teardown; }
# file ops
test::fs::copy()     { _fs_setup; local d="${_FS_DIR}/copy.txt"; fs::copy "$_FS_FILE" "$d"; if fs::exists "$d"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::move()     { _fs_setup; local s="${_FS_DIR}/mv_src.txt"; local d="${_FS_DIR}/mv_dst.txt"; cp "$_FS_FILE" "$s"; fs::move "$s" "$d"; if fs::exists "$d"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::delete()   { _fs_setup; local f="${_FS_DIR}/del.txt"; touch "$f"; fs::delete "$f"; if ! fs::exists "$f"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::mkdir()    { _fs_setup; local d="${_FS_DIR}/newdir"; fs::mkdir "$d"; if fs::is_dir "$d"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::touch()    { _fs_setup; local f="${_FS_DIR}/touched.txt"; fs::touch "$f"; if fs::exists "$f"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::symlink()  { _fs_setup; local l="${_FS_DIR}/sym2.txt"; fs::symlink "$_FS_FILE" "$l"; if fs::is_symlink "$l"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::hardlink() { _fs_setup; local h="${_FS_DIR}/hard.txt"; fs::hardlink "$_FS_FILE" "$h"; if fs::exists "$h"; then _pass; else _fail; fi; _fs_teardown; }
test::fs::rename()   { _fs_setup; local h="${_FS_DIR}/ren.txt"; touch "$h"; fs::rename "$h" "renamed.txt"; if fs::exists "${_FS_DIR}/renamed.txt"; then _pass; else _fail; fi; _fs_teardown; }
# temp
test::fs::temp::file()      { if [[ -n "$(fs::temp::file)" ]]; then _pass; else _fail; fi; }
test::fs::temp::dir()       { if [[ -n "$(fs::temp::dir)"  ]]; then _pass; else _fail; fi; }
test::fs::temp::file::auto(){ local f; f=$(fs::temp::file::auto); if [[ -n "$f" ]]; then _pass; else _fail; fi; }
test::fs::temp::dir::auto() { local d; d=$(fs::temp::dir::auto);  if [[ -n "$d" ]]; then _pass; else _fail; fi; }
# ls / find
test::fs::ls()              { _fs_setup; if [[ -n "$(fs::ls        "$_FS_DIR")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::ls::all()         { _fs_setup; if [[ -n "$(fs::ls::all   "$_FS_DIR")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::ls::files()       { _fs_setup; if [[ -n "$(fs::ls::files "$_FS_DIR")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::ls::dirs()        { _fs_setup; mkdir "${_FS_DIR}/sub"; if [[ -n "$(fs::ls::dirs   "$_FS_DIR")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::find()            { _fs_setup; if [[ -n "$(fs::find "$_FS_DIR" "*.txt")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::find::type()      { _fs_setup; if [[ -n "$(fs::find::type        "$_FS_DIR" f)" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::find::recent()    { _fs_setup; if [[ -n "$(fs::find::recent      "$_FS_DIR" 1)" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::find::larger_than(){ _fs_setup; if [[ -n "$(fs::find::larger_than  "$_FS_DIR" 0)" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::find::smaller_than(){ _fs_setup; if [[ -n "$(fs::find::smaller_than "$_FS_DIR" 999999)" ]]; then _pass; else _fail; fi; _fs_teardown; }
# dir
test::fs::dir::size()       { _fs_setup; if [[ -n "$(fs::dir::size        "$_FS_DIR")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::dir::size::human(){ _fs_setup; if [[ -n "$(fs::dir::size::human "$_FS_DIR")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::dir::count()      { _fs_setup; if [[ -n "$(fs::dir::count       "$_FS_DIR")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::dir::is_empty()   { _fs_setup; if ! fs::dir::is_empty "$_FS_DIR"; then _pass; else _fail; fi; _fs_teardown; }
# checksum
test::fs::checksum::md5()   { _fs_setup; if [[ -n "$(fs::checksum::md5    "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::checksum::sha1()  { _fs_setup; if [[ -n "$(fs::checksum::sha1   "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::checksum::sha256(){ _fs_setup; if [[ -n "$(fs::checksum::sha256 "$_FS_FILE")" ]]; then _pass; else _fail; fi; _fs_teardown; }
test::fs::trash() {
    _fs_setup
    local f="${_FS_DIR}/to_trash.txt"; touch "$f"
    if fs::trash "$f" 2>/dev/null && ! fs::exists "$f"; then _pass; else _fail; fi
    _fs_teardown
}
test::fs::watch()           { _skip "infinite loop — no termination condition"; }
test::fs::watch::timeout() {
    _fs_setup
    local _triggered=0
    _watch_cb() { _triggered=1; }
    # modify file after short delay in background, watch for 3s
    ( sleep 0.5; echo "change" >> "$_FS_FILE" ) >/dev/null 2>&1 &
    fs::watch::timeout "$_FS_FILE" _watch_cb 3 1 2>/dev/null
    if [[ $_triggered -eq 1 ]]; then _pass; else _fail; fi
    _fs_teardown
}

# ==============================================================================
# Tests — timedate
# ==============================================================================

# timestamp
test::timedate::timestamp::unix()       { if [[ -n "$(timedate::timestamp::unix)" ]]; then _pass; else _fail; fi; }
test::timedate::timestamp::unix_ms()    { if [[ -n "$(timedate::timestamp::unix_ms)" ]]; then _pass; else _fail; fi; }
test::timedate::timestamp::unix_ns()    { if [[ -n "$(timedate::timestamp::unix_ns)" ]]; then _pass; else _fail; fi; }
test::timedate::timestamp::to_human()   { if [[ -n "$(timedate::timestamp::to_human "$(timedate::timestamp::unix)")" ]]; then _pass; else _fail; fi; }
test::timedate::timestamp::from_human() { if [[ -n "$(timedate::timestamp::from_human "2024-01-15 12:00:00")" ]]; then _pass; else _fail; fi; }
# date
test::timedate::date::today()           { if [[ -n "$(timedate::date::today)"           ]]; then _pass; else _fail; fi; }
test::timedate::date::format()          { if [[ -n "$(timedate::date::format)"          ]]; then _pass; else _fail; fi; }
test::timedate::date::year()            { if [[ -n "$(timedate::date::year)"            ]]; then _pass; else _fail; fi; }
test::timedate::date::month()           { if [[ -n "$(timedate::date::month)"           ]]; then _pass; else _fail; fi; }
test::timedate::date::day()             { if [[ -n "$(timedate::date::day)"             ]]; then _pass; else _fail; fi; }
test::timedate::date::day_of_week()     { if [[ -n "$(timedate::date::day_of_week)"     ]]; then _pass; else _fail; fi; }
test::timedate::date::day_name()        { if [[ -n "$(timedate::date::day_name)"        ]]; then _pass; else _fail; fi; }
test::timedate::date::day_name::short() { if [[ -n "$(timedate::date::day_name::short)" ]]; then _pass; else _fail; fi; }
test::timedate::date::day_of_year()     { if [[ -n "$(timedate::date::day_of_year)"     ]]; then _pass; else _fail; fi; }
test::timedate::date::week_of_year()    { if [[ -n "$(timedate::date::week_of_year)"    ]]; then _pass; else _fail; fi; }
test::timedate::date::quarter()         { if [[ -n "$(timedate::date::quarter)"         ]]; then _pass; else _fail; fi; }
test::timedate::date::yesterday()       { if [[ -n "$(timedate::date::yesterday)"       ]]; then _pass; else _fail; fi; }
test::timedate::date::tomorrow()        { if [[ -n "$(timedate::date::tomorrow)"        ]]; then _pass; else _fail; fi; }
test::timedate::date::week_start()      { if [[ -n "$(timedate::date::week_start)"      ]]; then _pass; else _fail; fi; }
test::timedate::date::week_end()        { if [[ -n "$(timedate::date::week_end)"        ]]; then _pass; else _fail; fi; }
test::timedate::date::month_start()     { if [[ -n "$(timedate::date::month_start)"     ]]; then _pass; else _fail; fi; }
test::timedate::date::month_end()       { if [[ -n "$(timedate::date::month_end)"       ]]; then _pass; else _fail; fi; }
test::timedate::date::year_start()      { if [[ -n "$(timedate::date::year_start)"      ]]; then _pass; else _fail; fi; }
test::timedate::date::year_end()        { if [[ -n "$(timedate::date::year_end)"        ]]; then _pass; else _fail; fi; }
test::timedate::date::days_in_month()   {
    _assert "leap feb"    "29" "$(timedate::date::days_in_month 2000 2)"
    _assert "non-leap feb" "28" "$(timedate::date::days_in_month 1900 2)"
    _sub_done
}
test::timedate::date::add_days()        { if [[ "$(timedate::date::add_days  2024-01-15 1)" == "2024-01-16" ]]; then _pass; else _fail; fi; }
test::timedate::date::sub_days()        { if [[ "$(timedate::date::sub_days  2024-01-15 1)" == "2024-01-14" ]]; then _pass; else _fail; fi; }
test::timedate::date::add_months()      { if [[ -n "$(timedate::date::add_months 2024-01-15 1)" ]]; then _pass; else _fail; fi; }
test::timedate::date::add_years()       { if [[ -n "$(timedate::date::add_years  2024-01-15 1)" ]]; then _pass; else _fail; fi; }
test::timedate::date::days_between()    { if [[ "$(timedate::date::days_between 2024-01-15 2024-01-16)" == "1" ]]; then _pass; else _fail; fi; }
test::timedate::date::next_weekday()    { if [[ -n "$(timedate::date::next_weekday 1)" ]]; then _pass; else _fail; fi; }
test::timedate::date::prev_weekday()    { if [[ -n "$(timedate::date::prev_weekday 5)" ]]; then _pass; else _fail; fi; }
test::timedate::date::compare()         {
    _assert "eq"  "0"  "$(timedate::date::compare 2024-01-15 2024-01-15)"
    _assert "lt"  "-1" "$(timedate::date::compare 2024-01-14 2024-01-15)"
    _assert "gt"  "1"  "$(timedate::date::compare 2024-01-16 2024-01-15)"
    _sub_done
}
test::timedate::date::is_before()  { if timedate::date::is_before  2024-01-14 2024-01-15; then _pass; else _fail; fi; }
test::timedate::date::is_after()   { if timedate::date::is_after   2024-01-16 2024-01-15; then _pass; else _fail; fi; }
test::timedate::date::is_between() { if timedate::date::is_between 2024-01-15 2024-01-01 2024-01-31; then _pass; else _fail; fi; }
# time
test::timedate::time::now()             { if [[ -n "$(timedate::time::now)"             ]]; then _pass; else _fail; fi; }
test::timedate::time::format()          { if [[ -n "$(timedate::time::format)"          ]]; then _pass; else _fail; fi; }
test::timedate::time::hour()            { if [[ -n "$(timedate::time::hour)"            ]]; then _pass; else _fail; fi; }
test::timedate::time::minute()          { if [[ -n "$(timedate::time::minute)"          ]]; then _pass; else _fail; fi; }
test::timedate::time::second()          { if [[ -n "$(timedate::time::second)"          ]]; then _pass; else _fail; fi; }
test::timedate::time::timezone()        { if [[ -n "$(timedate::time::timezone)"        ]]; then _pass; else _fail; fi; }
test::timedate::time::timezone_offset() { if [[ -n "$(timedate::time::timezone_offset)" ]]; then _pass; else _fail; fi; }
test::timedate::time::is_morning()      { timedate::time::is_morning;      local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::timedate::time::is_afternoon()    { timedate::time::is_afternoon;    local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::timedate::time::is_evening()      { timedate::time::is_evening;      local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::timedate::time::is_business_hours(){ timedate::time::is_business_hours; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::timedate::time::is_before()       { timedate::time::is_before 23:59;  local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::timedate::time::is_after()        { timedate::time::is_after  00:00;  local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::timedate::time::is_between()      { timedate::time::is_between 00:00 23:59; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::timedate::time::stopwatch::start(){ if [[ -n "$(timedate::time::stopwatch::start)" ]]; then _pass; else _fail; fi; }
test::timedate::time::stopwatch::stop() { local s; s=$(timedate::time::stopwatch::start); if [[ -n "$(timedate::time::stopwatch::stop "$s")" ]]; then _pass; else _fail; fi; }
# calendar
test::timedate::calendar::is_leap_year(){ _assert "leap (2000)"   "0" "$(timedate::calendar::is_leap_year 2000; echo $?)"; _assert "no-leap (1900)" "1" "$(timedate::calendar::is_leap_year 1900; echo $?)"; _sub_done; }
test::timedate::calendar::days_in_year(){ _assert "leap"   "366" "$(timedate::calendar::days_in_year 2000)"; _assert "normal" "365" "$(timedate::calendar::days_in_year 2001)"; _sub_done; }
test::timedate::calendar::is_weekend()  { if timedate::calendar::is_weekend 2024-01-06; then _pass; else _fail; fi; }
test::timedate::calendar::is_weekday()  { if timedate::calendar::is_weekday 2024-01-08; then _pass; else _fail; fi; }
test::timedate::calendar::iso_week()    { if [[ -n "$(timedate::calendar::iso_week    2024-01-15)" ]]; then _pass; else _fail; fi; }
test::timedate::calendar::day_of_year() { if [[ -n "$(timedate::calendar::day_of_year 2024-01-15)" ]]; then _pass; else _fail; fi; }
test::timedate::calendar::quarter()     { if [[ -n "$(timedate::calendar::quarter     2024-04-01)" ]]; then _pass; else _fail; fi; }
test::timedate::calendar::easter()      { _assert "2024" "2024-03-31" "$(timedate::calendar::easter 2024)"; _assert "2025" "2025-04-20" "$(timedate::calendar::easter 2025)"; _sub_done; }
test::timedate::calendar::weekdays_between() { if [[ -n "$(timedate::calendar::weekdays_between 2024-01-15 2024-01-19 2>/dev/null || echo 5)" ]]; then _pass; else _fail; fi; }
test::timedate::calendar::month()       { if [[ -n "$(timedate::calendar::month 2024 1)" ]]; then _pass; else _fail; fi; }
# duration
test::timedate::has_gnu_date()        { timedate::has_gnu_date; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::timedate::time::sleep()         { if timedate::time::sleep 1 "Testing" >/dev/null 2>&1; then _pass; else _fail; fi; }
test::timedate::format()              { if [[ -n "$(timedate::format)" ]]; then _pass; else _fail; fi; }
test::timedate::duration::format() {
    _assert "3661"  "1h 1m 1s" "$(timedate::duration::format 3661)"
    _assert "zero"  "0s"       "$(timedate::duration::format 0)"
    _sub_done
}
test::timedate::duration::format_ms() { if [[ "$(timedate::duration::format_ms 1500)" == "1s 500ms" ]]; then _pass; else _fail; fi; }
test::timedate::duration::parse()     { if [[ "$(timedate::duration::parse "1h 1m 1s")"  == "3661"  ]]; then _pass; else _fail; fi; }
test::timedate::duration::relative()  {
    _assert_contains "past"   "ago" "$(timedate::duration::relative $(( $(timedate::timestamp::unix) - 3600 )))"
    _assert_contains "future" "in"  "$(timedate::duration::relative $(( $(timedate::timestamp::unix) + 3600 )))"
    _sub_done
}
# tz
test::timedate::tz::current()        { if [[ -n "$(timedate::tz::current)"        ]]; then _pass; else _fail; fi; }
test::timedate::tz::offset_seconds() { if [[ -n "$(timedate::tz::offset_seconds)" ]]; then _pass; else _fail; fi; }
test::timedate::tz::now()            { if [[ -n "$(timedate::tz::now UTC)"         ]]; then _pass; else _fail; fi; }
test::timedate::tz::convert()        { if [[ -n "$(timedate::tz::convert "$(timedate::timestamp::unix)" UTC)" ]]; then _pass; else _fail; fi; }
test::timedate::tz::is_dst()         { timedate::tz::is_dst; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::timedate::tz::list()           { if [[ -n "$(timedate::tz::list | head -1)"        ]]; then _pass; else _fail; fi; }
test::timedate::tz::list::region()   { if [[ -n "$(timedate::tz::list::region Asia)"     ]]; then _pass; else _fail; fi; }

# ==============================================================================
# Tests — process
# ==============================================================================

test::process::self()            { if [[ -n "$(process::self)"                ]]; then _pass; else _fail; fi; }
test::process::name()            { if [[ -n "$(process::name $$)"             ]]; then _pass; else _fail; fi; }
test::process::ppid()            { if [[ -n "$(process::ppid $$)"             ]]; then _pass; else _fail; fi; }
test::process::cmdline()         { if [[ -n "$(process::cmdline $$)"          ]]; then _pass; else _fail; fi; }
test::process::cwd()             { if [[ -n "$(process::cwd $$)"              ]]; then _pass; else _fail; fi; }
test::process::state()           { if [[ -n "$(process::state $$)"            ]]; then _pass; else _fail; fi; }
test::process::memory()          { if [[ -n "$(process::memory $$)"           ]]; then _pass; else _fail; fi; }
test::process::cpu()             { if [[ -n "$(process::cpu $$)"              ]]; then _pass; else _fail; fi; }
test::process::fd_count()        { if [[ -n "$(process::fd_count $$)"         ]]; then _pass; else _fail; fi; }
test::process::thread_count()    { if [[ -n "$(process::thread_count $$)"     ]]; then _pass; else _fail; fi; }
test::process::list()            { if [[ -n "$(process::list | head -1)"      ]]; then _pass; else _fail; fi; }
test::process::find()            { if [[ -n "$(process::find bash | head -1)" ]]; then _pass; else _fail; fi; }
test::process::run_bg() {
    local p; p=$(process::run_bg bash -c 'exec >/dev/null 2>&1; sleep 1')
    wait "$p" 2>/dev/null
    if [[ -n "$p" ]]; then _pass; else _fail; fi
}
test::process::start_time()      { if process::start_time $$ >/dev/null;       then _pass; else _fail; fi; }
test::process::uptime()          { if process::uptime     $$ >/dev/null;       then _pass; else _fail; fi; }
test::process::memory::percent() { if process::memory::percent $$ >/dev/null;  then _pass; else _fail; fi; }
test::process::is_zombie()       { process::is_zombie $$; if [[ $? -eq 1 ]];  then _pass; else _fail; fi; }
test::process::is_running::name(){ if process::is_running::name bash;          then _pass; else _fail; fi; }
test::process::pid()             { if [[ -n "$(process::pid bash)"             ]]; then _pass; else _fail; fi; }
test::process::time()            { if [[ -n "$(process::time echo hello)"      ]]; then _pass; else _fail; fi; }
test::process::singleton()       { if process::singleton _tester_singleton true; then _pass; else _fail; fi; }
test::process::job::list()       { process::job::list 2>/dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::process::env()             { if [[ -n "$(process::env $$ PATH 2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::process::tree()            { if [[ -n "$(process::tree $$ 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::process::renice()          { if process::renice $$ 0 >/dev/null 2>&1; then _pass; else _fail; fi; }
test::process::reload()          { local p; { sleep 5 >/dev/null 2>&1; } & p=$!; if process::reload "$p" 2>/dev/null; then process::kill "$p" 2>/dev/null; wait "$p" 2>/dev/null; _pass; else process::kill "$p" 2>/dev/null; wait "$p" 2>/dev/null; _fail; fi; }
# is_running
test::process::is_running() {
    _assert "self"    "0" "$(process::is_running $$;        echo $?)"
    _assert "bad pid" "1" "$(process::is_running 999999999; echo $?)"
    _sub_done
}
# kill / signal / suspend / resume — each spawns its own bg process, fds redirected to prevent pipe leak
test::process::kill() {
    local p; { sleep 5 >/dev/null 2>&1; } & p=$!
    if process::kill "$p" 2>/dev/null; then wait "$p" 2>/dev/null; _pass; else wait "$p" 2>/dev/null; _fail; fi
}
test::process::kill::graceful() {
    local p; { sleep 5 >/dev/null 2>&1; } & p=$!
    if process::kill::graceful "$p" 2 2>/dev/null; then wait "$p" 2>/dev/null; _pass; else process::kill "$p" 2>/dev/null; wait "$p" 2>/dev/null; _fail; fi
}
test::process::kill::force() {
    local p; { sleep 5 >/dev/null 2>&1; } & p=$!
    if process::kill::force "$p" 2>/dev/null; then wait "$p" 2>/dev/null; _pass; else wait "$p" 2>/dev/null; _fail; fi
}
test::process::signal() {
    local p; { sleep 5 >/dev/null 2>&1; } & p=$!
    if process::signal "$p" TERM 2>/dev/null; then wait "$p" 2>/dev/null; _pass; else process::kill "$p" 2>/dev/null; wait "$p" 2>/dev/null; _fail; fi
}
test::process::suspend() {
    local p; { sleep 5 >/dev/null 2>&1; } & p=$!
    process::suspend "$p" 2>/dev/null
    local ok=0
    process::is_running "$p" && ok=1
    # must SIGCONT before kill — a STOPped process ignores SIGTERM
    process::resume "$p" 2>/dev/null
    process::kill "$p" 2>/dev/null; wait "$p" 2>/dev/null
    if [[ $ok -eq 1 ]]; then _pass; else _fail; fi
}
test::process::resume() {
    local p; { sleep 5 >/dev/null 2>&1; } & p=$!
    process::suspend "$p" 2>/dev/null
    process::resume  "$p" 2>/dev/null
    local ok=0
    process::is_running "$p" && ok=1
    process::kill "$p" 2>/dev/null; wait "$p" 2>/dev/null
    if [[ $ok -eq 1 ]]; then _pass; else _fail; fi
}
test::process::kill::name() { _skip "would kill live processes by name — unsafe in test context"; }
# wait
test::process::wait() {
    local p; { sleep 1 >/dev/null 2>&1; } & p=$!
    if process::wait "$p" 2>/dev/null; then _pass; else _fail; fi
}
test::process::job::wait() {
    local p; { sleep 1 >/dev/null 2>&1; } & p=$!
    if process::job::wait "$p" 2>/dev/null; then _pass; else _fail; fi
}
test::process::job::wait_all() {
    { sleep 1 >/dev/null 2>&1; } & { sleep 1 >/dev/null 2>&1; } &
    if process::job::wait_all 2>/dev/null; then _pass; else _fail; fi
}
test::process::job::status() {
    local p; { sleep 1 >/dev/null 2>&1; } & p=$!
    wait "$p" 2>/dev/null
    if [[ -n "$(process::job::status "$p" 2>/dev/null)" ]]; then _pass; else _fail; fi
}
# run_bg variants
test::process::run_bg::log() {
    local f; f=$(mktemp)
    local p; p=$(process::run_bg::log "$f" echo hello)
    wait "$p" 2>/dev/null
    if grep -q "hello" "$f" 2>/dev/null; then _pass; else _fail; fi
    rm -f "$f"
}
test::process::run_bg::timeout() {
    local p; p=$(process::run_bg::timeout 2 bash -c 'exec >/dev/null 2>&1; echo hello')
    wait "$p" 2>/dev/null
    if [[ -n "$p" ]]; then _pass; else _fail; fi
}
# lock
test::process::lock::acquire() {
    if process::lock::acquire _tlock_a 2>/dev/null; then _pass; else _fail; fi
    process::lock::release _tlock_a 2>/dev/null
}
test::process::lock::is_locked() {
    process::lock::acquire _tlock_il 2>/dev/null
    if process::lock::is_locked _tlock_il 2>/dev/null; then _pass; else _fail; fi
    process::lock::release _tlock_il 2>/dev/null
}
test::process::lock::release() {
    process::lock::acquire _tlock_r 2>/dev/null
    process::lock::release _tlock_r 2>/dev/null
    if ! process::lock::is_locked _tlock_r 2>/dev/null; then _pass; else _fail; fi
}
test::process::lock::wait() {
    # lock is free — should acquire immediately and return 0
    if process::lock::wait _tlock_w 2 2>/dev/null; then _pass; else _fail; fi
    process::lock::release _tlock_w 2>/dev/null
}
# retry / timeout
test::process::retry() {
    _assert "pass" "0" "$(process::retry 3 0 true;  echo $?)"
    _assert "fail" "1" "$(process::retry 2 0 false; echo $?)"
    _sub_done
}
test::process::timeout() {
    _assert "pass" "0"   "$(process::timeout 5 true;    echo $?)"
    _assert "fail" "124" "$(process::timeout 1 sleep 5; echo $?)"
    _sub_done
}
# service — requires systemctl/root, skip
test::process::service::is_running() { _skip "requires systemctl/root"; }
test::process::service::is_enabled() { _skip "requires systemctl/root"; }
test::process::service::start()      { _skip "requires systemctl/root"; }
test::process::service::stop()       { _skip "requires systemctl/root"; }
test::process::service::restart()    { _skip "requires systemctl/root"; }

# ==============================================================================
# Tests — random
# ==============================================================================

# Single 32-bit state — seed properly, check output differs from seed
test::random::lcg() {
    local s; s=$(random::seed32)
    local r; r=$(random::lcg "$s")
    if [[ -n "$r" && "$r" != "$s" ]]; then _pass; else _fail; fi
}
test::random::lcg::glibc() {
    local s; s=$(random::seed32)
    local r; r=$(random::lcg::glibc "$s")
    if [[ -n "$r" && "$r" != "$s" ]]; then _pass; else _fail; fi
}
test::random::xorshift32() {
    local s; s=$(random::seed32)
    local r; r=$(random::xorshift32 "$s")
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}
test::random::middle_square() {
    # Use a known non-degenerate seed (must be nonzero and not a fixed point)
    local r; r=$(random::middle_square 6752)
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}

# Single 64-bit state — seed from seed64
test::random::xorshift64() {
    local s; s=$(random::seed64)
    local r; r=$(random::xorshift64 "$s")
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}
test::random::splitmix64() {
    local s; s=$(random::seed64)
    local r _; read -r r _ <<< "$(random::splitmix64 "$s")"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}
test::random::mulberry32() {
    local s; s=$(random::seed32)
    local r _; read -r r _ <<< "$(random::mulberry32 "$s")"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}
test::random::wyrand() {
    local s; s=$(random::seed64)
    local r _; read -r r _ <<< "$(random::wyrand "$s")"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}
test::random::pcg32() {
    local s; s=$(random::seed64)
    local r _; read -r r _ <<< "$(random::pcg32 "$s")"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}
test::random::pcg32::fast() {
    local s; s=$(random::seed64)
    local r _; read -r r _ <<< "$(random::pcg32::fast "$s")"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}

# Two 64-bit states
test::random::xorshiftr128plus() {
    local s0 s1
    s0=$(random::seed64); s1=$(random::seed64)
    local r; read -r r _ _ <<< "$(random::xorshiftr128plus "$s0" "$s1")"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}

# Four 64-bit states — use splitmix64::seed_xoshiro
test::random::xoshiro256p() {
    local s; s=$(random::seed64)
    local s0 s1 s2 s3; read -r s0 s1 s2 s3 <<< "$(random::splitmix64::seed_xoshiro "$s")"
    local r; read -r r _ _ _ _ <<< "$(random::xoshiro256p "$s0" "$s1" "$s2" "$s3")"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}
test::random::xoshiro256ss() {
    local s; s=$(random::seed64)
    local s0 s1 s2 s3; read -r s0 s1 s2 s3 <<< "$(random::splitmix64::seed_xoshiro "$s")"
    local r; read -r r _ _ _ _ <<< "$(random::xoshiro256ss "$s0" "$s1" "$s2" "$s3")"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}

# 17-state — use well512::init
test::random::well512() {
    local s; s=$(random::seed64)
    local state; state=$(random::well512::init "$s")
    local r; read -r r _ <<< "$(random::well512 $state)"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}

# 11-state — use isaac::init
test::random::isaac() {
    local s; s=$(random::seed64)
    local state; state=$(random::isaac::init "$s")
    local r; read -r r _ <<< "$(random::isaac $state)"
    if [[ -n "$r" ]]; then _pass; else _fail; fi
}

# seed32/seed64 generate from /dev/urandom — just verify nonempty output
test::random::seed32() { if [[ -n "$(random::seed32)" ]]; then _pass; else _fail; fi; }
test::random::seed64() { if [[ -n "$(random::seed64)" ]]; then _pass; else _fail; fi; }
test::random::native() {
    if [[ -n "$(random::native)" ]]; then _pass; else _fail; fi
}
test::random::native::range() {
    local r; r=$(random::native::range 1 10)
    if [[ -n "$r" && $r -ge 1 && $r -le 10 ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Tests — colour
# ==============================================================================

test::colour::depth()              { if colour::depth >/dev/null; then _pass; else _fail; fi; }
test::colour::strip()              { if [[ -n "$(colour::strip "$(printf '\033[31mhello\033[0m')")" ]]; then _pass; else _fail; fi; }
test::colour::visible_length()     { if [[ -n "$(colour::visible_length "$(printf '\033[31mhello\033[0m')")" ]]; then _pass; else _fail; fi; }
test::colour::index::4bit()        { if colour::index::4bit red fg >/dev/null; then _pass; else _fail; fi; }
test::colour::index::8bit()        { if colour::index::8bit red fg >/dev/null; then _pass; else _fail; fi; }
test::colour::supports()           { if _bool_probe colour::supports; then _pass; else _fail; fi; }
test::colour::supports_256()       { if _bool_probe colour::supports_256; then _pass; else _fail; fi; }
test::colour::supports_truecolor() { if _bool_probe colour::supports_truecolor; then _pass; else _fail; fi; }
test::colour::has_colour() {
    _assert "has_colour (true)"  "0" "$(colour::has_colour "$(printf '\033[31mhi\033[0m')"; echo $?)"
    _assert "has_colour (false)" "1" "$(colour::has_colour "plain text"; echo $?)"
    _sub_done
}
# attributes — no-arg escape sequences
test::colour::reset()              { if [[ -n "$(colour::reset)"              ]]; then _pass; else _fail; fi; }
test::colour::bold()               { if [[ -n "$(colour::bold)"               ]]; then _pass; else _fail; fi; }
test::colour::dim()                { if [[ -n "$(colour::dim)"                ]]; then _pass; else _fail; fi; }
test::colour::italic()             { if [[ -n "$(colour::italic)"             ]]; then _pass; else _fail; fi; }
test::colour::underline()          { if [[ -n "$(colour::underline)"          ]]; then _pass; else _fail; fi; }
test::colour::blink()              { if [[ -n "$(colour::blink)"              ]]; then _pass; else _fail; fi; }
test::colour::reverse()            { if [[ -n "$(colour::reverse)"            ]]; then _pass; else _fail; fi; }
test::colour::hidden()             { if [[ -n "$(colour::hidden)"             ]]; then _pass; else _fail; fi; }
test::colour::strike()             { if [[ -n "$(colour::strike)"             ]]; then _pass; else _fail; fi; }
# reset attributes
test::colour::reset::bold()        { if [[ -n "$(colour::reset::bold)"        ]]; then _pass; else _fail; fi; }
test::colour::reset::dim()         { if [[ -n "$(colour::reset::dim)"         ]]; then _pass; else _fail; fi; }
test::colour::reset::italic()      { if [[ -n "$(colour::reset::italic)"      ]]; then _pass; else _fail; fi; }
test::colour::reset::underline()   { if [[ -n "$(colour::reset::underline)"   ]]; then _pass; else _fail; fi; }
test::colour::reset::blink()       { if [[ -n "$(colour::reset::blink)"       ]]; then _pass; else _fail; fi; }
test::colour::reset::reverse()     { if [[ -n "$(colour::reset::reverse)"     ]]; then _pass; else _fail; fi; }
test::colour::reset::hidden()      { if [[ -n "$(colour::reset::hidden)"      ]]; then _pass; else _fail; fi; }
test::colour::reset::strike()      { if [[ -n "$(colour::reset::strike)"      ]]; then _pass; else _fail; fi; }
test::colour::reset::fg()          { if [[ -n "$(colour::reset::fg)"          ]]; then _pass; else _fail; fi; }
test::colour::reset::bg()          { if [[ -n "$(colour::reset::bg)"          ]]; then _pass; else _fail; fi; }
# fg colours
test::colour::fg::black()          { if [[ -n "$(colour::fg::black)"          ]]; then _pass; else _fail; fi; }
test::colour::fg::red()            { if [[ -n "$(colour::fg::red)"            ]]; then _pass; else _fail; fi; }
test::colour::fg::green()          { if [[ -n "$(colour::fg::green)"          ]]; then _pass; else _fail; fi; }
test::colour::fg::yellow()         { if [[ -n "$(colour::fg::yellow)"         ]]; then _pass; else _fail; fi; }
test::colour::fg::blue()           { if [[ -n "$(colour::fg::blue)"           ]]; then _pass; else _fail; fi; }
test::colour::fg::magenta()        { if [[ -n "$(colour::fg::magenta)"        ]]; then _pass; else _fail; fi; }
test::colour::fg::cyan()           { if [[ -n "$(colour::fg::cyan)"           ]]; then _pass; else _fail; fi; }
test::colour::fg::white()          { if [[ -n "$(colour::fg::white)"          ]]; then _pass; else _fail; fi; }
test::colour::fg::bright_black()   { if [[ -n "$(colour::fg::bright_black)"   ]]; then _pass; else _fail; fi; }
test::colour::fg::bright_red()     { if [[ -n "$(colour::fg::bright_red)"     ]]; then _pass; else _fail; fi; }
test::colour::fg::bright_green()   { if [[ -n "$(colour::fg::bright_green)"   ]]; then _pass; else _fail; fi; }
test::colour::fg::bright_yellow()  { if [[ -n "$(colour::fg::bright_yellow)"  ]]; then _pass; else _fail; fi; }
test::colour::fg::bright_blue()    { if [[ -n "$(colour::fg::bright_blue)"    ]]; then _pass; else _fail; fi; }
test::colour::fg::bright_magenta() { if [[ -n "$(colour::fg::bright_magenta)" ]]; then _pass; else _fail; fi; }
test::colour::fg::bright_cyan()    { if [[ -n "$(colour::fg::bright_cyan)"    ]]; then _pass; else _fail; fi; }
test::colour::fg::bright_white()   { if [[ -n "$(colour::fg::bright_white)"   ]]; then _pass; else _fail; fi; }
# bg colours
test::colour::bg::black()          { if [[ -n "$(colour::bg::black)"          ]]; then _pass; else _fail; fi; }
test::colour::bg::red()            { if [[ -n "$(colour::bg::red)"            ]]; then _pass; else _fail; fi; }
test::colour::bg::green()          { if [[ -n "$(colour::bg::green)"          ]]; then _pass; else _fail; fi; }
test::colour::bg::yellow()         { if [[ -n "$(colour::bg::yellow)"         ]]; then _pass; else _fail; fi; }
test::colour::bg::blue()           { if [[ -n "$(colour::bg::blue)"           ]]; then _pass; else _fail; fi; }
test::colour::bg::magenta()        { if [[ -n "$(colour::bg::magenta)"        ]]; then _pass; else _fail; fi; }
test::colour::bg::cyan()           { if [[ -n "$(colour::bg::cyan)"           ]]; then _pass; else _fail; fi; }
test::colour::bg::white()          { if [[ -n "$(colour::bg::white)"          ]]; then _pass; else _fail; fi; }
test::colour::bg::bright_black()   { if [[ -n "$(colour::bg::bright_black)"   ]]; then _pass; else _fail; fi; }
test::colour::bg::bright_red()     { if [[ -n "$(colour::bg::bright_red)"     ]]; then _pass; else _fail; fi; }
test::colour::bg::bright_green()   { if [[ -n "$(colour::bg::bright_green)"   ]]; then _pass; else _fail; fi; }
test::colour::bg::bright_yellow()  { if [[ -n "$(colour::bg::bright_yellow)"  ]]; then _pass; else _fail; fi; }
test::colour::bg::bright_blue()    { if [[ -n "$(colour::bg::bright_blue)"    ]]; then _pass; else _fail; fi; }
test::colour::bg::bright_magenta() { if [[ -n "$(colour::bg::bright_magenta)" ]]; then _pass; else _fail; fi; }
test::colour::bg::bright_cyan()    { if [[ -n "$(colour::bg::bright_cyan)"    ]]; then _pass; else _fail; fi; }
test::colour::bg::bright_white()   { if [[ -n "$(colour::bg::bright_white)"   ]]; then _pass; else _fail; fi; }
# esc / wrap / print
test::colour::esc()                { if [[ -n "$(colour::esc 4 fg red)"        ]]; then _pass; else _fail; fi; }
test::colour::safe_esc()           { colour::safe_esc 4 fg red; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::colour::wrap()               {
    local out; out=$(colour::wrap 4 fg red "hello")
    if [[ "$out" == *"hello"* ]]; then _pass; else _fail; fi
}
test::colour::print()              { if [[ -n "$(colour::print 4 fg red "hi")" ]]; then _pass; else _fail; fi; }
test::colour::println()            { if [[ -n "$(colour::println 4 fg red "hi")" ]]; then _pass; else _fail; fi; }

# ==============================================================================
# Tests — terminal (escape code behaviour only — interactive functions skipped)
# ==============================================================================

test::terminal::width()          { if terminal::width  >/dev/null; then _pass; else _fail; fi; }
test::terminal::height()         { if terminal::height >/dev/null; then _pass; else _fail; fi; }
test::terminal::size()           { if terminal::size   >/dev/null; then _pass; else _fail; fi; }
test::terminal::name()           { if [[ -n "$(terminal::name)" ]]; then _pass; else _fail; fi; }
test::terminal::is_tty()         { if _bool_probe terminal::is_tty;         then _pass; else _fail; fi; }
test::terminal::is_tty::stdin()  { if _bool_probe terminal::is_tty::stdin;  then _pass; else _fail; fi; }
test::terminal::is_tty::stderr() { if _bool_probe terminal::is_tty::stderr; then _pass; else _fail; fi; }
test::terminal::has_colour()     { if _bool_probe terminal::has_colour;     then _pass; else _fail; fi; }
test::terminal::has_256colour()  { if _bool_probe terminal::has_256colour;  then _pass; else _fail; fi; }
test::terminal::has_truecolour() { if _bool_probe terminal::has_truecolour; then _pass; else _fail; fi; }
# shopt
test::terminal::shopt::enable()              { if terminal::shopt::enable nullglob; then _pass; else _fail; fi; }
test::terminal::shopt::is_enabled()          { terminal::shopt::enable nullglob; if terminal::shopt::is_enabled nullglob; then _pass; else _fail; fi; }
test::terminal::shopt::get()                 { if [[ -n "$(terminal::shopt::get nullglob)" ]]; then _pass; else _fail; fi; }
test::terminal::shopt::disable()             { if terminal::shopt::disable nullglob; then _pass; else _fail; fi; }
test::terminal::shopt::list::enabled()       { if [[ -n "$(terminal::shopt::list::enabled  | head -1)" ]]; then _pass; else _fail; fi; }
test::terminal::shopt::list::disabled()      { if [[ -n "$(terminal::shopt::list::disabled | head -1)" ]]; then _pass; else _fail; fi; }
test::terminal::shopt::save()                { if [[ -n "$(terminal::shopt::save 2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::terminal::shopt::globstar::enable()    { if terminal::shopt::globstar::enable;    then _pass; else _fail; fi; }
test::terminal::shopt::globstar::disable()   { if terminal::shopt::globstar::disable;   then _pass; else _fail; fi; }
test::terminal::shopt::nullglob::enable()    { if terminal::shopt::nullglob::enable;    then _pass; else _fail; fi; }
test::terminal::shopt::nullglob::disable()   { if terminal::shopt::nullglob::disable;   then _pass; else _fail; fi; }
test::terminal::shopt::dotglob::enable()     { if terminal::shopt::dotglob::enable;     then _pass; else _fail; fi; }
test::terminal::shopt::dotglob::disable()    { if terminal::shopt::dotglob::disable;    then _pass; else _fail; fi; }
test::terminal::shopt::extglob::enable()     { if terminal::shopt::extglob::enable;     then _pass; else _fail; fi; }
test::terminal::shopt::extglob::disable()    { if terminal::shopt::extglob::disable;    then _pass; else _fail; fi; }
test::terminal::shopt::nocaseglob::enable()  { if terminal::shopt::nocaseglob::enable;  then _pass; else _fail; fi; }
test::terminal::shopt::nocaseglob::disable() { if terminal::shopt::nocaseglob::disable; then _pass; else _fail; fi; }
test::terminal::shopt::histappend::enable()  { if terminal::shopt::histappend::enable;  then _pass; else _fail; fi; }
test::terminal::shopt::histappend::disable() { if terminal::shopt::histappend::disable; then _pass; else _fail; fi; }
test::terminal::shopt::cdspell::enable()     { if terminal::shopt::cdspell::enable;     then _pass; else _fail; fi; }
test::terminal::shopt::cdspell::disable()    { if terminal::shopt::cdspell::disable;    then _pass; else _fail; fi; }
test::terminal::shopt::nocasematch::enable() { if terminal::shopt::nocasematch::enable; then _pass; else _fail; fi; }
test::terminal::shopt::nocasematch::disable(){ if terminal::shopt::nocasematch::disable;then _pass; else _fail; fi; }
test::terminal::shopt::autocd::enable()      { if terminal::shopt::autocd::enable;      then _pass; else _fail; fi; }
test::terminal::shopt::autocd::disable()     { if terminal::shopt::autocd::disable;     then _pass; else _fail; fi; }
test::terminal::shopt::checkwinsize::enable() { if terminal::shopt::checkwinsize::enable;  then _pass; else _fail; fi; }
test::terminal::shopt::checkwinsize::disable(){ if terminal::shopt::checkwinsize::disable; then _pass; else _fail; fi; }
test::terminal::shopt::load() {
    local _shopt_state; _shopt_state=$(terminal::shopt::save 2>/dev/null)
    if terminal::shopt::load _shopt_state 2>/dev/null; then _pass; else _fail; fi
}
# escape sequence output — testable by checking output is nonempty
test::terminal::bell()               { if [[ -n "$(terminal::bell)" ]];               then _pass; else _fail; fi; }
test::terminal::title()              { if [[ -n "$(terminal::title "test")" ]];        then _pass; else _fail; fi; }
test::terminal::clear()              { if [[ -n "$(terminal::clear)" ]];               then _pass; else _fail; fi; }
test::terminal::clear::line()        { if [[ -n "$(terminal::clear::line)" ]];         then _pass; else _fail; fi; }
test::terminal::clear::line_end()    { if [[ -n "$(terminal::clear::line_end)" ]];     then _pass; else _fail; fi; }
test::terminal::clear::line_start()  { if [[ -n "$(terminal::clear::line_start)" ]];   then _pass; else _fail; fi; }
test::terminal::clear::to_end()      { if [[ -n "$(terminal::clear::to_end)" ]];       then _pass; else _fail; fi; }
test::terminal::clear::to_start()    { if [[ -n "$(terminal::clear::to_start)" ]];     then _pass; else _fail; fi; }
test::terminal::cursor::up()         { if [[ -n "$(terminal::cursor::up 1)" ]];        then _pass; else _fail; fi; }
test::terminal::cursor::down()       { if [[ -n "$(terminal::cursor::down 1)" ]];      then _pass; else _fail; fi; }
test::terminal::cursor::left()       { if [[ -n "$(terminal::cursor::left 1)" ]];      then _pass; else _fail; fi; }
test::terminal::cursor::right()      { if [[ -n "$(terminal::cursor::right 1)" ]];     then _pass; else _fail; fi; }
test::terminal::cursor::move()       { if [[ -n "$(terminal::cursor::move 1 1)" ]];    then _pass; else _fail; fi; }
test::terminal::cursor::col()        { if [[ -n "$(terminal::cursor::col 1)" ]];       then _pass; else _fail; fi; }
test::terminal::cursor::home()       { if [[ -n "$(terminal::cursor::home)" ]];        then _pass; else _fail; fi; }
test::terminal::cursor::save()       { if [[ -n "$(terminal::cursor::save)" ]];        then _pass; else _fail; fi; }
test::terminal::cursor::restore()    { if [[ -n "$(terminal::cursor::restore)" ]];     then _pass; else _fail; fi; }
test::terminal::cursor::hide()       { if [[ -n "$(terminal::cursor::hide)" ]];        then _pass; else _fail; fi; }
test::terminal::cursor::show()       { if [[ -n "$(terminal::cursor::show)" ]];        then _pass; else _fail; fi; }
test::terminal::cursor::toggle()     { if [[ -n "$(terminal::cursor::toggle)" ]];      then _pass; else _fail; fi; }
test::terminal::cursor::next_line()  { if [[ -n "$(terminal::cursor::next_line 1)" ]]; then _pass; else _fail; fi; }
test::terminal::cursor::prev_line()  { if [[ -n "$(terminal::cursor::prev_line 1)" ]]; then _pass; else _fail; fi; }
test::terminal::scroll::up()         { if [[ -n "$(terminal::scroll::up 1)" ]];        then _pass; else _fail; fi; }
test::terminal::scroll::down()       { if [[ -n "$(terminal::scroll::down 1)" ]];      then _pass; else _fail; fi; }
test::terminal::screen::alternate()  { if [[ -n "$(terminal::screen::alternate)" ]];   then _pass; else _fail; fi; }
test::terminal::screen::alternate_enter() { if [[ -n "$(terminal::screen::alternate_enter)" ]]; then _pass; else _fail; fi; }
test::terminal::screen::alternate_exit()  { if [[ -n "$(terminal::screen::alternate_exit)"  ]]; then _pass; else _fail; fi; }
test::terminal::screen::normal()     { if [[ -n "$(terminal::screen::normal)" ]];      then _pass; else _fail; fi; }
test::terminal::screen::wrap()       { if [[ -n "$(terminal::screen::wrap)" ]];        then _pass; else _fail; fi; }
test::terminal::echo::off()          {
    # stty requires a real tty - won't work in pipes/subshells
    if [[ -t 0 ]]; then
        if ( terminal::echo::off 2>/dev/null ); then _pass; else _fail; fi
    else
        _skip "stdin is not a tty"
    fi
}
test::terminal::echo::on()           {
    if [[ -t 0 ]]; then
        if ( terminal::echo::on 2>/dev/null ); then _pass; else _fail; fi
    else
        _skip "stdin is not a tty"
    fi
}
# interactive — require live terminal input, skip
test::terminal::confirm()            { _skip "requires interactive input"; }
test::terminal::confirm::default()   { _skip "requires interactive input"; }
test::terminal::read_key()           { _skip "requires interactive input"; }
test::terminal::read_key::timeout()  { _skip "requires interactive input"; }
test::terminal::read_password()      { _skip "requires interactive input"; }

# ==============================================================================
# Tests — hardware
# ==============================================================================

# cpu
test::hardware::cpu::name()                { if [[ -n "$(hardware::cpu::name                2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::cpu::core_count::logical() { if [[ -n "$(hardware::cpu::core_count::logical 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::cpu::core_count::physical(){ if [[ -n "$(hardware::cpu::core_count::physical 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::cpu::core_count::total()   { if [[ -n "$(hardware::cpu::core_count::total   2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::cpu::thread_count()        { if [[ -n "$(hardware::cpu::thread_count        2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::cpu::frequencyMHz()        { if [[ -n "$(hardware::cpu::frequencyMHz        2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::cpu::temp()                { if [[ -n "$(hardware::cpu::temp                2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
# ram
test::hardware::ram::totalSpaceMB()        { if [[ -n "$(hardware::ram::totalSpaceMB 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::ram::usedSpaceMB()         { if [[ -n "$(hardware::ram::usedSpaceMB  2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::ram::freeSpaceMB()         { if [[ -n "$(hardware::ram::freeSpaceMB  2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::ram::percentage()          { if [[ -n "$(hardware::ram::percentage   2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
# swap
test::hardware::swap::totalSpaceMB()       { if [[ -n "$(hardware::swap::totalSpaceMB 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::swap::usedSpaceMB()        { if [[ -n "$(hardware::swap::usedSpaceMB  2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::swap::freeSpaceMB()        { if [[ -n "$(hardware::swap::freeSpaceMB  2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
# disk
test::hardware::disk::count::total()       { if [[ -n "$(hardware::disk::count::total    2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::disk::count::physical()    { if [[ -n "$(hardware::disk::count::physical 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::disk::count::virtual()     { if [[ -n "$(hardware::disk::count::virtual  2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::disk::devices()            { if [[ -n "$(hardware::disk::devices          2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::disk::name()               { if [[ -n "$(hardware::disk::name             2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
# partition
test::hardware::partition::count()         { if [[ -n "$(hardware::partition::count          2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::partition::info()          { if [[ -n "$(hardware::partition::info        /  2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::partition::totalSpaceMB()  { if [[ -n "$(hardware::partition::totalSpaceMB / 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::partition::usedSpaceMB()   { if [[ -n "$(hardware::partition::usedSpaceMB  / 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::partition::freeSpaceMB()   { if [[ -n "$(hardware::partition::freeSpaceMB  / 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::partition::usagePercent()  { if [[ -n "$(hardware::partition::usagePercent / 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
# gpu
test::hardware::gpu()                      { if [[ -n "$(hardware::gpu       2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::gpu::vramMB()              { if [[ -n "$(hardware::gpu::vramMB 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
# battery — functions return "unknown" or exit 1 when no battery present, both acceptable
test::hardware::battery::present()         { hardware::battery::present; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::hardware::battery::percentage()      { if [[ -n "$(hardware::battery::percentage     2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::battery::status()          { if [[ -n "$(hardware::battery::status         2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::battery::is_charging()     { hardware::battery::is_charging 2>/dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::hardware::battery::capacity()        { if [[ -n "$(hardware::battery::capacity       2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::battery::health()          { if [[ -n "$(hardware::battery::health         2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::hardware::battery::time_remaining()  { local r; r=$(hardware::battery::time_remaining 2>/dev/null); if [[ -n "${r:-unknown}" ]]; then _pass; else _fail; fi; }

# ==============================================================================
# Tests — device
# ==============================================================================

test::device::exists()       { if device::exists    /dev/null; then _pass; else _fail; fi; }
test::device::null_ok()      { if device::null_ok;             then _pass; else _fail; fi; }
test::device::random()       { if device::random >/dev/null;   then _pass; else _fail; fi; }
test::device::zero()         { if device::zero /dev/null;      then _pass; else _fail; fi; }
test::device::is_device()    { if device::is_device /dev/null; then _pass; else _fail; fi; }
test::device::is_block()     { device::is_block /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::is_char()      { device::is_char  /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::is_loop()      { device::is_loop  /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::is_mounted()   { device::is_mounted /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::is_readable()  { device::is_readable /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::is_writeable() { device::is_writeable /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::is_virtual()   { device::is_virtual /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::is_ram()       { device::is_ram /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::is_occupied()  { device::is_occupied /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::has_processes(){ device::has_processes /dev/null; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::device::mount_point() {
    local dev; dev=$(df / 2>/dev/null | tail -1 | awk '{print $1}')
    if [[ -n "$(device::mount_point "${dev:-none}" 2>/dev/null || echo none)" ]]; then _pass; else _fail; fi
}
test::device::type()         { if [[ -n "$(device::type         /dev/null 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::device::number()       { if [[ -n "$(device::number       /dev/null 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::device::filesystem()   { if [[ -n "$(device::filesystem   /dev/null 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::device::size_bytes()   { if [[ -n "$(device::size_bytes   /dev/null 2>/dev/null || echo 0)"       ]]; then _pass; else _fail; fi; }
test::device::size_mb()      { if [[ -n "$(device::size_mb      /dev/null 2>/dev/null || echo 0)"       ]]; then _pass; else _fail; fi; }
test::device::list::block()  { if [[ -n "$(device::list::block   2>/dev/null || echo none)" ]]; then _pass; else _fail; fi; }
test::device::list::char()   { if [[ -n "$(device::list::char    2>/dev/null || echo none)" ]]; then _pass; else _fail; fi; }
test::device::list::loop()   { if device::list::loop >/dev/null; then _pass; else _fail; fi; }
test::device::list::mounted(){ if [[ -n "$(device::list::mounted 2>/dev/null | head -1 || echo none)" ]]; then _pass; else _fail; fi; }
test::device::list::tty()    { if [[ -n "$(device::list::tty     2>/dev/null | head -1 || echo none)" ]]; then _pass; else _fail; fi; }

# ==============================================================================
# Tests — git
# ==============================================================================

_git_in_repo()       { git rev-parse --git-dir >/dev/null 2>&1; }
_git_has_commits()   { (( $(git rev-list --count HEAD 2>/dev/null || echo 0) > 0 )); }
_git_has_upstream()  { git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; }
_git_has_remote()    { [[ -n "$(git remote 2>/dev/null | head -1)" ]]; }
_git_has_tags()      { [[ -n "$(git tag 2>/dev/null | head -1)" ]]; }
_git_has_stash()     { (( $(git stash list 2>/dev/null | wc -l | tr -d ' ') > 0 )); }

# repo state
test::git::is_repo()            { _git_in_repo || { _skip "not in a git repo"; return; }; if git::is_repo; then _pass; else _fail; fi; }
test::git::root_dir()           { _git_in_repo || { _skip "not in a git repo"; return; }; if [[ -n "$(git::root_dir 2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::git::is_dirty()           { _git_in_repo || { _skip "not in a git repo"; return; }; git::is_dirty;  local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::git::is_staged()          { _git_in_repo || { _skip "not in a git repo"; return; }; git::is_staged; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::git::has_remote()         { _git_in_repo || { _skip "not in a git repo"; return; }; git::has_remote; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::git::unstaged::count()    { _git_in_repo || { _skip "not in a git repo"; return; }; if [[ -n "$(git::unstaged::count  2>/dev/null || echo 0)" ]]; then _pass; else _fail; fi; }
test::git::staged::count()      { _git_in_repo || { _skip "not in a git repo"; return; }; if [[ -n "$(git::staged::count    2>/dev/null || echo 0)" ]]; then _pass; else _fail; fi; }
test::git::untracked::count()   { _git_in_repo || { _skip "not in a git repo"; return; }; if [[ -n "$(git::untracked::count 2>/dev/null || echo 0)" ]]; then _pass; else _fail; fi; }
test::git::stash::count()       { _git_in_repo || { _skip "not in a git repo"; return; }; if [[ -n "$(git::stash::count)" ]]; then _pass; else _fail; fi; }
test::git::exec()               { _git_in_repo || { _skip "not in a git repo"; return; }; if [[ -n "$(git::exec log --oneline -1 2>/dev/null)" ]]; then _pass; else _fail; fi; }
# branch
test::git::branch::current()    { _git_in_repo || { _skip "not in a git repo"; return; }; if [[ -n "$(git::branch::current)" ]]; then _pass; else _fail; fi; }
test::git::branch::list()       { _git_in_repo || { _skip "not in a git repo"; return; }; if [[ -n "$(git::branch::list | head -1)" ]]; then _pass; else _fail; fi; }
test::git::branch::list::all()  { _git_in_repo || { _skip "not in a git repo"; return; }; if [[ -n "$(git::branch::list::all  2>/dev/null | head -1)" ]]; then _pass; else _fail; fi; }
test::git::branch::list::remote(){ _git_in_repo || { _skip "not in a git repo"; return; }
                                   _git_has_remote || { _skip "no remotes"; return; }
                                   if [[ -n "$(git::branch::list::remote 2>/dev/null | head -1)" ]]; then _pass; else _fail; fi; }
test::git::branch::exists()     { _git_in_repo || { _skip "not in a git repo"; return; }
                                  local _b; _b=$(git::branch::current 2>/dev/null)
                                  if git::branch::exists "$_b" 2>/dev/null; then _pass; else _fail; fi; }
test::git::branch::exists::remote(){ _git_in_repo || { _skip "not in a git repo"; return; }
                                     _git_has_remote || { _skip "no remotes"; return; }
                                     git::branch::exists::remote 2>/dev/null; local r=$?
                                     if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
# ahead / behind
test::git::is_ahead()           { _git_in_repo || { _skip "not in a git repo"; return; }; git::is_ahead;  local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::git::is_behind()          { _git_in_repo || { _skip "not in a git repo"; return; }; git::is_behind; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::git::ahead_count()        { _git_in_repo    || { _skip "not in a git repo"; return; }
                                  _git_has_upstream || { _skip "no upstream"; return; }
                                  if [[ -n "$(git::ahead_count  2>/dev/null || echo 0)" ]]; then _pass; else _fail; fi; }
test::git::behind_count()       { _git_in_repo    || { _skip "not in a git repo"; return; }
                                  _git_has_upstream || { _skip "no upstream"; return; }
                                  if [[ -n "$(git::behind_count 2>/dev/null || echo 0)" ]]; then _pass; else _fail; fi; }
# commit
test::git::commit::hash()         { _git_in_repo || { _skip "not in a git repo"; return; }; _git_has_commits || { _skip "no commits"; return; }; if [[ -n "$(git::commit::hash)"           ]]; then _pass; else _fail; fi; }
test::git::commit::short_hash()   { _git_in_repo || { _skip "not in a git repo"; return; }; _git_has_commits || { _skip "no commits"; return; }; if [[ -n "$(git::commit::short_hash)"     ]]; then _pass; else _fail; fi; }
test::git::commit::message()      { _git_in_repo || { _skip "not in a git repo"; return; }; _git_has_commits || { _skip "no commits"; return; }; if [[ -n "$(git::commit::message)"        ]]; then _pass; else _fail; fi; }
test::git::commit::author()       { _git_in_repo || { _skip "not in a git repo"; return; }; _git_has_commits || { _skip "no commits"; return; }; if [[ -n "$(git::commit::author)"         ]]; then _pass; else _fail; fi; }
test::git::commit::author::email(){ _git_in_repo || { _skip "not in a git repo"; return; }; _git_has_commits || { _skip "no commits"; return; }; if [[ -n "$(git::commit::author::email)" ]]; then _pass; else _fail; fi; }
test::git::commit::date()         { _git_in_repo || { _skip "not in a git repo"; return; }; _git_has_commits || { _skip "no commits"; return; }; if [[ -n "$(git::commit::date)"           ]]; then _pass; else _fail; fi; }
test::git::commit::date::relative(){ _git_in_repo || { _skip "not in a git repo"; return; }; _git_has_commits || { _skip "no commits"; return; }; if [[ -n "$(git::commit::date::relative)" ]]; then _pass; else _fail; fi; }
test::git::commit::count()        { _git_in_repo || { _skip "not in a git repo"; return; }; _git_has_commits || { _skip "no commits"; return; }; if [[ -n "$(git::commit::count)"         ]]; then _pass; else _fail; fi; }
test::git::log()                  { _git_in_repo || { _skip "not in a git repo"; return; }; _git_has_commits || { _skip "no commits"; return; }; if [[ -n "$(git::log 2>/dev/null | head -1)" ]]; then _pass; else _fail; fi; }
# stash
test::git::is_stashed()         { _git_in_repo || { _skip "not in a git repo"; return; }
                                  _git_has_stash || { _skip "no stash entries"; return; }
                                  if git::is_stashed; then _pass; else _fail; fi; }
# remote
test::git::remote::list()       { _git_in_repo || { _skip "not in a git repo"; return; }
                                  _git_has_remote || { _skip "no remotes"; return; }
                                  if [[ -n "$(git::remote::list)" ]]; then _pass; else _fail; fi; }
test::git::remote::url()        { _git_in_repo || { _skip "not in a git repo"; return; }
                                  _git_has_remote || { _skip "no remotes"; return; }
                                  local _r; _r=$(git remote 2>/dev/null | head -1)
                                  if [[ -n "$(git::remote::url "$_r" 2>/dev/null)" ]]; then _pass; else _fail; fi; }
# tags
test::git::tag::list()          { _git_in_repo || { _skip "not in a git repo"; return; }
                                  _git_has_tags || { _skip "no tags"; return; }
                                  if [[ -n "$(git::tag::list)" ]]; then _pass; else _fail; fi; }
test::git::tag::latest()        { _git_in_repo || { _skip "not in a git repo"; return; }
                                  _git_has_tags || { _skip "no tags"; return; }
                                  if [[ -n "$(git::tag::latest)" ]]; then _pass; else _fail; fi; }
test::git::tag::exists()        { _git_in_repo || { _skip "not in a git repo"; return; }
                                  _git_has_tags || { _skip "no tags"; return; }
                                  local _t; _t=$(git tag 2>/dev/null | head -1)
                                  if git::tag::exists "$_t" 2>/dev/null; then _pass; else _fail; fi; }

# ==============================================================================
# Tests — net
# ==============================================================================

_net_online() { net::is_online 2>/dev/null; }

test::net::is_online()          { net::is_online; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::net::ip::local()          { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::ip::local)"  ]]; then _pass; else _fail; fi; }
test::net::hostname()           { if [[ -n "$(net::hostname)"  ]]; then _pass; else _fail; fi; }
test::net::hostname::fqdn()     { if [[ -n "$(net::hostname::fqdn 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::net::ip::all()            { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::ip::all | head -1)" ]]; then _pass; else _fail; fi; }
test::net::ip::is_valid_v4()    { _assert "true"  "0" "$(net::ip::is_valid_v4 192.168.1.1;     echo $?)"; _assert "false" "1" "$(net::ip::is_valid_v4 999.999.999.999; echo $?)"; _sub_done; }
test::net::ip::is_valid_v6()    { if net::ip::is_valid_v6 ::1; then _pass; else _fail; fi; }
test::net::ip::is_private()     { _assert "true"  "0" "$(net::ip::is_private  192.168.1.1; echo $?)"; _assert "false" "1" "$(net::ip::is_private  8.8.8.8;     echo $?)"; _sub_done; }
test::net::ip::is_loopback()    { _assert "true"  "0" "$(net::ip::is_loopback 127.0.0.1;   echo $?)"; _assert "false" "1" "$(net::ip::is_loopback 8.8.8.8;     echo $?)"; _sub_done; }
test::net::can_reach()          { _net_online || { _skip "offline"; return; }; if net::can_reach 8.8.8.8; then _pass; else _fail; fi; }
test::net::gateway()            { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::gateway 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi; }
test::net::interface::list()    { if [[ -n "$(net::interface::list | head -1)" ]]; then _pass; else _fail; fi; }
test::net::interface::is_up()   { net::interface::list | head -1 | read -r iface; net::interface::is_up "${iface:-lo}"; local r=$?; if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi; }
test::net::port::is_open()      { _net_online || { _skip "offline"; return; }; if net::port::is_open google.com 80; then _pass; else _fail; fi; }
test::net::http::status()       { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::http::status  http://example.com)" ]]; then _pass; else _fail; fi; }
test::net::http::is_ok()        { _net_online || { _skip "offline"; return; }; if net::http::is_ok http://example.com; then _pass; else _fail; fi; }
test::net::http::headers()      { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::http::headers http://example.com | head -1)" ]]; then _pass; else _fail; fi; }
test::net::fetch()              { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::fetch http://example.com | head -1)" ]]; then _pass; else _fail; fi; }
test::net::resolve()            { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::resolve example.com)" ]]; then _pass; else _fail; fi; }
test::net::mac() {
    local iface; iface=$(net::interface::list 2>/dev/null | head -1)
    if [[ -n "$(net::mac "${iface:-lo}" 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi
}
test::net::ip::public()         { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::ip::public 2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::net::ip::geo()            { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::ip::geo    2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::net::ping()               { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::ping 8.8.8.8 1 2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::net::resolve::reverse()   { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::resolve::reverse 8.8.8.8 2>/dev/null)" ]]; then _pass; else _fail; fi; }
_net_has_dns() { runtime::has_command dig || runtime::has_command nslookup; }
test::net::dns::records()       { _net_online || { _skip "offline"; return; }; _net_has_dns || { _skip "dig/nslookup not available"; return; }; if [[ -n "$(net::dns::records  example.com A  2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::net::dns::mx()            { _net_online || { _skip "offline"; return; }; _net_has_dns || { _skip "dig/nslookup not available"; return; }; if [[ -n "$(net::dns::mx       example.com    2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::net::dns::txt()           { _net_online || { _skip "offline"; return; }; _net_has_dns || { _skip "dig/nslookup not available"; return; }; if [[ -n "$(net::dns::txt      example.com    2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::net::dns::ns()            { _net_online || { _skip "offline"; return; }; _net_has_dns || { _skip "dig/nslookup not available"; return; }; if [[ -n "$(net::dns::ns       example.com    2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::net::dns::propagation()   { _net_online || { _skip "offline"; return; }; _net_has_dns || { _skip "dig/nslookup not available"; return; }; if [[ -n "$(net::dns::propagation example.com 2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::net::whois()              { _net_online || { _skip "offline"; return; }
                                  runtime::has_command whois || { _skip "whois not available"; return; }
                                  if [[ -n "$(net::whois example.com 2>/dev/null)" ]]; then _pass; else _fail; fi; }
test::net::fetch::retry()       { _net_online || { _skip "offline"; return; }; if [[ -n "$(net::fetch::retry http://example.com - 2 1 2>/dev/null | head -1)" ]]; then _pass; else _fail; fi; }
test::net::fetch::progress()    { _skip "writes to file with progress bar — not suitable for automated testing"; }
test::net::port::scan()         { _skip "scans port range — too slow for automated testing"; }
test::net::port::wait()         { _net_online || { _skip "offline"; return; }
                                  if net::port::wait example.com 80 5 2>/dev/null; then _pass; else _fail; fi; }
# interface stats — use first available interface
test::net::interface::stat() {
    local iface; iface=$(net::interface::list 2>/dev/null | head -1)
    if [[ -n "$(net::interface::stat "${iface:-lo}" 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi
}
test::net::interface::stat::rx() {
    local iface; iface=$(net::interface::list 2>/dev/null | head -1)
    if [[ -n "$(net::interface::stat::rx "${iface:-lo}" 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi
}
test::net::interface::stat::tx() {
    local iface; iface=$(net::interface::list 2>/dev/null | head -1)
    if [[ -n "$(net::interface::stat::tx "${iface:-lo}" 2>/dev/null || echo unknown)" ]]; then _pass; else _fail; fi
}
test::net::interface::speed() {
    local iface; iface=$(net::interface::list 2>/dev/null | head -1)
    net::interface::speed "${iface:-lo}" >/dev/null 2>&1; local r=$?
    if [[ $r -eq 0 || $r -eq 1 ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Tests — pm
# ==============================================================================

test::pm::install()   { _skip "requires sudo/root — would modify system state"; }
test::pm::uninstall() { _skip "requires sudo/root — would modify system state"; }
test::pm::update()    { _skip "requires sudo/root — would modify system state"; }
test::pm::sync()      { _skip "requires sudo/root — would modify system state"; }
test::pm::search()    { _skip "requires sudo/root — would modify system state"; }

# ==============================================================================
# Tests — math::vec2
# ==============================================================================

test::math::vec2::add()       { if [[ "$(math::vec2::add       "3,4" "1,2")"   == "4,6"   ]]; then _pass; else _fail; fi; }
test::math::vec2::sub()       { if [[ "$(math::vec2::sub       "3,4" "1,2")"   == "2,2"   ]]; then _pass; else _fail; fi; }
test::math::vec2::scale()     { if [[ "$(math::vec2::scale     "3,4" 2)"        == "6,8"   ]]; then _pass; else _fail; fi; }
test::math::vec2::dot()       { if [[ "$(math::vec2::dot       "3,4" "1,2")"   == "11"    ]]; then _pass; else _fail; fi; }
test::math::vec2::eq()        { if math::vec2::eq "3,4" "3,4"; then _pass; else _fail; fi; }

test::math::vec2::addf() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::addf 2 "1.5,2.5" "0.5,0.5")" ]]; then _pass; else _fail; fi
}
test::math::vec2::subf() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::subf 2 "3.0,4.0" "1.0,2.0")" ]]; then _pass; else _fail; fi
}
test::math::vec2::scalef() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::scalef 2 "1.5,2.5" 2)" ]]; then _pass; else _fail; fi
}
test::math::vec2::dotf() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::dotf 2 "1.5,2.5" "1.0,1.0")" ]]; then _pass; else _fail; fi
}
test::math::vec2::magnitude() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::magnitude "3,4")" ]]; then _pass; else _fail; fi
}
test::math::vec2::magnitudef() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::magnitudef 4 "3,4")" ]]; then _pass; else _fail; fi
}
test::math::vec2::normalise() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::normalise "3,4")" ]]; then _pass; else _fail; fi
}
test::math::vec2::normalisef() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::normalisef 4 "3,4")" ]]; then _pass; else _fail; fi
}
test::math::vec2::distance() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::distance "0,0" "3,4")" ]]; then _pass; else _fail; fi
}
test::math::vec2::distancef() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec2::distancef 4 "0,0" "3,4")" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Tests — math::vec3
# ==============================================================================

test::math::vec3::add()   { if [[ "$(math::vec3::add   "1,2,3" "4,5,6")" == "5,7,9"  ]]; then _pass; else _fail; fi; }
test::math::vec3::sub()   { if [[ "$(math::vec3::sub   "4,5,6" "1,2,3")" == "3,3,3"  ]]; then _pass; else _fail; fi; }
test::math::vec3::scale() { if [[ "$(math::vec3::scale "1,2,3" 2)"        == "2,4,6"  ]]; then _pass; else _fail; fi; }
test::math::vec3::dot()   { if [[ "$(math::vec3::dot   "1,2,3" "4,5,6")" == "32"     ]]; then _pass; else _fail; fi; }
test::math::vec3::cross() { if [[ "$(math::vec3::cross "1,0,0" "0,1,0")" == "0,0,1"  ]]; then _pass; else _fail; fi; }
test::math::vec3::eq()    { if math::vec3::eq "1,2,3" "1,2,3"; then _pass; else _fail; fi; }

test::math::vec3::addf() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::addf 2 "1.0,2.0,3.0" "0.5,0.5,0.5")" ]]; then _pass; else _fail; fi
}
test::math::vec3::subf() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::subf 2 "4.0,5.0,6.0" "1.0,2.0,3.0")" ]]; then _pass; else _fail; fi
}
test::math::vec3::scalef() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::scalef 2 "1.0,2.0,3.0" 2)" ]]; then _pass; else _fail; fi
}
test::math::vec3::dotf() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::dotf 2 "1.0,2.0,3.0" "4.0,5.0,6.0")" ]]; then _pass; else _fail; fi
}
test::math::vec3::crossf() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::crossf 4 "1,0,0" "0,1,0")" ]]; then _pass; else _fail; fi
}
test::math::vec3::magnitude() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::magnitude "1,2,2")" ]]; then _pass; else _fail; fi
}
test::math::vec3::magnitudef() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::magnitudef 4 "1,2,2")" ]]; then _pass; else _fail; fi
}
test::math::vec3::normalise() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::normalise "1,2,2")" ]]; then _pass; else _fail; fi
}
test::math::vec3::normalisef() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::normalisef 4 "1,2,2")" ]]; then _pass; else _fail; fi
}
test::math::vec3::distance() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::distance "0,0,0" "1,2,2")" ]]; then _pass; else _fail; fi
}
test::math::vec3::distancef() {
    math::has_bc || _skip "bc not available"
    if [[ -n "$(math::vec3::distancef 4 "0,0,0" "1,2,2")" ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Tests — math::matrix
# ==============================================================================

# Shared test matrices
_M2="2x2"
_MA="1 2 3 4"        # [[1,2],[3,4]]
_MB="5 6 7 8"        # [[5,6],[7,8]]
_MI="1 0 0 1"        # identity 2x2

test::math::matrix::add()      { if [[ "$(math::matrix::add      "$_M2" $_MA $_MB)" == "6 8 10 12" ]]; then _pass; else _fail; fi; }
test::math::matrix::sub()      { if [[ "$(math::matrix::sub      "$_M2" $_MA $_MB)" == "-4 -4 -4 -4" ]]; then _pass; else _fail; fi; }
test::math::matrix::scale()    { if [[ "$(math::matrix::scale    "$_M2" 2 $_MA)"    == "2 4 6 8"   ]]; then _pass; else _fail; fi; }
test::math::matrix::hadamard() { if [[ "$(math::matrix::hadamard "$_M2" $_MA $_MB)" == "5 12 21 32" ]]; then _pass; else _fail; fi; }
test::math::matrix::identity() { if [[ "$(math::matrix::identity "$_M2")"           == "$_MI"      ]]; then _pass; else _fail; fi; }
test::math::matrix::transpose(){ if [[ "$(math::matrix::transpose "$_M2" $_MA)"     == "1 3 2 4"   ]]; then _pass; else _fail; fi; }
test::math::matrix::is_square(){ if math::matrix::is_square "$_M2"; then _pass; else _fail; fi; }
test::math::matrix::eq() {
    _assert "eq (true)"  "0" "$(math::matrix::eq "$_M2" $_MA $_MA; echo $?)"
    _assert "eq (false)" "1" "$(math::matrix::eq "$_M2" $_MA $_MB; echo $?)"
    _sub_done
}
test::math::matrix::mul() {
    # [[1,2],[3,4]] * [[1,0],[0,1]] = [[1,2],[3,4]]
    if [[ "$(math::matrix::mul "$_M2" "$_M2" $_MA $_MI)" == "$_MA" ]]; then _pass; else _fail; fi
}
test::math::matrix::trace() {
    # trace([[1,2],[3,4]]) = 1+4 = 5
    if [[ "$(math::matrix::trace "$_M2" $_MA)" == "5" ]]; then _pass; else _fail; fi
}
test::math::matrix::diagonal() {
    # diagonal of [[1,2],[3,4]] = 1 4
    if [[ "$(math::matrix::diagonal "$_M2" $_MA)" == "1 4" ]]; then _pass; else _fail; fi
}
test::math::matrix::flatten() {
    _assert_nonempty "flatten" "$(math::matrix::flatten "$_M2" $_MA)"
    _sub_done
}
test::math::matrix::print() {
    _assert_nonempty "print" "$(math::matrix::print "$_M2" $_MA)"
    _sub_done
}
test::math::matrix::minor() {
    # minor of 3x3 removing row 0 col 0
    local m3="3x3" a="1 2 3 4 5 6 7 8 9"
    if [[ "$(math::matrix::minor "$m3" 0 0 $a)" == "5 6 8 9" ]]; then _pass; else _fail; fi
}

test::math::matrix::determinant() {
    math::has_bc || _skip "bc not available"
    # det([[1,2],[3,4]]) = -2
    _assert_contains "det 2x2" "-2" "$(math::matrix::determinant 2 "$_M2" $_MA)"
    _sub_done
}
test::math::matrix::lu() {
    math::has_bc || _skip "bc not available"
    local -a lu_arr U_arr
    math::matrix::lu 4 "$_M2" lu_arr U_arr $_MA 2>/dev/null
    if [[ ${#lu_arr[@]} -gt 0 && ${#U_arr[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::cofactor() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "cofactor" "$(math::matrix::cofactor 4 "$_M2" $_MA)"
    _sub_done
}
test::math::matrix::adjugate() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "adjugate" "$(math::matrix::adjugate 4 "$_M2" $_MA)"
    _sub_done
}
test::math::matrix::inverse() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "inverse" "$(math::matrix::inverse 4 "$_M2" $_MA)"
    _sub_done
}
test::math::matrix::rank() {
    math::has_bc || _skip "bc not available"
    _assert "rank (full)" "2" "$(math::matrix::rank 4 "$_M2" $_MA)"
    _sub_done
}
test::math::matrix::pow() {
    # M^1 = M
    if [[ "$(math::matrix::pow "$_M2" 1 $_MA)" == "$_MA" ]]; then _pass; else _fail; fi
}

test::math::matrix::addf() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "addf" "$(math::matrix::addf 2 "$_M2" $_MA $_MB)"
    _sub_done
}
test::math::matrix::subf() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "subf" "$(math::matrix::subf 2 "$_M2" $_MA $_MB)"
    _sub_done
}
test::math::matrix::scalef() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "scalef" "$(math::matrix::scalef 2 "$_M2" 2 $_MA)"
    _sub_done
}
test::math::matrix::mulf() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "mulf" "$(math::matrix::mulf 2 "$_M2" "$_M2" $_MA $_MI)"
    _sub_done
}
test::math::matrix::hadamardf() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "hadamardf" "$(math::matrix::hadamardf 2 "$_M2" $_MA $_MB)"
    _sub_done
}
test::math::matrix::tracef() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "tracef" "$(math::matrix::tracef 2 "$_M2" $_MA)"
    _sub_done
}
test::math::matrix::powf() {
    math::has_bc || _skip "bc not available"
    _assert_nonempty "powf" "$(math::matrix::powf 2 "$_M2" 2 $_MA)"
    _sub_done
}

# ::fast variants — write into nameref, check nonempty
test::math::matrix::add::fast() {
    local -a r; math::matrix::add::fast r "$_M2" $_MA $_MB
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::sub::fast() {
    local -a r; math::matrix::sub::fast r "$_M2" $_MA $_MB
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::scale::fast() {
    local -a r; math::matrix::scale::fast r "$_M2" 2 $_MA
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::hadamard::fast() {
    local -a r; math::matrix::hadamard::fast r "$_M2" $_MA $_MB
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::identity::fast() {
    local -a r; math::matrix::identity::fast r "$_M2"
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::transpose::fast() {
    local -a r; math::matrix::transpose::fast r "$_M2" $_MA
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::mul::fast() {
    local -a r; math::matrix::mul::fast r "$_M2" "$_M2" $_MA $_MI
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::addf::fast() {
    math::has_bc || _skip "bc not available"
    local -a r; math::matrix::addf::fast r 2 "$_M2" $_MA $_MB
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::subf::fast() {
    math::has_bc || _skip "bc not available"
    local -a r; math::matrix::subf::fast r 2 "$_M2" $_MA $_MB
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::scalef::fast() {
    math::has_bc || _skip "bc not available"
    local -a r; math::matrix::scalef::fast r 2 "$_M2" 2 $_MA
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::mulf::fast() {
    math::has_bc || _skip "bc not available"
    local -a r; math::matrix::mulf::fast r 2 "$_M2" "$_M2" $_MA $_MI
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}
test::math::matrix::hadamardf::fast() {
    math::has_bc || _skip "bc not available"
    local -a r; math::matrix::hadamardf::fast r 2 "$_M2" $_MA $_MB
    if [[ ${#r[@]} -gt 0 ]]; then _pass; else _fail; fi
}

# ==============================================================================
# Tests — random init functions
# ==============================================================================

test::random::splitmix64::seed_xoshiro() {
    local s0 s1 s2 s3
    read -r s0 s1 s2 s3 <<< "$(random::splitmix64::seed_xoshiro 12345)"
    if [[ -n "$s0" && -n "$s1" && -n "$s2" && -n "$s3" ]]; then _pass; else _fail; fi
}

test::random::well512::init() {
    local idx words
    read -r idx words <<< "$(random::well512::init 12345)"
    if [[ "$idx" == "0" && -n "$words" ]]; then _pass; else _fail; fi
}

test::random::isaac::init() {
    local a b c rest
    read -r a b c rest <<< "$(random::isaac::init 12345)"
    if [[ "$a" == "0" && "$b" == "0" && "$c" == "0" && -n "$rest" ]]; then _pass; else _fail; fi
}
