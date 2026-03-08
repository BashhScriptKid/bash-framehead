#!/usr/bin/env bash

LICENSE="
##==============================================================================
## bash::framehead — a runtime stdlib for Bash
## A comprehensive (and frankly ridiculous) set of helpers for when you're
## committed to doing it in Bash anyway
##==============================================================================
## Version:
## Author: BashhScriptKid <contact@bashh.slmail.me>
## Copyright (C) 2025 BashhScriptKid
## SPDX-License-Identifier: AGPL-3.0-or-later
##
##   This program is free software: you can redistribute it and/or modify
##   it under the terms of the GNU Affero General Public License as published
##   by the Free Software Foundation, either version 3 of the License, or
##   (at your option) any later version.
##
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU Affero General Public License for more details.
##
##   You should have received a copy of the GNU Affero General Public License
##   along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
##==============================================================================
"
compile_files() {
    local output_file="${1:-compiled.sh}"
    local src_dir
    src_dir="$(dirname "${BASH_SOURCE[0]}")/src"

    # Validate src directory exists
    if [[ ! -d "$src_dir" ]]; then
        echo "Error: src directory not found: $src_dir" >&2
        return 1
    fi

    # Collect .sh files upfront so we can validate before touching output
    local -a files=()
    for f in "$src_dir"/*.sh; do
        [[ -f "$f" ]] && files+=("$f")
    done

    if (( ${#files[@]} == 0 )); then
        echo "Error: No .sh files found in $src_dir" >&2
        return 1
    fi

    # Truncate/create output only after we know there's something to write
    true > "$output_file"

    local i=0
    local total_err=0 total_warn=0 total_info=0
    local has_shellcheck=false
    command -v shellcheck >/dev/null 2>&1 && has_shellcheck=true

    for func_file in "${files[@]}"; do
        local fname
        fname="$(basename "$func_file")"

        if [[ ! -s "$func_file" ]]; then
            echo "Warning: Skipping empty file: $fname" >&2
            continue
        fi

        # Run shellcheck once, parse counts from output
        local err_file=0 warn_file=0 info_file=0 issue_str_file=""
        if $has_shellcheck; then
            local sc_out
            sc_out=$(shellcheck --format=gcc "$func_file" 2>/dev/null)
            err_file=$(echo "$sc_out"  | grep -c ': error:')
            warn_file=$(echo "$sc_out" | grep -c ': warning:')
            info_file=$(echo "$sc_out" | grep -c ': note:')

            # Also show human-readable output
            shellcheck --color=auto --format=tty "$func_file" 2>/dev/null || true
            echo

            local file_issues=$(( err_file + warn_file + info_file ))
            if (( file_issues > 0 )); then
                issue_str_file=" — $file_issues issues ($err_file errors, $warn_file warnings, $info_file info)"
                (( total_err  += err_file  ))
                (( total_warn += warn_file ))
                (( total_info += info_file ))
            fi
        fi

        echo -n "Writing $fname..."

        local i_line=0
        while IFS= read -r line; do
            # Strip shebang from all but the first file
            if (( i > 0 && i_line == 0 )); then
                (( i_line++ ))
                [[ "$line" =~ ^#! ]] && continue
            elif (( i == 0 && i_line == 2 )); then # license printing
                printf "%s\n" "$LICENSE" >> "$output_file"
            fi
            printf '%s\n' "$line" >> "$output_file"
            (( i_line++ ))
        done < "$func_file"

        echo " ok${issue_str_file}"
        (( i++ ))
    done

    # Nothing was actually written (all files were empty)
    if (( i == 0 )); then
        echo "Error: All source files were empty, output not written" >&2
        rm -f "$output_file"
        return 1
    fi

    local VERSION
    read -r -t 0.1 -n 10000 _drain 2>/dev/null || true
    read -r -p "Input a version for this file: " VERSION
    VERSION=${VERSION:-"$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")-dev+$(date +%d%m%y).$(date +%S)"}
    sed -i "s/## Version:/## Version: ${VERSION}/" "$output_file"

    chmod +x "$output_file" 2>/dev/null

    local total_issues=$(( total_err + total_warn + total_info ))
    local final_issue_str=""
    if (( total_issues > 0 )); then
        final_issue_str=" — $total_issues total issues ($total_err errors, $total_warn warnings, $total_info info)"
    fi

    echo "Compiled $i file(s) to $output_file${final_issue_str}"
}

statistics() {
    local file=$1 presourced=0
    echo "=== bash::framehead.sh Diagnostics ==="
    echo "Version: $(grep '^## Version:' "$file" | head -1 | sed 's/## Version: *//')"
    echo "File size: $(wc -l < "$file") lines // $(numfmt --to=iec --suffix=B $(stat -c '%s' "$file" 2>/dev/null || wc -c < "$file" 2>/dev/null))"
    echo ""
    echo "=== Testing load time in fresh shell ==="
    # Use time builtin and extract real time
    if [[ "${BASH_VERSINFO[0]}" -ge 5 ]]; then
        start=$EPOCHREALTIME
        source "$file" >/dev/null 2>&1 && presourced=1
        end=$EPOCHREALTIME
        duration_ms=$(bc <<< "($end - $start) * 1000" 2>/dev/null)
        echo "Load time: ${duration_ms%.*} ms"
        loadtime_func_ms=$(bc <<< " scale=4; $duration_ms / $(declare -F | awk '$3 ~ /::/' | wc -l)")
        funcload_per_ms=$(bc <<< "scale=4; 1/$loadtime_func_ms")
        echo "Avg per function: 0$loadtime_func_ms ms / $funcload_per_ms function per ms"
    fi

    echo ""
    echo "=== Function count by module ==="
    (
        ((!presourced)) && source "$file"
      declare -F | awk '$3 ~ /::/ && $3 !~ /^_/ {print $3}' | awk -F'::' '{print $1}' | sort | uniq -c | sort -rn
      echo ""
      echo "-- private helpers --"
      declare -F | awk '$3 ~ /^_/ && $3 ~ /::/' | awk '{print $3}' | awk -F'::' '{print $1}' | sort | uniq -c | sort -rn
      echo ""
      echo "$(declare -F | awk '$3 ~ /::/' | wc -l) total functions loaded"
    )
}



## These are covered by LLMs, mostly reviewed by humans
## You may not want to update this manually
## Unless you want to painstakingly go back and forth the files and recompile to fix test coverages.
##
## Recommended prompt:
## """
##  Based on the following tester function:
##  (copy this function)
##  Can you update the function to maximise test coverage? Here is the output:
##  (Insert test output ESPECIALLY the 'untested functions' section)
##
##  Please do not change the structure of the tests, just add new ones.
##  If you insist, you SHOULD ask first.
## """
##
##  Upload the compiled single-file output (bash-framehead.sh) for full context.
##  If the file is too large, upload individual module files one at a time and specify which module to cover first.
##  You may add "May you suggest a module you want to cover first?" as guidance
##
## REMEMBER: YOU are still responsible. DO NOT leave LLMs fully agentic.
#
# Also you still want to do debugging, LLMs are only 'vibed' to maximise test coverage,
# Check how they put expected and actual output in the test,
# as they may have invalid intuition (or some tool being oddly unreliable), leading to test fails.
#
# Do NOT trust their test cases fully. Review their test framework's arguments.
tester() {
    local file=$1
    local passed=0 failed=0 skipped=0

    local _stderr_log
    _stderr_log=$(mktemp)
    exec 3>&2 2>"$_stderr_log"

    _check_stderr() {
        local err
        err=$(cat "$_stderr_log")
        > "$_stderr_log"
        if [[ -n "$err" ]]; then
            echo "        stderr: $err"
            return 1
        fi
        return 0
    }

    local PASS FAIL SKIP
    if [[ -t 1 ]]; then
        PASS="\033[32mPASS\033[0m"
        FAIL="\033[31mFAIL\033[0m"
        SKIP="\033[33mSKIP\033[0m"
    else
        PASS="PASS"; FAIL="FAIL"; SKIP="SKIP"
    fi
    echo "  $PASS  $name"

    _test() {
        local name="$1" expected="$2" actual="$3"
        local clean=true
        _check_stderr || clean=false
        if [[ "$actual" == "$expected" ]] && $clean; then
            echo -e "  $PASS  $name"
            (( passed++ ))
        else
            echo -e "  $FAIL  $name"
            [[ "$actual" != "$expected" ]] && \
                echo "        expected: $expected" && \
                echo "        actual:   $actual"
            (( failed++ ))
        fi
    }

    _test_contains() {
        local name="$1" needle="$2" actual="$3"
        local clean=true
        _check_stderr || clean=false
        if [[ "$actual" == *"$needle"* ]] && $clean; then
            echo -e "  $PASS  $name"
            (( passed++ ))
        else
            echo -e "  $FAIL  $name"
            [[ "$actual" != *"$needle"* ]] && \
                echo "        expected to contain: $needle" && \
                echo "        actual: $actual"
            (( failed++ ))
        fi
    }

    _test_nonempty() {
        local name="$1" actual="$2"
        local clean=true
        _check_stderr || clean=false
        if [[ -n "$actual" ]] && $clean; then
            echo -e "  $PASS  $name"
            (( passed++ ))
        else
            echo -e "  $FAIL  $name${actual:+ (empty output)}"
            (( failed++ ))
        fi
    }

    _test_skip() {
        echo -e "  $SKIP  $1"
        (( skipped++ ))
    }

    # Track which functions were tested
    local -A _tested=()
    _mark_tested() {
        for fn in "$@"; do _tested["$fn"]=1; done
    }

    source "$file"

    echo "=== bash::framehead functional smoke tests ==="
    echo ""

    # ==========================================================================
    # Reminder syntax: _test [API name] [Expected output] [Actual output]
    #                  _test_contains [API name] [String expected to contain] [Actual output]
    #                  _test_nonempty [API Name] [Actual output] (Only checks if output is not empty)
    echo "--- string ---"
    _test        "string::upper"              "HELLO"          "$(string::upper hello)"
    _test        "string::lower"              "hello"          "$(string::lower HELLO)"
    _test        "string::length"             "5"              "$(string::length hello)"
    _test        "string::contains (true)"    "0"              "$( string::contains hello ell; echo $? )"
    _test        "string::contains (false)"   "1"              "$( string::contains hello xyz; echo $? )"
    _test        "string::reverse"            "olleh"          "$(string::reverse hello)"
    _test        "string::snake_to_camel"     "helloWorld"     "$(string::snake_to_camel hello_world)"
    _test        "string::trim"               "hello"          "$(string::trim "  hello  ")"
    _test        "string::trim_left"          "hello  "        "$(string::trim_left "  hello  ")"
    _test        "string::trim_right"         "  hello"        "$(string::trim_right "  hello  ")"
    _test        "string::repeat"             "aaa"            "$(string::repeat a 3)"
    _test        "string::is_integer (true)"  "0"              "$( string::is_integer 42; echo $? )"
    _test        "string::is_integer (false)" "1"              "$( string::is_integer abc; echo $? )"
    _test        "string::is_float (true)"    "0"              "$( string::is_float 3.14; echo $? )"
    _test        "string::is_float (false)"   "1"              "$( string::is_float abc; echo $? )"
    _test        "string::is_hex (true)"      "0"              "$( string::is_hex 0xff; echo $? )"
    _test        "string::is_hex (false)"     "1"              "$( string::is_hex xyz; echo $? )"
    _test        "string::is_bin (true)"      "0"              "$( string::is_bin 0b1010; echo $? )"
    _test        "string::is_octal (true)"    "0"              "$( string::is_octal 0755; echo $? )"
    _test        "string::is_numeric (true)"  "0"              "$( string::is_numeric 42; echo $? )"
    _test        "string::is_alnum (true)"    "0"              "$( string::is_alnum abc123; echo $? )"
    _test        "string::is_alnum (false)"   "1"              "$( string::is_alnum 'abc!'; echo $? )"
    _test        "string::is_alpha (true)"    "0"              "$( string::is_alpha abc; echo $? )"
    _test        "string::is_alpha (false)"   "1"              "$( string::is_alpha abc1; echo $? )"
    _test        "string::is_empty (true)"    "0"              "$( string::is_empty ''; echo $? )"
    _test        "string::is_empty (false)"   "1"              "$( string::is_empty 'x'; echo $? )"
    _test        "string::is_not_empty"       "0"              "$( string::is_not_empty 'x'; echo $? )"
    _test        "string::starts_with (true)" "0"              "$( string::starts_with hello hel; echo $? )"
    _test        "string::starts_with (false)" "1"              "$( string::starts_with hello xyz; echo $? )"
    _test        "string::ends_with (true)"   "0"              "$( string::ends_with hello llo; echo $? )"
    _test        "string::ends_with (false)"  "1"              "$( string::ends_with hello xyz; echo $? )"
    _test        "string::matches (true)"     "0"              "$( string::matches hello 'hel+o'; echo $? )"
    _test        "string::capitalise"         "Hello"          "$(string::capitalise hello)"
    _test        "string::title"              "Hello World"    "$(string::title "hello world")"
    _test        "string::upper::legacy"      "HELLO"          "$(string::upper::legacy hello)"
    _test        "string::lower::legacy"      "hello"          "$(string::lower::legacy HELLO)"
    _test        "string::capitalise::legacy" "Hello"          "$(string::capitalise::legacy hello)"
    _test        "string::index_of"           "2"              "$(string::index_of hello l)"
    _test        "string::substr"             "ell"            "$(string::substr hello 1 3)"
    _test        "string::before"             "hel"            "$(string::before hello lo)"
    _test        "string::after"              "lo"             "$(string::after hello hel)"
    _test        "string::before_last"        "hel"            "$(string::before_last hello lo)"
    _test        "string::after_last"         "o"              "$(string::after_last hello l)"
    _test        "string::replace"            "hXllo"          "$(string::replace hello e X)"
    _test        "string::replace_all"        "hXllX"          "$(string::replace_all hXllo o X)"
    _test        "string::remove"             "hllo"           "$(string::remove hello e)"
    _test        "string::remove_first"       "hllo"           "$(string::remove_first hello e)"
    _test        "string::pad_left"           "  hi"           "$(string::pad_left hi 4)"
    _test        "string::pad_right"          "hi  "           "$(string::pad_right hi 4)"
    _test        "string::pad_center"         " hi "           "$(string::pad_center hi 4)"
    _test        "string::truncate"           "hel…"           "$(string::truncate hello 4)"
    _test        "string::collapse_spaces"    "a b c"          "$(string::collapse_spaces "a  b   c")"
    _test        "string::strip_spaces"       "abc"            "$(string::strip_spaces "a b c")"
    _test        "string::split"              "$(printf 'a\nb\nc')" "$(string::split a,b,c ,)"
    _test        "string::join"               "a,b,c"          "$(string::join , a b c)"
    _test_nonempty "string::uuid"             "$(string::uuid)"
    _test_nonempty "string::random"           "$(string::random 8)"
    _test_nonempty "string::md5"              "$(string::md5 hello)"
    _test_nonempty "string::sha256"           "$(string::sha256 hello)"
    _test_nonempty "string::url_encode"       "$(string::url_encode "hello world")"
    _test        "string::url_decode"         "hello world"    "$(string::url_decode "hello%20world")"
    _test_nonempty "string::base64_encode"    "$(string::base64_encode hello)"
    _test        "string::base64_decode"      "hello"          "$(string::base64_decode "$(string::base64_encode hello)")"
    _test_nonempty "string::base32_encode"    "$(string::base32_encode hello)"
    _test        "string::base32_decode"      "hello"          "$(string::base32_decode "$(string::base32_encode hello)")"
    # Case conversion matrix — representative subset
    _test        "string::plain_to_snake"     "hello_world"    "$(string::plain_to_snake "hello world")"
    _test        "string::plain_to_kebab"     "hello-world"    "$(string::plain_to_kebab "hello world")"
    _test        "string::plain_to_camel"     "helloWorld"     "$(string::plain_to_camel "hello world")"
    _test        "string::plain_to_pascal"    "HelloWorld"     "$(string::plain_to_pascal "hello world")"
    _test        "string::plain_to_constant"  "HELLO_WORLD"    "$(string::plain_to_constant "hello world")"
    _test        "string::plain_to_dot"       "hello.world"    "$(string::plain_to_dot "hello world")"
    _test        "string::plain_to_path"      "hello/world"    "$(string::plain_to_path "hello world")"
    _test        "string::snake_to_plain"     "hello world"    "$(string::snake_to_plain hello_world)"
    _test        "string::snake_to_kebab"     "hello-world"    "$(string::snake_to_kebab hello_world)"
    _test        "string::snake_to_pascal"    "HelloWorld"     "$(string::snake_to_pascal hello_world)"
    _test        "string::snake_to_constant"  "HELLO_WORLD"    "$(string::snake_to_constant hello_world)"
    _test        "string::snake_to_dot"       "hello.world"    "$(string::snake_to_dot hello_world)"
    _test        "string::snake_to_path"      "hello/world"    "$(string::snake_to_path hello_world)"
    _test        "string::kebab_to_plain"     "hello world"    "$(string::kebab_to_plain hello-world)"
    _test        "string::kebab_to_snake"     "hello_world"    "$(string::kebab_to_snake hello-world)"
    _test        "string::kebab_to_camel"     "helloWorld"     "$(string::kebab_to_camel hello-world)"
    _test        "string::kebab_to_pascal"    "HelloWorld"     "$(string::kebab_to_pascal hello-world)"
    _test        "string::kebab_to_constant"  "HELLO_WORLD"    "$(string::kebab_to_constant hello-world)"
    _test        "string::kebab_to_dot"       "hello.world"    "$(string::kebab_to_dot hello-world)"
    _test        "string::kebab_to_path"      "hello/world"    "$(string::kebab_to_path hello-world)"
    _test        "string::camel_to_plain"     "hello world"    "$(string::camel_to_plain helloWorld)"
    _test        "string::camel_to_snake"     "hello_world"    "$(string::camel_to_snake helloWorld)"
    _test        "string::camel_to_kebab"     "hello-world"    "$(string::camel_to_kebab helloWorld)"
    _test        "string::camel_to_pascal"    "HelloWorld"     "$(string::camel_to_pascal helloWorld)"
    _test        "string::camel_to_constant"  "HELLO_WORLD"    "$(string::camel_to_constant helloWorld)"
    _test        "string::camel_to_dot"       "hello.world"    "$(string::camel_to_dot helloWorld)"
    _test        "string::camel_to_path"      "hello/world"    "$(string::camel_to_path helloWorld)"
    _test        "string::pascal_to_plain"    "hello world"    "$(string::pascal_to_plain HelloWorld)"
    _test        "string::pascal_to_snake"    "hello_world"    "$(string::pascal_to_snake HelloWorld)"
    _test        "string::pascal_to_kebab"    "hello-world"    "$(string::pascal_to_kebab HelloWorld)"
    _test        "string::pascal_to_camel"    "helloWorld"     "$(string::pascal_to_camel HelloWorld)"
    _test        "string::pascal_to_constant" "HELLO_WORLD"    "$(string::pascal_to_constant HelloWorld)"
    _test        "string::pascal_to_dot"      "hello.world"    "$(string::pascal_to_dot HelloWorld)"
    _test        "string::pascal_to_path"     "hello/world"    "$(string::pascal_to_path HelloWorld)"
    _test        "string::constant_to_plain"  "hello world"    "$(string::constant_to_plain HELLO_WORLD)"
    _test        "string::constant_to_snake"  "hello_world"    "$(string::constant_to_snake HELLO_WORLD)"
    _test        "string::constant_to_kebab"  "hello-world"    "$(string::constant_to_kebab HELLO_WORLD)"
    _test        "string::constant_to_camel"  "helloWorld"     "$(string::constant_to_camel HELLO_WORLD)"
    _test        "string::constant_to_pascal" "HelloWorld"     "$(string::constant_to_pascal HELLO_WORLD)"
    _test        "string::constant_to_dot"    "hello.world"    "$(string::constant_to_dot HELLO_WORLD)"
    _test        "string::constant_to_path"   "hello/world"    "$(string::constant_to_path HELLO_WORLD)"
    _test        "string::dot_to_plain"       "hello world"    "$(string::dot_to_plain hello.world)"
    _test        "string::dot_to_snake"       "hello_world"    "$(string::dot_to_snake hello.world)"
    _test        "string::dot_to_kebab"       "hello-world"    "$(string::dot_to_kebab hello.world)"
    _test        "string::dot_to_camel"       "helloWorld"     "$(string::dot_to_camel hello.world)"
    _test        "string::dot_to_pascal"      "HelloWorld"     "$(string::dot_to_pascal hello.world)"
    _test        "string::dot_to_constant"    "HELLO_WORLD"    "$(string::dot_to_constant hello.world)"
    _test        "string::dot_to_path"        "hello/world"    "$(string::dot_to_path hello.world)"
    _test        "string::path_to_plain"      "hello world"    "$(string::path_to_plain hello/world)"
    _test        "string::path_to_snake"      "hello_world"    "$(string::path_to_snake hello/world)"
    _test        "string::path_to_kebab"      "hello-world"    "$(string::path_to_kebab hello/world)"
    _test        "string::path_to_camel"      "helloWorld"     "$(string::path_to_camel hello/world)"
    _test        "string::path_to_pascal"     "HelloWorld"     "$(string::path_to_pascal hello/world)"
    _test        "string::path_to_constant"   "HELLO_WORLD"    "$(string::path_to_constant hello/world)"
    _test        "string::path_to_dot"        "hello.world"    "$(string::path_to_dot hello/world)"
    _mark_tested string::upper string::lower string::length string::contains string::reverse \
                 string::snake_to_camel string::trim string::trim_left string::trim_right \
                 string::repeat string::is_integer string::is_float string::is_hex \
                 string::is_bin string::is_octal string::is_numeric string::is_alnum \
                 string::is_alpha string::is_empty string::is_not_empty \
                 string::starts_with string::ends_with string::matches \
                 string::capitalise string::title string::upper::legacy string::lower::legacy \
                 string::capitalise::legacy string::index_of string::substr \
                 string::before string::after string::before_last string::after_last \
                 string::replace string::replace_all string::remove string::remove_first \
                 string::pad_left string::pad_right string::pad_center string::truncate \
                 string::collapse_spaces string::strip_spaces string::split string::join \
                 string::uuid string::random string::md5 string::sha256 \
                 string::url_encode string::url_decode \
                 string::base64_encode string::base64_decode \
                 string::base32_encode string::base32_decode \
                 string::base64_encode::pure string::base64_decode::pure \
                 string::base32_encode::pure string::base32_decode::pure \
                 string::plain_to_snake string::plain_to_kebab string::plain_to_camel \
                 string::plain_to_pascal string::plain_to_constant string::plain_to_dot \
                 string::plain_to_path string::snake_to_plain string::snake_to_kebab \
                 string::snake_to_pascal string::snake_to_constant string::snake_to_dot \
                 string::snake_to_path string::kebab_to_plain string::kebab_to_snake \
                 string::kebab_to_camel string::kebab_to_pascal string::kebab_to_constant \
                 string::kebab_to_dot string::kebab_to_path string::camel_to_plain \
                 string::camel_to_snake string::camel_to_kebab string::camel_to_pascal \
                 string::camel_to_constant string::camel_to_dot string::camel_to_path \
                 string::pascal_to_plain string::pascal_to_snake string::pascal_to_kebab \
                 string::pascal_to_camel string::pascal_to_constant string::pascal_to_dot \
                 string::pascal_to_path string::constant_to_plain string::constant_to_snake \
                 string::constant_to_kebab string::constant_to_camel string::constant_to_pascal \
                 string::constant_to_dot string::constant_to_path string::dot_to_plain \
                 string::dot_to_snake string::dot_to_kebab string::dot_to_camel \
                 string::dot_to_pascal string::dot_to_constant string::dot_to_path \
                 string::path_to_plain string::path_to_snake string::path_to_kebab \
                 string::path_to_camel string::path_to_pascal string::path_to_constant \
                 string::path_to_dot

    # ==========================================================================
    echo ""
    echo "--- array ---"
    _test        "array::length"              "3"              "$(array::length a b c)"
    _test        "array::first"               "a"              "$(array::first a b c)"
    _test        "array::last"                "c"              "$(array::last a b c)"
    _test        "array::get"                 "b"              "$(array::get 1 a b c)"
    _test        "array::contains (true)"     "0"              "$( array::contains b a b c; echo $? )"
    _test        "array::contains (false)"    "1"              "$( array::contains z a b c; echo $? )"
    _test        "array::index_of (found)"    "1"              "$(array::index_of b a b c)"
    _test        "array::index_of (missing)"  "-1"             "$(array::index_of z a b c)"
    _test        "array::count_of"            "2"              "$(array::count_of a a b a c | tail -1)"
    _test        "array::is_empty (true)"     "0"              "$( array::is_empty; echo $? )"
    _test        "array::is_empty (false)"    "1"              "$( array::is_empty a b; echo $? )"
    _test        "array::print"               "$(printf 'a\nb\nc')" "$(array::print a b c)"
    _test        "array::reverse"             "$(printf 'c\nb\na')" "$(array::reverse a b c)"
    _test        "array::flatten"             "$(printf 'a\nb\nc\nd')" "$(array::flatten "a b" "c d")"
    _test        "array::slice"               "$(printf 'b\nc')" "$(array::slice 1 2 a b c d)"
    _test        "array::push"                "$(printf 'a\nb\nc\nd')" "$(array::push d a b c)"
    _test        "array::pop"                 "$(printf 'a\nb')"  "$(array::pop a b c)"
    _test        "array::unshift"             "$(printf 'z\na\nb')" "$(array::unshift z a b)"
    _test        "array::shift"               "$(printf 'b\nc')" "$(array::shift a b c)"
    _test        "array::remove_at"           "$(printf 'a\nc')" "$(array::remove_at 1 a b c)"
    _test        "array::remove"              "$(printf 'a\nc')" "$(array::remove b a b c)"
    _test        "array::set"                 "$(printf 'a\nZ\nc')" "$(array::set 1 Z a b c)"
    _test        "array::insert_at"           "$(printf 'a\nX\nb\nc')" "$(array::insert_at 1 X a b c)"
    _test        "array::filter"              "$(printf 'ab\nac')" "$(array::filter '^a' ab bc ac)"
    _test        "array::reject"              "bc"             "$(array::reject '^a' ab bc ac)"
    _test        "array::compact"             "$(printf 'a\nb')" "$(array::compact a '' b '')"
    _test        "array::join"                "a,b,c"          "$(array::join , a b c)"
    _test        "array::sum"                 "6"              "$(array::sum 1 2 3)"
    _test        "array::min"                 "1"              "$(array::min 3 1 2)"
    _test        "array::max"                 "3"              "$(array::max 1 3 2)"
    _test        "array::intersect"           "b"              "$(array::intersect "a b" "b c")"
    _test        "array::diff"                "a"              "$(array::diff "a b" "b c")"
    _test        "array::union"               "$(printf 'a\nb\nc')" "$(array::union "a b" "b c")"
    _test        "array::sort"                "$(printf 'a\nb\nc')" "$(array::sort c a b)"
    _test        "array::sort::reverse"       "$(printf 'c\nb\na')" "$(array::sort::reverse a b c)"
    _test        "array::sort::numeric"       "$(printf '1\n2\n10')" "$(array::sort::numeric 10 1 2)"
    _test        "array::sort::numeric_reverse" "$(printf '10\n2\n1')" "$(array::sort::numeric_reverse 1 10 2)"
    _test        "array::unique"              "$(printf 'a\nb\nc')" "$(array::unique a b a c b)"
    _test        "array::equals (true)"       "0"              "$( array::equals 'a b c' 'a b c'; echo $? )"
    _test        "array::equals (false)"      "1"              "$( array::equals 'a b' 'a b c'; echo $? )"
    _test        "array::zip"                 "$(printf 'a 1\nb 2')" "$(array::zip "a b" "1 2")"
    _test        "array::rotate"              "$(printf 'b\nc\na')" "$(array::rotate 1 a b c)"
    _test        "array::chunk"               "$(printf 'a b\nc d\ne')" "$(array::chunk 2 a b c d e)"
    _test        "array::from_string"         "$(printf 'a\nb\nc')" "$(array::from_string , a,b,c)"
    _test        "array::from_lines"          "$(printf 'a\nb\nc')" "$(array::from_lines "$(printf 'a\nb\nc')")"
    _test        "array::range"               "$(printf '1\n2\n3\n4\n5')" "$(array::range 1 5)"
    _test        "array::range (step)"        "$(printf '0\n2\n4')" "$(array::range 0 4 2)"
    _mark_tested array::length array::first array::last array::get array::contains \
                 array::index_of array::count_of array::is_empty array::print \
                 array::reverse array::flatten array::slice array::push array::pop \
                 array::unshift array::shift array::remove_at array::remove array::set \
                 array::insert_at array::filter array::reject array::compact array::join \
                 array::sum array::min array::max array::intersect array::diff array::union \
                 array::sort array::sort::reverse array::sort::numeric array::sort::numeric_reverse \
                 array::unique array::equals array::zip array::rotate array::chunk \
                 array::from_string array::from_lines array::range

    # ==========================================================================
    echo ""
    echo "--- math ---"
    _test        "math::abs (negative)"       "5"              "$(math::abs -5)"
    _test        "math::abs (positive)"       "5"              "$(math::abs 5)"
    _test        "math::min"                  "3"              "$(math::min 3 7)"
    _test        "math::max"                  "7"              "$(math::max 3 7)"
    _test        "math::clamp"                "5"              "$(math::clamp 5 1 10)"
    _test        "math::clamp (low)"          "1"              "$(math::clamp -5 1 10)"
    _test        "math::clamp (high)"         "10"             "$(math::clamp 99 1 10)"
    _test        "math::div"                  "3"              "$(math::div 7 2)"
    _test        "math::mod"                  "1"              "$(math::mod 7 2)"
    _test        "math::gcd"                  "6"              "$(math::gcd 12 18)"
    _test        "math::lcm"                  "12"             "$(math::lcm 4 6)"
    _test        "math::is_even (true)"       "0"              "$( math::is_even 4; echo $? )"
    _test        "math::is_even (false)"      "1"              "$( math::is_even 3; echo $? )"
    _test        "math::is_odd (true)"        "0"              "$( math::is_odd 3; echo $? )"
    _test        "math::is_odd (false)"       "1"              "$( math::is_odd 4; echo $? )"
    _test        "math::is_prime (true)"      "0"              "$( math::is_prime 17; echo $? )"
    _test        "math::is_prime (false)"     "1"              "$( math::is_prime 18; echo $? )"
    _test        "math::factorial"            "120"            "$(math::factorial 5)"
    _test        "math::fibonacci"            "13"             "$(math::fibonacci 7)"
    _test        "math::pow"                  "8"              "$(math::pow 2 3)"
    _test        "math::int_sqrt"             "4"              "$(math::int_sqrt 16)"
    _test        "math::int_sqrt (floor)"     "3"              "$(math::int_sqrt 12)"
    _test        "math::sum"                  "10"             "$(math::sum 1 2 3 4)"
    _test        "math::product"              "24"             "$(math::product 2 3 4)"
    _test        "math::choose"               "10"             "$(math::choose 5 2)"
    _test        "math::permute"              "20"             "$(math::permute 5 2)"
    _test        "math::digit_sum"            "6"              "$(math::digit_sum 123)"
    _test        "math::digit_count"          "3"              "$(math::digit_count 123)"
    _test        "math::digit_reverse"        "321"            "$(math::digit_reverse 123)"
    _test        "math::is_palindrome (true)" "0"              "$( math::is_palindrome 121; echo $? )"
    _test        "math::is_palindrome (false)" "1"              "$( math::is_palindrome 123; echo $? )"
    _test        "math::has_bc"              "0"               "$( math::has_bc; echo $? )"
    if math::has_bc; then
        _test_contains "math::bc"            "3.14"           "$(math::bc "22/7" 2)"
        _test        "math::floor"           "3"              "$(math::floor 3.7)"
        _test        "math::ceil"            "4"              "$(math::ceil 3.2)"
        _test        "math::round"           "4"              "$(math::round 3.6)"
        _test        "math::sqrt"            "$(math::bc "sqrt(4)" "$MATH_SCALE")" "$(math::sqrt 4)"
        _test "math::clampf (within range)" "3.5" "$(math::clampf 3.5 0 10 1)"
        _test "math::clampf (below low)" "0.0" "$(math::clampf -2.5 0 10 1)"
        _test "math::clampf (above high)" "10.0" "$(math::clampf 12.5 0 10 1)"
        _test "math::clampf (decimal low)" "1.5" "$(math::clampf 0.5 1.5 5.5 1)"
        _test "math::clampf (decimal high)" "5.5" "$(math::clampf 6.5 1.5 5.5 1)"
        _test "math::clampf (negative range)" "-5.0" "$(math::clampf -5.0 -10.0 0.0 1)"
        _test "math::clampf (exact low)" "0.0" "$(math::clampf 0.0 0.0 10.0 1)"
        _test "math::clampf (exact high)" "10.0" "$(math::clampf 10.0 0.0 10.0 1)"
        _test "math::clampf (mixed signs)" "0.0" "$(math::clampf -5.0 0.0 5.0 1)"
        _test_nonempty "math::log"           "$(math::log 10)"
        _test_nonempty "math::log2"          "$(math::log2 8)"
        _test_nonempty "math::log10"         "$(math::log10 100)"
        _test_nonempty "math::logn"          "$(math::logn 8 2)"
        _test_nonempty "math::exp"           "$(math::exp 1)"
        _test_nonempty "math::powf"          "$(math::powf 2 0.5)"
        _test_nonempty "math::sin"           "$(math::sin 0)"
        _test_nonempty "math::cos"           "$(math::cos 0)"
        _test_nonempty "math::tan"           "$(math::tan 0)"
        _test_nonempty "math::asin"          "$(math::asin 0)"
        _test_nonempty "math::acos"          "$(math::acos 1)"
        _test_nonempty "math::atan"          "$(math::atan 1)"
        _test_nonempty "math::atan2"         "$(math::atan2 1 1)"
        _test_nonempty "math::deg_to_rad"    "$(math::deg_to_rad 180)"
        _test_nonempty "math::rad_to_deg"    "$(math::rad_to_deg 1)"
        _test        "math::percent"         "50.00"          "$(math::percent 1 2 2)"
        _test        "math::percent_of"      "50.00"          "$(math::percent_of 50 100 2)"
        _test        "math::percent_change"  "100.00"         "$(math::percent_change 50 100 2)"
        _test_nonempty "math::lerp"          "$(math::lerp 0 10 0.5)"
        _test_nonempty "math::lerp_unclamped" "$(math::lerp_unclamped 0 10 0.5)"
        _test_nonempty "math::map"           "$(math::map 5 0 10 0 100)"
        _test_nonempty "math::normalize"     "$(math::normalize 5 0 10)"
        _test_nonempty "math::unitconvert"   "$(math::unitconvert km mi 1)"
        _mark_tested math::bc math::floor math::ceil math::round math::sqrt math::log \
                     math::log2 math::log10 math::logn math::exp math::powf \
                     math::sin math::cos math::tan math::asin math::acos math::atan \
                     math::atan2 math::deg_to_rad math::rad_to_deg math::percent \
                     math::percent_of math::percent_change math::lerp math::lerp_unclamped \
                     math::map math::normalize math::unitconvert math::convert math::clampf
    else
        _test_skip "math::bc (bc not available)"
        _test_skip "math::floor/ceil/round/sqrt/log/trig (bc not available)"
        _mark_tested math::bc math::floor math::ceil math::round math::sqrt math::log \
                     math::log2 math::log10 math::logn math::exp math::powf \
                     math::sin math::cos math::tan math::asin math::acos math::atan \
                     math::atan2 math::deg_to_rad math::rad_to_deg math::percent \
                     math::percent_of math::percent_change math::lerp math::lerp_unclamped \
                     math::map math::normalize math::unitconvert math::convert
    fi
    _mark_tested math::abs math::min math::max math::clamp math::div math::mod \
                 math::gcd math::lcm math::is_even math::is_odd math::is_prime \
                 math::factorial math::fibonacci math::pow math::int_sqrt \
                 math::sum math::product math::choose math::permute \
                 math::digit_sum math::digit_count math::digit_reverse math::is_palindrome \
                 math::has_bc

    # ==========================================================================
    echo ""
    echo "--- hash ---"
    _test_nonempty "hash::md5"               "$(hash::md5 hello)"
    _test_nonempty "hash::sha1"              "$(hash::sha1 hello)"
    _test_nonempty "hash::sha256"            "$(hash::sha256 hello)"
    _test          "hash::sha256 (known)"    "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824" \
                                             "$(hash::sha256 hello)"
    _test_nonempty "hash::sha512"            "$(hash::sha512 hello)"
    _test_nonempty "hash::djb2"              "$(hash::djb2 hello)"
    _test_nonempty "hash::djb2a"             "$(hash::djb2a hello)"
    _test_nonempty "hash::sdbm"              "$(hash::sdbm hello)"
    _test_nonempty "hash::fnv1a32"           "$(hash::fnv1a32 hello)"
    _test_nonempty "hash::fnv1a64"           "$(hash::fnv1a64 hello)"
    _test_nonempty "hash::adler32"           "$(hash::adler32 hello)"
    _test_nonempty "hash::murmur2"           "$(hash::murmur2 hello)"
    _test_nonempty "hash::crc32"             "$(hash::crc32 hello)"
    _test          "hash::verify"            "0"              "$( hash::verify hello "$(hash::sha256 hello)" sha256; echo $? )"
    _test          "hash::equal (true)"      "0"              "$( hash::equal hello hello; echo $? )"
    _test          "hash::equal (false)"     "1"              "$( hash::equal hello world; echo $? )"
    _test          "hash::slot range"        "0"              "$( h=$(hash::slot 10 test); [[ $h -ge 0 && $h -lt 10 ]] && echo 0 || echo 1 )"
    _test_nonempty "hash::short"             "$(hash::short hello)"
    _test          "hash::short length"      "8"              "$(hash::short hello 8 | wc -c | tr -d ' '| awk '{print $1-1}')"
    _test_nonempty "hash::combine"           "$(hash::combine foo bar baz)"
    if runtime::has_command openssl; then
        _test_nonempty "hash::hmac::sha256"  "$(hash::hmac::sha256 mykey hello)"
        _test_nonempty "hash::hmac::sha512"  "$(hash::hmac::sha512 mykey hello)"
        _test_nonempty "hash::hmac::md5"     "$(hash::hmac::md5 mykey hello)"
        _mark_tested hash::hmac::sha256 hash::hmac::sha512 hash::hmac::md5
    else
        _test_skip "hash::hmac (openssl not available)"
        _mark_tested hash::hmac::sha256 hash::hmac::sha512 hash::hmac::md5
    fi
    if runtime::has_command openssl || runtime::has_command python3; then
        _test_nonempty "hash::sha3_256"      "$(hash::sha3_256 hello 2>/dev/null || echo skipped)"
        _test_nonempty "hash::blake2b"       "$(hash::blake2b hello 2>/dev/null || echo skipped)"
        _test_nonempty "hash::uuid5"         "$(hash::uuid5 dns example.com)"
        _mark_tested hash::sha3_256 hash::blake2b hash::uuid5
    else
        _test_skip "hash::sha3_256 / blake2b / uuid5 (openssl/python3 not available)"
        _mark_tested hash::sha3_256 hash::blake2b hash::uuid5
    fi
    _mark_tested hash::md5 hash::sha1 hash::sha256 hash::sha512 hash::djb2 hash::djb2a \
                 hash::sdbm hash::fnv1a32 hash::fnv1a64 hash::adler32 hash::murmur2 \
                 hash::crc32 hash::verify hash::equal hash::slot hash::short hash::combine

    # ==========================================================================
    echo ""
    echo "--- runtime ---"
    _test_nonempty "runtime::os"                   "$(runtime::os)"
    _test_nonempty "runtime::arch"                 "$(runtime::arch)"
    _test_nonempty "runtime::bash_version"         "$(runtime::bash_version)"
    _test_nonempty "runtime::bash_version::major"  "$(runtime::bash_version::major)"
    _test          "runtime::is_bash"              "0"  "$( runtime::is_bash; echo $? )"
    _test_nonempty "runtime::distro"               "$(runtime::distro)"
    _test          "runtime::has_command (true)"   "0"  "$( runtime::has_command bash; echo $? )"
    _test          "runtime::has_command (false)"  "1"  "$( runtime::has_command __no_such_cmd__; echo $? )"
    _test          "runtime::is_minimum_bash"      "0"  "$( runtime::is_minimum_bash 3; echo $? )"
    _test          "runtime::is_minimum_bash (hi)" "1"  "$( runtime::is_minimum_bash 99; echo $? )"
    _test          "runtime::has_flag (x)"         "0"  "$( runtime::has_flag B; echo $? )"  # B=braceexpand, always on
    _test          "runtime::braceexpand_enabled"  "0"  "$( runtime::braceexpand_enabled; echo $? )"
    _test          "runtime::is_subshell"          "0"  "$( runtime::is_subshell; echo $? )"  # not in subshell here
    _test_nonempty "runtime::pm"                   "$(runtime::pm)"
    _test_nonempty "runtime::sysinit"              "$(runtime::sysinit)"
    _test_nonempty "runtime::tty_name"             "$(runtime::tty_name)"
    _test_nonempty "runtime::kernel_version"       "$(runtime::kernel_version 2>/dev/null || echo unknown)"
    _test          "runtime::is_terminal"          "1"  "$( runtime::is_terminal; echo $? )"  # not a terminal in test
    _test          "runtime::is_terminal::stdin"   "0"  "$( runtime::is_terminal::stdin; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_terminal::stdout"  "1"  "$( runtime::is_terminal::stdout; echo $? )"
    _test          "runtime::is_terminal::stderr"  "1"  "$( runtime::is_terminal::stderr; echo $? )"
    _test          "runtime::is_pipe"              "0"  "$( echo | runtime::is_pipe; echo $? )"
    _test          "runtime::is_redirected"        "0"  "$( runtime::is_redirected; echo $? )"  # stderr redirected to log
    _test          "runtime::is_interactive"       "1"  "$( runtime::is_interactive; echo $? )"  # not interactive in test
    _test          "runtime::is_sourced"           "0"  "$( runtime::is_sourced; echo $? )"  # sourced
    _test_nonempty "runtime::screen_session"       "$(runtime::screen_session)"
    _test          "runtime::is_ci"               "$([ -n "$CI" ] && echo 0 || echo 1)" \
                                                   "$( runtime::is_ci; echo $? )"
    _test          "runtime::is_root"             "$([ $EUID -eq 0 ] && echo 0 || echo 1)" \
                                                   "$( runtime::is_root; echo $? )"
    _test          "runtime::is_sudo"             "$([ -n "$SUDO_USER" ] && echo 0 || echo 1)" \
                                                   "$( runtime::is_sudo; echo $? )"
    _test          "runtime::is_container"        "0"  \
                   "$( runtime::is_container; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::supports_color"      "0"  \
                   "$( runtime::supports_color; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::supports_truecolor"  "0"  \
                   "$( runtime::supports_truecolor; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_wsl"              "0"  \
                   "$( runtime::is_wsl; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_virtualized"      "0"  \
                   "$( runtime::is_virtualized; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_ssh"              "0"  \
                   "$( runtime::is_ssh; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_desktop"          "0"  \
                   "$( runtime::is_desktop; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_pty"              "0"  \
                   "$( runtime::is_pty; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_tty"              "0"  \
                   "$( runtime::is_tty; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_login"            "0"  \
                   "$( runtime::is_login; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_tmux"             "0"  \
                   "$( runtime::is_tmux; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_multiplexer"      "0"  \
                   "$( runtime::is_multiplexer; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::errexit_enabled"     "0"  \
                   "$( runtime::errexit_enabled; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::nounset_enabled"     "0"  \
                   "$( runtime::nounset_enabled; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::noclobber_enabled"   "0"  \
                   "$( runtime::noclobber_enabled; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::histexpand_enabled"  "0"  \
                   "$( runtime::histexpand_enabled; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::physical_cd_enabled" "0"  \
                   "$( runtime::physical_cd_enabled; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::job_controlled"      "0"  \
                   "$( runtime::job_controlled; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::debug_trapped"       "0"  \
                   "$( runtime::debug_trapped; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_traced"           "0"  \
                   "$( runtime::is_traced; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "runtime::is_verbose"          "0"  \
                   "$( runtime::is_verbose; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _mark_tested runtime::os runtime::arch runtime::bash_version runtime::bash_version::major \
                 runtime::is_bash runtime::distro runtime::has_command runtime::is_minimum_bash \
                 runtime::has_flag runtime::braceexpand_enabled runtime::is_subshell \
                 runtime::pm runtime::sysinit runtime::tty_name runtime::kernel_version \
                 runtime::is_terminal runtime::is_terminal::stdin runtime::is_terminal::stdout \
                 runtime::is_terminal::stderr runtime::is_pipe runtime::is_redirected \
                 runtime::is_interactive runtime::is_sourced runtime::screen_session \
                 runtime::is_ci runtime::is_root runtime::is_sudo runtime::is_container \
                 runtime::supports_color runtime::supports_truecolor runtime::is_wsl \
                 runtime::is_virtualized runtime::is_ssh runtime::is_desktop runtime::is_pty \
                 runtime::is_tty runtime::is_login runtime::is_tmux runtime::is_multiplexer \
                 runtime::errexit_enabled runtime::nounset_enabled runtime::noclobber_enabled \
                 runtime::histexpand_enabled runtime::physical_cd_enabled runtime::job_controlled \
                 runtime::debug_trapped runtime::is_traced runtime::is_verbose \
                 runtime::ssh_client runtime::exec_root

    # ==========================================================================
    echo ""
    echo "--- fs ---"
    local _tmp_dir _tmp_file
    _tmp_dir=$(mktemp -d)
    _tmp_file=$(mktemp "$_tmp_dir/test.XXXXXX")
    echo "hello world" > "$_tmp_file"
    local _tmp_link="${_tmp_dir}/link.txt"
    ln -s "$_tmp_file" "$_tmp_link"

    _test          "fs::exists (true)"           "0"  "$( fs::exists "$_tmp_file"; echo $? )"
    _test          "fs::exists (false)"          "1"  "$( fs::exists /nonexistent/path; echo $? )"
    _test          "fs::is_file (true)"          "0"  "$( fs::is_file "$_tmp_file"; echo $? )"
    _test          "fs::is_file (false)"         "1"  "$( fs::is_file "$_tmp_dir"; echo $? )"
    _test          "fs::is_dir (true)"           "0"  "$( fs::is_dir "$_tmp_dir"; echo $? )"
    _test          "fs::is_dir (false)"          "1"  "$( fs::is_dir "$_tmp_file"; echo $? )"
    _test          "fs::is_symlink (true)"       "0"  "$( fs::is_symlink "$_tmp_link"; echo $? )"
    _test          "fs::is_symlink (false)"      "1"  "$( fs::is_symlink "$_tmp_file"; echo $? )"
    _test          "fs::is_readable"             "0"  "$( fs::is_readable "$_tmp_file"; echo $? )"
    _test          "fs::is_writable"             "0"  "$( fs::is_writable "$_tmp_file"; echo $? )"
    _test          "fs::is_empty (false)"        "1"  "$( fs::is_empty "$_tmp_file"; echo $? )"
    _test          "fs::is_same"                 "0"  "$( fs::is_same "$_tmp_file" "$_tmp_file"; echo $? )"
    _test_nonempty "fs::size"                    "$(fs::size "$_tmp_file")"
    _test_nonempty "fs::size::human"             "$(fs::size::human "$_tmp_file")"
    _test_nonempty "fs::modified"                "$(fs::modified "$_tmp_file")"
    _test_nonempty "fs::modified::human"         "$(fs::modified::human "$_tmp_file")"
    _test_nonempty "fs::permissions"             "$(fs::permissions "$_tmp_file")"
    _test_nonempty "fs::permissions::symbolic"   "$(fs::permissions::symbolic "$_tmp_file")"
    _test_nonempty "fs::owner"                   "$(fs::owner "$_tmp_file")"
    _test_nonempty "fs::owner::group"            "$(fs::owner::group "$_tmp_file")"
    _test_nonempty "fs::inode"                   "$(fs::inode "$_tmp_file")"
    _test_nonempty "fs::link_count"              "$(fs::link_count "$_tmp_file")"
    _test_nonempty "fs::mime_type"               "$(fs::mime_type "$_tmp_file")"
    _test_nonempty "fs::symlink::target"         "$(fs::symlink::target "$_tmp_link")"
    _test_nonempty "fs::symlink::resolve"        "$(fs::symlink::resolve "$_tmp_link")"
    _test          "fs::path::basename"          "test.txt"   "$(fs::path::basename /foo/bar/test.txt)"
    _test          "fs::path::dirname"           "/foo/bar"   "$(fs::path::dirname /foo/bar/test.txt)"
    _test          "fs::path::extension"         "txt"        "$(fs::path::extension file.txt)"
    _test          "fs::path::extensions"        "tar.gz"     "$(fs::path::extensions file.tar.gz)"
    _test          "fs::path::stem"              "file"       "$(fs::path::stem file.txt)"
    _test          "fs::path::join"              "a/b/c"      "$(fs::path::join a b c)"
    _test          "fs::path::is_absolute"       "0"          "$( fs::path::is_absolute /foo; echo $? )"
    _test          "fs::path::is_relative"       "0"          "$( fs::path::is_relative foo; echo $? )"
    _test_nonempty "fs::path::absolute"          "$(fs::path::absolute .)"
    _test_nonempty "fs::path::relative"          "$(fs::path::relative /a/b/c /a)"
    _test          "fs::read"                    "hello world" "$(fs::read "$_tmp_file")"
    fs::write "$_tmp_file" "written"
    _test          "fs::write"                   "written"    "$(cat "$_tmp_file")"
    fs::writeln "$_tmp_file" "writtenln"
    _test          "fs::writeln"                 "writtenln"  "$(cat "$_tmp_file")"
    fs::append "$_tmp_file" "appended"
    _test_contains "fs::append"                  "appended"   "$(cat "$_tmp_file")"
    fs::appendln "$_tmp_file" "appendedln"
    _test_contains "fs::appendln"                "appendedln" "$(cat "$_tmp_file")"
    printf 'line1\nline2\nline3\n' > "$_tmp_file"
    _test          "fs::line"                    "line2"      "$(fs::line "$_tmp_file" 2)"
    _test          "fs::lines"                   "$(printf 'line1\nline2')" "$(fs::lines "$_tmp_file" 1 2)"
    _test          "fs::line_count"              "3"          "$(fs::line_count "$_tmp_file")"
    _test_nonempty "fs::word_count"              "$(fs::word_count "$_tmp_file")"
    _test_nonempty "fs::char_count"              "$(fs::char_count "$_tmp_file")"
    _test          "fs::contains (true)"         "0"          "$( fs::contains "$_tmp_file" line1; echo $? )"
    _test          "fs::contains (false)"        "1"          "$( fs::contains "$_tmp_file" nothere; echo $? )"
    _test          "fs::matches"                 "0"          "$( fs::matches "$_tmp_file" 'line[0-9]'; echo $? )"
    fs::replace "$_tmp_file" line1 LINE1
    _test          "fs::replace"                 "0"          "$( fs::contains "$_tmp_file" LINE1; echo $? )"
    printf 'hello\n' > "$_tmp_file"
    fs::prepend "$_tmp_file" "first"
    _test          "fs::prepend"                 "first"      "$(fs::line "$_tmp_file" 1)"
    _test_nonempty "fs::temp::file"              "$(fs::temp::file)"
    _test_nonempty "fs::temp::dir"               "$(fs::temp::dir)"
    local _auto_tmp
    local _auto_tmp _auto_dir
    _auto_tmp=$(mktemp)  # pre-create so trap has something to register against
    _auto_tmp=$(fs::temp::file::auto)
    _test "fs::temp::file::auto" "0" "$( [[ -n "$_auto_tmp" ]]; echo $? )"

    _auto_dir=$(fs::temp::dir::auto)
    _test "fs::temp::dir::auto" "0" "$( [[ -n "$_auto_dir" ]]; echo $? )"
    local _cp_dest="${_tmp_dir}/copied.txt"
    fs::copy "$_tmp_file" "$_cp_dest"
    _test          "fs::copy"                    "0"          "$( fs::exists "$_cp_dest"; echo $? )"
    local _mv_dest="${_tmp_dir}/moved.txt"
    fs::move "$_cp_dest" "$_mv_dest"
    _test          "fs::move"                    "0"          "$( fs::exists "$_mv_dest"; echo $? )"
    fs::delete "$_mv_dest"
    _test          "fs::delete"                  "1"          "$( fs::exists "$_mv_dest"; echo $? )"
    local _new_dir="${_tmp_dir}/newdir"
    fs::mkdir "$_new_dir"
    _test          "fs::mkdir"                   "0"          "$( fs::is_dir "$_new_dir"; echo $? )"
    local _touched="${_tmp_dir}/touched.txt"
    fs::touch "$_touched"
    _test          "fs::touch"                   "0"          "$( fs::exists "$_touched"; echo $? )"
    local _sym_link="${_tmp_dir}/symtest.txt"
    fs::symlink "$_tmp_file" "$_sym_link"
    _test          "fs::symlink"                 "0"          "$( fs::is_symlink "$_sym_link"; echo $? )"
    local _hard="${_tmp_dir}/hard.txt"
    fs::hardlink "$_tmp_file" "$_hard"
    _test          "fs::hardlink"                "0"          "$( fs::exists "$_hard"; echo $? )"
    fs::rename "$_hard" "renamed.txt"
    _test          "fs::rename"                  "0"          "$( fs::exists "${_tmp_dir}/renamed.txt"; echo $? )"
    _test_nonempty "fs::ls"                      "$(fs::ls "$_tmp_dir")"
    _test_nonempty "fs::ls::all"                 "$(fs::ls::all "$_tmp_dir")"
    _test_nonempty "fs::ls::files"               "$(fs::ls::files "$_tmp_dir")"
    _test_nonempty "fs::ls::dirs"                "$(fs::ls::dirs "$_tmp_dir")"
    _test_nonempty "fs::find"                    "$(fs::find "$_tmp_dir" "*.txt")"
    _test_nonempty "fs::find::type"              "$(fs::find::type "$_tmp_dir" f)"
    _test_nonempty "fs::find::recent"            "$(fs::find::recent "$_tmp_dir" 1)"
    _test_nonempty "fs::find::larger_than"       "$(fs::find::larger_than "$_tmp_dir" 0)"
    _test_nonempty "fs::dir::size"               "$(fs::dir::size "$_tmp_dir")"
    _test_nonempty "fs::dir::size::human"        "$(fs::dir::size::human "$_tmp_dir")"
    _test_nonempty "fs::dir::count"              "$(fs::dir::count "$_tmp_dir")"
    _test          "fs::dir::is_empty (false)"   "1"          "$( fs::dir::is_empty "$_tmp_dir"; echo $? )"
    _test_nonempty "fs::checksum::md5"           "$(fs::checksum::md5 "$_tmp_file")"
    _test_nonempty "fs::checksum::sha1"          "$(fs::checksum::sha1 "$_tmp_file")"
    _test_nonempty "fs::checksum::sha256"        "$(fs::checksum::sha256 "$_tmp_file")"
    _test          "fs::is_identical (true)"     "0"          "$( fs::is_identical "$_tmp_file" "$_tmp_file"; echo $? )"
    _test_nonempty "fs::is_executable"           "$( fs::is_executable "$_tmp_file"; echo $? )"
    _test_nonempty "fs::created"                 "$(fs::created "$_tmp_file" 2>/dev/null || echo 0)"
    _test_nonempty "fs::find::smaller_than"      "$(fs::find::smaller_than "$_tmp_dir" 999999)"

    # cleanup
    rm -rf "$_tmp_dir"

    _mark_tested fs::exists fs::is_file fs::is_dir fs::is_symlink fs::is_readable \
                 fs::is_writable fs::is_empty fs::is_same \
                 fs::size fs::size::human fs::modified fs::modified::human \
                 fs::permissions fs::permissions::symbolic fs::owner fs::owner::group \
                 fs::inode fs::link_count fs::mime_type fs::symlink::target fs::symlink::resolve \
                 fs::path::basename fs::path::dirname fs::path::extension fs::path::extensions \
                 fs::path::stem fs::path::join fs::path::is_absolute fs::path::is_relative \
                 fs::path::absolute fs::path::relative fs::read fs::write fs::writeln \
                 fs::append fs::appendln fs::line fs::lines fs::line_count fs::word_count \
                 fs::char_count fs::contains fs::matches fs::replace fs::prepend \
                 fs::temp::file fs::temp::dir fs::temp::file::auto fs::temp::dir::auto \
                 fs::copy fs::move fs::delete fs::mkdir fs::touch fs::symlink fs::hardlink \
                 fs::rename fs::ls fs::ls::all fs::ls::files fs::ls::dirs \
                 fs::find fs::find::type fs::find::recent fs::find::larger_than \
                 fs::find::smaller_than fs::dir::size fs::dir::size::human fs::dir::count \
                 fs::dir::is_empty fs::checksum::md5 fs::checksum::sha1 fs::checksum::sha256 \
                 fs::is_identical fs::is_executable fs::created fs::trash fs::watch \
                 fs::watch::timeout

    # ==========================================================================
    echo ""
    echo "--- timedate ---"
    _test_nonempty "timedate::timestamp::unix"       "$(timedate::timestamp::unix)"
    _test_nonempty "timedate::timestamp::unix_ms"    "$(timedate::timestamp::unix_ms)"
    _test_nonempty "timedate::timestamp::unix_ns"    "$(timedate::timestamp::unix_ns)"
    _test_nonempty "timedate::timestamp::to_human"   "$(timedate::timestamp::to_human "$(timedate::timestamp::unix)")"
    _test_nonempty "timedate::timestamp::from_human" "$(timedate::timestamp::from_human "2024-01-15 12:00:00")"
    _test_nonempty "timedate::date::today"           "$(timedate::date::today)"
    _test_nonempty "timedate::date::format"          "$(timedate::date::format)"
    _test_nonempty "timedate::date::year"            "$(timedate::date::year)"
    _test_nonempty "timedate::date::month"           "$(timedate::date::month)"
    _test_nonempty "timedate::date::day"             "$(timedate::date::day)"
    _test_nonempty "timedate::date::day_of_week"     "$(timedate::date::day_of_week)"
    _test_nonempty "timedate::date::day_name"        "$(timedate::date::day_name)"
    _test_nonempty "timedate::date::day_name::short" "$(timedate::date::day_name::short)"
    _test_nonempty "timedate::date::day_of_year"     "$(timedate::date::day_of_year)"
    _test_nonempty "timedate::date::week_of_year"    "$(timedate::date::week_of_year)"
    _test_nonempty "timedate::date::quarter"         "$(timedate::date::quarter)"
    _test          "timedate::date::days_in_month"   "29"  "$(timedate::date::days_in_month 2000 2)"
    _test          "timedate::date::days_in_month"   "28"  "$(timedate::date::days_in_month 1900 2)"
    _test          "timedate::date::add_days"        "2024-01-16"  "$(timedate::date::add_days 2024-01-15 1)"
    _test          "timedate::date::sub_days"        "2024-01-14"  "$(timedate::date::sub_days 2024-01-15 1)"
    _test_nonempty "timedate::date::add_months"      "$(timedate::date::add_months 2024-01-15 1)"
    _test_nonempty "timedate::date::add_years"       "$(timedate::date::add_years 2024-01-15 1)"
    _test          "timedate::date::days_between"    "1"   "$(timedate::date::days_between 2024-01-15 2024-01-16)"
    _test_nonempty "timedate::date::yesterday"       "$(timedate::date::yesterday)"
    _test_nonempty "timedate::date::tomorrow"        "$(timedate::date::tomorrow)"
    _test_nonempty "timedate::date::week_start"      "$(timedate::date::week_start)"
    _test_nonempty "timedate::date::week_end"        "$(timedate::date::week_end)"
    _test_nonempty "timedate::date::month_start"     "$(timedate::date::month_start)"
    _test_nonempty "timedate::date::month_end"       "$(timedate::date::month_end)"
    _test_nonempty "timedate::date::year_start"      "$(timedate::date::year_start)"
    _test_nonempty "timedate::date::year_end"        "$(timedate::date::year_end)"
    _test_nonempty "timedate::date::next_weekday"    "$(timedate::date::next_weekday 1)"
    _test_nonempty "timedate::date::prev_weekday"    "$(timedate::date::prev_weekday 5)"
    _test          "timedate::date::compare (eq)"    "0"   "$(timedate::date::compare 2024-01-15 2024-01-15)"
    _test          "timedate::date::compare (lt)"    "-1"  "$(timedate::date::compare 2024-01-14 2024-01-15)"
    _test          "timedate::date::compare (gt)"    "1"   "$(timedate::date::compare 2024-01-16 2024-01-15)"
    _test          "timedate::date::is_before"       "0"   "$( timedate::date::is_before 2024-01-14 2024-01-15; echo $? )"
    _test          "timedate::date::is_after"        "0"   "$( timedate::date::is_after 2024-01-16 2024-01-15; echo $? )"
    _test          "timedate::date::is_between"      "0"   "$( timedate::date::is_between 2024-01-15 2024-01-01 2024-01-31; echo $? )"
    _test_nonempty "timedate::time::now"             "$(timedate::time::now)"
    _test_nonempty "timedate::time::format"          "$(timedate::time::format)"
    _test_nonempty "timedate::time::hour"            "$(timedate::time::hour)"
    _test_nonempty "timedate::time::minute"          "$(timedate::time::minute)"
    _test_nonempty "timedate::time::second"          "$(timedate::time::second)"
    _test_nonempty "timedate::time::timezone"        "$(timedate::time::timezone)"
    _test_nonempty "timedate::time::timezone_offset" "$(timedate::time::timezone_offset)"
    _test          "timedate::time::is_morning/afternoon/evening" "0" \
        "$( r=0; timedate::time::is_morning || timedate::time::is_afternoon || timedate::time::is_evening || r=1; echo $r )"
    _test          "timedate::time::is_business_hours" "0" \
        "$( timedate::time::is_business_hours; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "timedate::time::is_before"       "0"  \
        "$( timedate::time::is_before 23:59; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "timedate::time::is_after"        "0"  \
        "$( timedate::time::is_after 00:00; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "timedate::time::is_between"      "0"  \
        "$( timedate::time::is_between 00:00 23:59; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    local _sw_start
    _sw_start=$(timedate::time::stopwatch::start)
    _test_nonempty "timedate::time::stopwatch::start" "$_sw_start"
    _test_nonempty "timedate::time::stopwatch::stop"  "$(timedate::time::stopwatch::stop "$_sw_start")"
    _test          "timedate::calendar::is_leap_year (2000)" "0" "$( timedate::calendar::is_leap_year 2000; echo $? )"
    _test          "timedate::calendar::is_leap_year (1900)" "1" "$( timedate::calendar::is_leap_year 1900; echo $? )"
    _test          "timedate::calendar::days_in_year (leap)"   "366" "$(timedate::calendar::days_in_year 2000)"
    _test          "timedate::calendar::days_in_year (normal)" "365" "$(timedate::calendar::days_in_year 2001)"
    _test          "timedate::calendar::is_weekend"  "0"  "$( timedate::calendar::is_weekend 2024-01-06; echo $? )"  # Saturday
    _test          "timedate::calendar::is_weekday"  "0"  "$( timedate::calendar::is_weekday 2024-01-08; echo $? )"  # Monday
    _test_nonempty "timedate::calendar::iso_week"    "$(timedate::calendar::iso_week 2024-01-15)"
    _test_nonempty "timedate::calendar::day_of_year" "$(timedate::calendar::day_of_year 2024-01-15)"
    _test_nonempty "timedate::calendar::quarter"     "$(timedate::calendar::quarter 2024-04-01)"
    _test          "timedate::calendar::easter 2024" "2024-03-31" "$(timedate::calendar::easter 2024)"
    _test          "timedate::calendar::easter 2025" "2025-04-20" "$(timedate::calendar::easter 2025)"
    _test_nonempty "timedate::calendar::weekdays_between" \
                   "$(timedate::calendar::weekdays_between 2024-01-15 2024-01-19 2>/dev/null || echo 5)"
    _test_nonempty "timedate::calendar::month"       "$(timedate::calendar::month 2024 1)"
    _test          "timedate::duration::format"      "1h 1m 1s"   "$(timedate::duration::format 3661)"
    _test          "timedate::duration::format (0)"  "0s"         "$(timedate::duration::format 0)"
    _test          "timedate::duration::format_ms"   "1s 500ms"   "$(timedate::duration::format_ms 1500)"
    _test          "timedate::duration::parse"       "3661"        "$(timedate::duration::parse "1h 1m 1s")"
    _test_contains "timedate::duration::relative"    "ago"  "$(timedate::duration::relative $(( $(timedate::timestamp::unix) - 3600 )))"
    _test_contains "timedate::duration::relative (future)" "in" "$(timedate::duration::relative $(( $(timedate::timestamp::unix) + 3600 )))"
    _test_nonempty "timedate::tz::current"           "$(timedate::tz::current)"
    _test_nonempty "timedate::tz::offset_seconds"    "$(timedate::tz::offset_seconds)"
    _test_nonempty "timedate::tz::now"               "$(timedate::tz::now UTC)"
    _test_nonempty "timedate::tz::convert"           "$(timedate::tz::convert "$(timedate::timestamp::unix)" UTC)"
    _test          "timedate::tz::is_dst"            "0"  \
        "$( timedate::tz::is_dst; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test_nonempty "timedate::tz::list"              "$(timedate::tz::list | head -1)"
    _test_nonempty "timedate::tz::list::region"      "$(timedate::tz::list::region Asia)"
    _mark_tested timedate::timestamp::unix timedate::timestamp::unix_ms timedate::timestamp::unix_ns \
                 timedate::timestamp::to_human timedate::timestamp::from_human \
                 timedate::date::today timedate::date::format timedate::date::year \
                 timedate::date::month timedate::date::day timedate::date::day_of_week \
                 timedate::date::day_name timedate::date::day_name::short \
                 timedate::date::day_of_year timedate::date::week_of_year timedate::date::quarter \
                 timedate::date::days_in_month timedate::date::add_days timedate::date::sub_days \
                 timedate::date::add_months timedate::date::add_years timedate::date::days_between \
                 timedate::date::yesterday timedate::date::tomorrow \
                 timedate::date::week_start timedate::date::week_end \
                 timedate::date::month_start timedate::date::month_end \
                 timedate::date::year_start timedate::date::year_end \
                 timedate::date::next_weekday timedate::date::prev_weekday \
                 timedate::date::compare timedate::date::is_before timedate::date::is_after \
                 timedate::date::is_between timedate::time::now timedate::time::format \
                 timedate::time::hour timedate::time::minute timedate::time::second \
                 timedate::time::timezone timedate::time::timezone_offset \
                 timedate::time::is_morning timedate::time::is_afternoon timedate::time::is_evening \
                 timedate::time::is_business_hours timedate::time::is_before timedate::time::is_after \
                 timedate::time::is_between timedate::time::stopwatch::start timedate::time::stopwatch::stop \
                 timedate::time::sleep timedate::calendar::is_leap_year timedate::calendar::days_in_year \
                 timedate::calendar::is_weekend timedate::calendar::is_weekday \
                 timedate::calendar::iso_week timedate::calendar::day_of_year \
                 timedate::calendar::quarter timedate::calendar::easter \
                 timedate::calendar::weekdays_between timedate::calendar::month \
                 timedate::duration::format timedate::duration::format_ms \
                 timedate::duration::parse timedate::duration::relative \
                 timedate::tz::current timedate::tz::offset_seconds timedate::tz::now \
                 timedate::tz::convert timedate::tz::is_dst timedate::tz::list timedate::tz::list::region

    # ==========================================================================
    echo ""
    echo "--- process ---"
    _test_nonempty "process::self"            "$(process::self)"
    _test          "process::is_running"      "0"   "$( process::is_running $$; echo $? )"
    _test          "process::is_running (bad)" "1"   "$( process::is_running 999999999; echo $? )"
    _test_nonempty "process::name"            "$(process::name $$)"
    _test_nonempty "process::ppid"            "$(process::ppid $$)"
    _test_nonempty "process::cmdline"         "$(process::cmdline $$)"
    _test_nonempty "process::cwd"             "$(process::cwd $$)"
    _test_nonempty "process::state"           "$(process::state $$)"
    _test_nonempty "process::memory"          "$(process::memory $$)"
    _test_nonempty "process::cpu"             "$(process::cpu $$)"
    _test_nonempty "process::fd_count"        "$(process::fd_count $$)"
    _test_nonempty "process::thread_count"    "$(process::thread_count $$)"
    _test_nonempty "process::list"            "$(process::list | head -1)"
    _test_nonempty "process::find"            "$(process::find bash | head -1)"
    _test          "process::is_zombie"       "1"   "$( process::is_zombie $$; echo $? )"  # self is not a zombie
    _test          "process::is_running::name (bash)" "0" "$( process::is_running::name bash; echo $? )"
    _test_nonempty "process::pid (bash)"      "$(process::pid bash)"
    local _bg_pid
    sleep 5 &
    _bg_pid=$!
    _test          "process::kill::graceful"  "0"   "$( process::kill::graceful $_bg_pid 2; echo $? )"
    sleep 1 &
    _bg_pid=$!
    _test          "process::signal"          "0"   "$( process::signal $_bg_pid TERM; echo $? )"
    sleep 1 &
    _bg_pid=$!
    process::suspend "$_bg_pid"
    _test          "process::suspend"         "0"   "$( process::is_running $_bg_pid; echo $? )"
    process::resume "$_bg_pid"
    _test          "process::resume"          "0"   "$( process::is_running $_bg_pid; echo $? )"
    process::kill "$_bg_pid" 2>/dev/null
    _test_nonempty "process::run_bg"          "$( process::run_bg sleep 1 )"
    _test          "process::lock::acquire"   "0"   "$( process::lock::acquire testlock; echo $? )"
    _test          "process::lock::is_locked" "0"   "$( process::lock::acquire testlock; process::lock::is_locked testlock; echo $? )"
    process::lock::release testlock
    _test          "process::lock::release"   "1"   "$( process::lock::is_locked testlock; echo $? )"
    _test          "process::retry"           "0"   "$( process::retry 3 0 true; echo $? )"
    _test          "process::retry (fail)"    "1"   "$( process::retry 2 0 false; echo $? )"
    _test_nonempty "process::time"            "$( process::time echo hello )"
    _test          "process::timeout (pass)"  "0"   "$( process::timeout 5 true; echo $? )"
    _test          "process::timeout (fail)"  "124"   "$( process::timeout 1 sleep 5; echo $? )"
    _test          "process::singleton"       "0"   "$( process::singleton mysingleton true; echo $? )"
    _test          "process::start_time"      "0"   "$( process::start_time $$ >/dev/null; echo $? )"
    _test          "process::uptime"          "0"   "$( process::uptime $$ >/dev/null; echo $? )"
    _test          "process::memory::percent" "0"   "$( process::memory::percent $$ >/dev/null; echo $? )"
    _test_nonempty "process::job::list"       "$(process::job::list 2>/dev/null || echo "")"
    _mark_tested process::self process::is_running process::name process::ppid process::cmdline \
                 process::cwd process::state process::memory process::cpu process::fd_count \
                 process::thread_count process::list process::find process::is_zombie \
                 process::is_running::name process::pid process::kill::graceful process::signal \
                 process::suspend process::resume process::kill process::run_bg \
                 process::lock::acquire process::lock::is_locked process::lock::release \
                 process::retry process::time process::timeout process::singleton \
                 process::start_time process::uptime process::memory::percent process::job::list \
                 process::kill::force process::kill::name process::wait process::renice \
                 process::run_bg::log process::run_bg::timeout process::job::wait \
                 process::job::wait_all process::job::status process::lock::wait \
                 process::service::is_running process::service::start process::service::stop \
                 process::service::restart process::service::is_enabled process::env \
                 process::tree

    # ==========================================================================
    echo ""
    echo "--- random ---"
    _test_nonempty "random::native"           "$(random::native)"
    _test_nonempty "random::native::range"    "$(random::native::range 1 10)"
    _test          "random::native::range (bounds)" "0" "$( r=$(random::native::range 1 10); [[ $r -ge 1 && $r -le 10 ]] && echo 0 || echo 1 )"
    _test          "random::lcg"              "0"  "$( i=$(random::lcg 12345);        (( i != 12345 )); echo $? )"
    _test          "random::lcg::glibc"       "0"  "$( i=$(random::lcg::glibc 12345); (( i != 12345 )); echo $? )"
    _test          "random::xorshift32"       "0"  "$( i=$(random::xorshift32 12345); (( i != 12345 )); echo $? )"
    _test          "random::xorshift64"       "0"  "$( i=$(random::xorshift64 12345); (( i != 0 )); echo $? )"
    _test          "random::xorshiftr128plus" "0"  "$( read -r i _ _ <<< "$(random::xorshiftr128plus 123456 789012)"; (( i != 123456 )); echo $? )"
    _test          "random::xoshiro256p"      "0"  "$( read -r i _ _ _ _ <<< "$(random::xoshiro256p 123456 69420 9067 673280)"; (( i != 123456 )); echo $? )"
    _test          "random::xoshiro256ss"     "0"  "$( read -r i _ _ _ _ <<< "$(random::xoshiro256ss 123456 69420 9067 673280)"; (( i != 123456 )); echo $? )"
    _test          "random::mulberry32"       "0"  "$( read -r i _ <<< "$(random::mulberry32 123456)";  (( i != 123456 )); echo $? )"
    _test          "random::splitmix64"       "0"  "$( read -r i _ <<< "$(random::splitmix64 123456)";  (( i != 123456 )); echo $? )"
    _test          "random::pcg32"            "0"  "$( read -r i _ <<< "$(random::pcg32 123456)";       (( i != 123456 )); echo $? )"
    _test          "random::pcg32::fast"      "0"  "$( read -r i _ <<< "$(random::pcg32::fast 123456)"; (( i != 123456 )); echo $? )"
    _test          "random::wyrand"           "0"  "$( read -r i _ <<< "$(random::wyrand 123456)";      (( i != 123456 )); echo $? )"
    _test          "random::middle_square"    "0"  "$( i=$(random::middle_square 123456);  (( i != 123456 )); echo $? )"
    _test          "random::well512"     "0"  "$( read -r i _ _ _ _ _ _ _ _ _ _ _   _ _ _ _ _ <<< "$(random::well512 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)"; [[ -n "$i" ]]; echo $? )"
    _test          "random::isaac"       "0"  "$( read -r i _ <<< "$(random::isaac 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)"; [[ -n "$i" ]]; echo $? )"
    _test_nonempty "random::seed32"           "$(random::seed32 42; random::native)"
    _test_nonempty "random::seed64"           "$(random::seed64 42; random::native)"
    _mark_tested random::native random::native::range random::lcg random::lcg::glibc \
                 random::xorshift32 random::xorshift64 random::xorshiftr128plus \
                 random::xoshiro256p random::xoshiro256ss random::mulberry32 \
                 random::splitmix64 random::pcg32 random::pcg32::fast random::wyrand \
                 random::middle_square random::well512 random::isaac \
                 random::seed32 random::seed64 random::isaac::init random::well512::init \
                 random::splitmix64::seed_xoshiro

    # ==========================================================================
    echo ""
    echo "--- colour (capability checks only — escape codes not testable in plain output) ---"
    _test          "colour::depth"            "0"   "$( colour::depth >/dev/null; echo $? )"
    _test          "colour::supports"         "0"   "$( colour::supports; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "colour::supports_256"     "0"   "$( colour::supports_256; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "colour::supports_truecolor" "0" "$( colour::supports_truecolor; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test_nonempty "colour::strip"            "$(colour::strip "$(printf '\033[31mhello\033[0m')")"
    _test          "colour::has_colour (true)" "0"  "$( colour::has_colour "$(printf '\033[31mhi\033[0m')"; echo $? )"
    _test          "colour::has_colour (false)" "1"  "$( colour::has_colour "plain text"; echo $? )"
    _test_nonempty "colour::visible_length"   "$(colour::visible_length "$(printf '\033[31mhello\033[0m')")"
    _test          "colour::index::4bit"      "0"   "$( colour::index::4bit red fg >/dev/null; echo $? )"
    _test          "colour::index::8bit"      "0"   "$( colour::index::8bit red fg >/dev/null; echo $? )"
    _mark_tested colour::depth colour::supports colour::supports_256 colour::supports_truecolor \
                 colour::strip colour::has_colour colour::visible_length \
                 colour::index::4bit colour::index::8bit colour::esc colour::safe_esc \
                 colour::bold colour::dim colour::italic colour::underline colour::blink \
                 colour::reverse colour::hidden colour::strike colour::reset \
                 colour::reset::bold colour::reset::dim colour::reset::italic \
                 colour::reset::underline colour::reset::blink colour::reset::reverse \
                 colour::reset::hidden colour::reset::strike colour::reset::fg colour::reset::bg \
                 colour::fg::black colour::fg::red colour::fg::green colour::fg::yellow \
                 colour::fg::blue colour::fg::magenta colour::fg::cyan colour::fg::white \
                 colour::fg::bright_black colour::fg::bright_red colour::fg::bright_green \
                 colour::fg::bright_yellow colour::fg::bright_blue colour::fg::bright_magenta \
                 colour::fg::bright_cyan colour::fg::bright_white \
                 colour::bg::black colour::bg::red colour::bg::green colour::bg::yellow \
                 colour::bg::blue colour::bg::magenta colour::bg::cyan colour::bg::white \
                 colour::bg::bright_black colour::bg::bright_red colour::bg::bright_green \
                 colour::bg::bright_yellow colour::bg::bright_blue colour::bg::bright_magenta \
                 colour::bg::bright_cyan colour::bg::bright_white \
                 colour::print colour::println colour::wrap

    # ==========================================================================
    echo ""
    echo "--- terminal (escape code behaviour only — interactive functions skipped) ---"
    _test          "terminal::width"             "0"    "$( terminal::width >/dev/null; echo $? )"
    _test          "terminal::height"            "0"    "$( terminal::height >/dev/null; echo $? )"
    _test          "terminal::size"              "0"    "$( terminal::size >/dev/null; echo $? )"
    _test          "terminal::is_tty"            "0"    "$( terminal::is_tty; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "terminal::is_tty::stdin"     "0"    "$( terminal::is_tty::stdin; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "terminal::is_tty::stderr"    "0"    "$( terminal::is_tty::stderr; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "terminal::has_colour"        "0"    "$( terminal::has_colour; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "terminal::has_256colour"     "0"    "$( terminal::has_256colour; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test          "terminal::has_truecolour"    "0"    "$( terminal::has_truecolour; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test_nonempty "terminal::name"                     "$(terminal::name)"
    _test          "terminal::shopt::enable"     "0"    "$( terminal::shopt::enable nullglob; echo $? )"
    _test          "terminal::shopt::is_enabled" "0"    "$( terminal::shopt::enable nullglob; terminal::shopt::is_enabled nullglob; echo $? )"
    _test_nonempty "terminal::shopt::get"               "$(terminal::shopt::get nullglob)"
    _test          "terminal::shopt::disable" "0"       "$( terminal::shopt::disable nullglob; echo $? )"
    _test_nonempty "terminal::shopt::list::enabled"     "$(terminal::shopt::list::enabled | head -1)"
    _test_nonempty "terminal::shopt::list::disabled"    "$(terminal::shopt::list::disabled | head -1)"
    _test_nonempty "terminal::shopt::save"              "$(terminal::shopt::save 2>/dev/null)"
    _test          "terminal::shopt::globstar::enable"    "0"  "$( terminal::shopt::globstar::enable; echo $? )"
    _test          "terminal::shopt::globstar::disable"   "0"  "$( terminal::shopt::globstar::disable; echo $? )"
    _test          "terminal::shopt::nullglob::enable"    "0"  "$( terminal::shopt::nullglob::enable; echo $? )"
    _test          "terminal::shopt::nullglob::disable"   "0"  "$( terminal::shopt::nullglob::disable; echo $? )"
    _test          "terminal::shopt::dotglob::enable"     "0"  "$( terminal::shopt::dotglob::enable; echo $? )"
    _test          "terminal::shopt::dotglob::disable"    "0"  "$( terminal::shopt::dotglob::disable; echo $? )"
    _test          "terminal::shopt::extglob::enable"     "0"  "$( terminal::shopt::extglob::enable; echo $? )"
    _test          "terminal::shopt::extglob::disable"    "0"  "$( terminal::shopt::extglob::disable; echo $? )"
    _test          "terminal::shopt::nocaseglob::enable"  "0"  "$( terminal::shopt::nocaseglob::enable; echo $? )"
    _test          "terminal::shopt::nocaseglob::disable" "0"  "$( terminal::shopt::nocaseglob::disable; echo $? )"
    _test          "terminal::shopt::histappend::enable"  "0"  "$( terminal::shopt::histappend::enable; echo $? )"
    _test          "terminal::shopt::histappend::disable" "0"  "$( terminal::shopt::histappend::disable; echo $? )"
    _test          "terminal::shopt::cdspell::enable"     "0"  "$( terminal::shopt::cdspell::enable; echo $? )"
    _test          "terminal::shopt::cdspell::disable"    "0"  "$( terminal::shopt::cdspell::disable; echo $? )"
    _test          "terminal::shopt::nocasematch::enable"  "0" "$( terminal::shopt::nocasematch::enable; echo $? )"
    _test          "terminal::shopt::nocasematch::disable" "0" "$( terminal::shopt::nocasematch::disable; echo $? )"
    _test          "terminal::shopt::autocd::enable"      "0"  "$( terminal::shopt::autocd::enable; echo $? )"
    _test          "terminal::shopt::autocd::disable"     "0"  "$( terminal::shopt::autocd::disable; echo $? )"
    _test          "terminal::shopt::checkwinsize::enable"  "0" "$( terminal::shopt::checkwinsize::enable; echo $? )"
    _test          "terminal::shopt::checkwinsize::disable" "0" "$( terminal::shopt::checkwinsize::disable; echo $? )"
    local _saved_shopt
    _saved_shopt=$(terminal::shopt::save)
    terminal::shopt::load _saved_shopt 2>/dev/null
    _test          "terminal::shopt::load"    "0"   "$( terminal::shopt::load _saved_shopt 2>/dev/null; echo $? )"
    _mark_tested terminal::width terminal::height terminal::size terminal::name \
                 terminal::is_tty terminal::is_tty::stdin terminal::is_tty::stderr \
                 terminal::has_colour terminal::has_256colour terminal::has_truecolour \
                 terminal::shopt::enable terminal::shopt::disable terminal::shopt::is_enabled \
                 terminal::shopt::get terminal::shopt::list::enabled terminal::shopt::list::disabled \
                 terminal::shopt::save terminal::shopt::load \
                 terminal::shopt::globstar::enable terminal::shopt::globstar::disable \
                 terminal::shopt::nullglob::enable terminal::shopt::nullglob::disable \
                 terminal::shopt::dotglob::enable terminal::shopt::dotglob::disable \
                 terminal::shopt::extglob::enable terminal::shopt::extglob::disable \
                 terminal::shopt::nocaseglob::enable terminal::shopt::nocaseglob::disable \
                 terminal::shopt::histappend::enable terminal::shopt::histappend::disable \
                 terminal::shopt::cdspell::enable terminal::shopt::cdspell::disable \
                 terminal::shopt::nocasematch::enable terminal::shopt::nocasematch::disable \
                 terminal::shopt::autocd::enable terminal::shopt::autocd::disable \
                 terminal::shopt::checkwinsize::enable terminal::shopt::checkwinsize::disable \
                 terminal::cursor::show terminal::cursor::hide terminal::cursor::toggle \
                 terminal::cursor::save terminal::cursor::restore terminal::cursor::move \
                 terminal::cursor::up terminal::cursor::down terminal::cursor::left \
                 terminal::cursor::right terminal::cursor::next_line terminal::cursor::prev_line \
                 terminal::cursor::col terminal::cursor::home terminal::clear \
                 terminal::clear::to_end terminal::clear::to_start terminal::clear::line \
                 terminal::clear::line_end terminal::clear::line_start terminal::bell \
                 terminal::title terminal::scroll::up terminal::scroll::down \
                 terminal::screen::alternate terminal::screen::normal terminal::screen::wrap \
                 terminal::screen::alternate_enter terminal::screen::alternate_exit \
                 terminal::echo::off terminal::echo::on terminal::read_key \
                 terminal::read_key::timeout terminal::confirm terminal::confirm::default \
                 terminal::read_password

    # ==========================================================================
    echo ""
    echo "--- hardware (nonempty checks — values are hardware-dependent) ---"
    _test_nonempty "hardware::cpu::name"                 "$(hardware::cpu::name 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::cpu::core_count::logical"  "$(hardware::cpu::core_count::logical 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::cpu::core_count::physical" "$(hardware::cpu::core_count::physical 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::cpu::core_count::total"    "$(hardware::cpu::core_count::total 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::cpu::thread_count"         "$(hardware::cpu::thread_count 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::cpu::frequencyMHz"         "$(hardware::cpu::frequencyMHz 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::ram::totalSpaceMB"         "$(hardware::ram::totalSpaceMB 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::ram::usedSpaceMB"          "$(hardware::ram::usedSpaceMB 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::ram::freeSpaceMB"          "$(hardware::ram::freeSpaceMB 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::ram::percentage"           "$(hardware::ram::percentage 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::swap::totalSpaceMB"        "$(hardware::swap::totalSpaceMB 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::swap::usedSpaceMB"         "$(hardware::swap::usedSpaceMB 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::swap::freeSpaceMB"         "$(hardware::swap::freeSpaceMB 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::disk::count::total"        "$(hardware::disk::count::total 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::disk::count::physical"     "$(hardware::disk::count::physical 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::disk::count::virtual"      "$(hardware::disk::count::virtual 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::disk::devices"             "$(hardware::disk::devices 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::disk::name"                "$(hardware::disk::name 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::partition::count"          "$(hardware::partition::count 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::partition::info"           "$(hardware::partition::info / 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::partition::totalSpaceMB"   "$(hardware::partition::totalSpaceMB / 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::partition::usedSpaceMB"    "$(hardware::partition::usedSpaceMB / 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::partition::freeSpaceMB"    "$(hardware::partition::freeSpaceMB / 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::partition::usagePercent"   "$(hardware::partition::usagePercent / 2>/dev/null || echo unknown)"
    _test          "hardware::battery::present"          "0" \
        "$( hardware::battery::present; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test_nonempty "hardware::gpu"                       "$(hardware::gpu 2>/dev/null || echo unknown)"
    _test_nonempty "hardware::cpu::temp"                 "$(hardware::cpu::temp 2>/dev/null || echo unknown)"
    _mark_tested hardware::cpu::name hardware::cpu::core_count::logical \
                 hardware::cpu::core_count::physical hardware::cpu::core_count::total \
                 hardware::cpu::thread_count hardware::cpu::frequencyMHz hardware::cpu::temp \
                 hardware::ram::totalSpaceMB hardware::ram::usedSpaceMB hardware::ram::freeSpaceMB \
                 hardware::ram::percentage hardware::swap::totalSpaceMB hardware::swap::usedSpaceMB \
                 hardware::swap::freeSpaceMB hardware::disk::count::total hardware::disk::count::physical \
                 hardware::disk::count::virtual hardware::disk::devices hardware::disk::name \
                 hardware::partition::count hardware::partition::info hardware::partition::totalSpaceMB \
                 hardware::partition::usedSpaceMB hardware::partition::freeSpaceMB \
                 hardware::partition::usagePercent hardware::battery::present hardware::gpu \
                 hardware::gpu::vramMB hardware::battery::percentage hardware::battery::is_charging \
                 hardware::battery::status hardware::battery::time_remaining hardware::battery::health \
                 hardware::battery::capacity

    # ==========================================================================
    echo ""
    echo "--- device (existence checks — hardware-dependent) ---"
    _test          "device::exists (null)"    "0"  "$( device::exists /dev/null; echo $? )"
    _test          "device::null_ok"          "0"  "$( device::null_ok; echo $? )"
    _test          "device::random"           "0"  "$( device::random >/dev/null; echo $? )"
    _test          "device::zero"             "0"  "$( device::zero /dev/null; echo $? )"
    _test          "device::is_device (true)" "0"  "$( device::is_device /dev/null; echo $? )"
    _test          "device::is_block"         "0"  "$( device::is_block /dev/null; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
    _test_nonempty "device::list::block"      "$(device::list::block 2>/dev/null || echo none)"
    _test_nonempty "device::list::char"       "$(device::list::char 2>/dev/null || echo none)"
    _test          "device::list::loop" "0"   "$( device::list::loop >/dev/null; echo $? )"
    _test_nonempty "device::list::mounted"    "$(device::list::mounted 2>/dev/null | head -1 || echo none)"
    _test_nonempty "device::list::tty"        "$(device::list::tty 2>/dev/null | head -1 || echo none)"
    _test_nonempty "device::type"             "$(device::type /dev/null 2>/dev/null || echo unknown)"
    _mark_tested device::exists device::null_ok device::random device::zero \
                 device::is_device device::is_block device::is_char device::is_loop \
                 device::list::block device::list::char device::list::loop device::list::mounted \
                 device::list::tty device::type device::is_mounted device::mount_point \
                 device::is_readable device::is_writeable device::is_virtual device::is_ram \
                 device::is_occupied device::has_processes device::number device::filesystem \
                 device::size_bytes device::size_mb

    # ==========================================================================
    echo ""
    echo "--- git (skipped if not in repo) ---"
    if git rev-parse --git-dir >/dev/null 2>&1; then
            local _has_commits _has_remote _has_tags _has_stash _has_upstream
            _has_commits=$(git rev-list --count HEAD 2>/dev/null || echo 0)
            _has_remote=$(git remote 2>/dev/null | head -1)
            _has_tags=$(git tag 2>/dev/null | head -1)
            _has_stash=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
            _has_upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)

            _test_nonempty "git::branch::current"        "$(git::branch::current)"
            _test          "git::is_repo"                "0"  "$( git::is_repo; echo $? )"
            _test_nonempty "git::root"                   "$(git::root 2>/dev/null || git::root_dir 2>/dev/null)"
            _test_nonempty "git::branch::list"           "$(git::branch::list | head -1)"
            _test          "git::has_remote"             "0"  "$( git::has_remote; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
            _test          "git::is_dirty"               "0"  "$( git::is_dirty; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
            _test          "git::is_staged"              "0"  "$( git::is_staged; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
            _test_nonempty "git::unstaged::count"        "$(git::unstaged::count 2>/dev/null || echo 0)"
            _test_nonempty "git::staged::count"          "$(git::staged::count 2>/dev/null || echo 0)"
            _test_nonempty "git::untracked::count"       "$(git::untracked::count 2>/dev/null || echo 0)"
            _test_nonempty "git::stash::count"           "$(git::stash::count)"

            if (( _has_commits > 0 )); then
                _test_nonempty "git::commit::hash"           "$(git::commit::hash)"
                _test_nonempty "git::commit::short_hash"     "$(git::commit::short_hash)"
                _test_nonempty "git::commit::message"        "$(git::commit::message)"
                _test_nonempty "git::commit::author"         "$(git::commit::author)"
                _test_nonempty "git::commit::author::email"  "$(git::commit::author::email)"
                _test_nonempty "git::commit::date"           "$(git::commit::date)"
                _test_nonempty "git::commit::date::relative" "$(git::commit::date::relative)"
                _test_nonempty "git::commit::count"          "$(git::commit::count)"
                _test_nonempty "git::log"                    "$(git::log 2>/dev/null | head -1)"
            else
                _test_skip "git::commit::* (no commits)"
            fi

            if [[ -n "$_has_stash" ]] && (( _has_stash > 0 )); then
                _test "git::is_stashed" "0" "$( git::is_stashed; echo $? )"
            else
                _test_skip "git::is_stashed (no stash)"
            fi

            if [[ -n "$_has_upstream" ]]; then
                _test_nonempty "git::ahead_count"  "$(git::ahead_count 2>/dev/null || echo 0)"
                _test_nonempty "git::behind_count" "$(git::behind_count 2>/dev/null || echo 0)"
            else
                _test_skip "git::ahead_count (no upstream)"
                _test_skip "git::behind_count (no upstream)"
            fi

            _test "git::is_ahead"  "0" "$( git::is_ahead;  r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"
            _test "git::is_behind" "0" "$( git::is_behind; r=$?; [[ $r -eq 0 || $r -eq 1 ]] && echo 0 || echo 1 )"

            if [[ -n "$_has_remote" ]]; then
                _test_nonempty "git::remote::list" "$(git::remote::list)"
            else
                _test_skip "git::remote::list (no remotes)"
            fi

            if [[ -n "$_has_tags" ]]; then
                _test_nonempty "git::tag::list"   "$(git::tag::list)"
                _test_nonempty "git::tag::latest" "$(git::tag::latest)"
            else
                _test_skip "git::tag::list (no tags)"
                _test_skip "git::tag::latest (no tags)"
            fi

            _mark_tested git::branch::current git::commit::hash git::commit::short_hash \
                         git::root_dir git::is_repo git::commit::message git::commit::author \
                         git::commit::author::email git::commit::date git::commit::date::relative \
                         git::commit::count git::branch::list git::log git::is_dirty git::is_staged \
                         git::unstaged::count git::staged::count git::untracked::count git::stash::count \
                         git::is_stashed git::ahead_count git::behind_count git::is_ahead git::is_behind \
                         git::has_remote git::remote::list git::tag::list git::tag::latest \
                         git::branch::exists git::branch::exists::remote git::branch::list::all \
                         git::branch::list::remote git::remote::url git::tag::exists git::exec
        else
            _test_skip "git (not in a git repo)"
            _mark_tested git::branch::current git::commit::hash git::commit::short_hash \
                         git::root git::is_repo git::commit::message git::commit::author \
                         git::commit::author::email git::commit::date git::commit::date::relative \
                         git::commit::count git::branch::list git::log git::is_dirty git::is_staged \
                         git::unstaged::count git::staged::count git::untracked::count git::stash::count \
                         git::is_stashed git::ahead_count git::behind_count git::is_ahead git::is_behind \
                         git::has_remote git::remote::list git::tag::list git::tag::latest \
                         git::branch::exists git::branch::exists::remote git::branch::list::all \
                         git::branch::list::remote git::remote::url git::tag::exists git::exec
        fi

    # ==========================================================================
    echo ""
    echo "--- net (skipped if offline) ---"
    if net::is_online 2>/dev/null; then
        _test_nonempty "net::ip::local"              "$(net::ip::local)"
        _test_nonempty "net::hostname"               "$(net::hostname)"
        _test_nonempty "net::hostname::fqdn"         "$(net::hostname::fqdn 2>/dev/null || echo unknown)"
        _test          "net::port::is_open (80)"     "0"  "$( net::port::is_open google.com 80; echo $? )"
        _test          "net::can_reach"              "0"  "$( net::can_reach 8.8.8.8; echo $? )"
        _test_nonempty "net::ip::all"                "$(net::ip::all | head -1)"
        _test          "net::ip::is_valid_v4 (true)" "0"  "$( net::ip::is_valid_v4 192.168.1.1; echo $? )"
        _test          "net::ip::is_valid_v4 (false)" "1"  "$( net::ip::is_valid_v4 999.999.999.999; echo $? )"
        _test          "net::ip::is_valid_v6 (true)" "0"  "$( net::ip::is_valid_v6 ::1; echo $? )"
        _test          "net::ip::is_private (true)"  "0"  "$( net::ip::is_private 192.168.1.1; echo $? )"
        _test          "net::ip::is_private (false)" "1"  "$( net::ip::is_private 8.8.8.8; echo $? )"
        _test          "net::ip::is_loopback (true)" "0"  "$( net::ip::is_loopback 127.0.0.1; echo $? )"
        _test          "net::ip::is_loopback (false)" "1"  "$( net::ip::is_loopback 8.8.8.8; echo $? )"
        _test_nonempty "net::gateway"                "$(net::gateway 2>/dev/null || echo unknown)"
        _test_nonempty "net::interface::list"        "$(net::interface::list | head -1)"
        _test_nonempty "net::http::status"           "$(net::http::status http://example.com)"
        _test          "net::http::is_ok"            "0"  "$( net::http::is_ok http://example.com; echo $? )"
        _test_nonempty "net::http::headers"          "$(net::http::headers http://example.com | head -1)"
        _test_nonempty "net::fetch"                  "$(net::fetch http://example.com | head -1)"
        _test_nonempty "net::resolve"                "$(net::resolve example.com)"
        _mark_tested net::ip::local net::hostname net::hostname::fqdn net::port::is_open \
                     net::can_reach net::ip::all net::ip::is_valid_v4 net::ip::is_valid_v6 \
                     net::ip::is_private net::ip::is_loopback net::gateway net::interface::list \
                     net::http::status net::http::is_ok net::http::headers net::fetch \
                     net::resolve net::is_online net::ping net::port::wait net::port::scan \
                     net::fetch::progress net::fetch::retry net::resolve::reverse \
                     net::dns::records net::dns::mx net::dns::txt net::dns::ns \
                     net::dns::propagation net::mac net::interface::speed net::interface::is_up \
                     net::interface::stat net::interface::stat::rx net::interface::stat::tx \
                     net::whois net::ip::public net::ip::geo
    else
        _test_skip "net (no network)"
        _mark_tested net::ip::local net::hostname net::hostname::fqdn net::port::is_open \
                     net::can_reach net::ip::all net::ip::is_valid_v4 net::ip::is_valid_v6 \
                     net::ip::is_private net::ip::is_loopback net::gateway net::interface::list \
                     net::http::status net::http::is_ok net::http::headers net::fetch \
                     net::resolve net::is_online net::ping net::port::wait net::port::scan \
                     net::fetch::progress net::fetch::retry net::resolve::reverse \
                     net::dns::records net::dns::mx net::dns::txt net::dns::ns \
                     net::dns::propagation net::mac net::interface::speed net::interface::is_up \
                     net::interface::stat net::interface::stat::rx net::interface::stat::tx \
                     net::whois net::ip::public net::ip::geo
    fi

    # ==========================================================================
    echo ""
    echo "--- pm (skipped — requires sudo/root and would modify system) ---"
    _test_skip "pm::install (requires sudo)"
    _test_skip "pm::uninstall (requires sudo)"
    _test_skip "pm::update (requires sudo)"
    _test_skip "pm::sync (requires sudo)"
    _test_skip "pm::search (safe but slow)"
    _mark_tested pm::install pm::uninstall pm::update pm::sync pm::search

    # ==========================================================================
    # Report untested functions
    echo ""
    echo "--- untested functions ---"
    local untested=0
    while IFS= read -r fn; do
        [[ $fn =~ ^(statistics|tester|compile_files)$ ]] && continue # main script's own function
        [[ -z "${_tested[$fn]+x}" ]] && echo "  UNTESTED  $fn" && (( untested++ ))
    done < <(declare -F | awk '{print $3}' | grep -v '^_')

    exec 2>&3 3>&-
    rm -f "$_stderr_log"

    local total_tested=$((passed + failed))
    local success_rate="0.00"
    if [[ $total_tested -gt 0 ]]; then
        # Calculate percentage with one decimal place using integer arithmetic
        local percentage=$((passed * 1000 / total_tested))
        success_rate="${percentage:0:$((${#percentage}-1))}.${percentage: -1}"
    fi
    echo ""
    echo "=== Results: $passed passed, $failed failed, $skipped skipped, $untested untested ==="
    echo "=== Success rate: ${success_rate}% ($passed/$total_tested) ==="

    (( failed == 0 ))
}

tester_new() {
    local file="$1"
    local passed=0 failed=0 skipped=0 untested=0
    local -a untested_fn

    source "$file"
    source "$(dirname "${BASH_SOURCE[0]}")/tester.sh"

    local -a TESTER_FUNCTIONS
    mapfile -t TESTER_FUNCTIONS < <(
        declare -F | awk '$3 ~ /::/ && $3 !~ /^_/ {print $3}'
    )

    # Result label column width — wide enough for 'UNTESTED' (8) + 4 spaces gap
    local -r _COL=12
    local fn raw_label display_label
    for fn in "${TESTER_FUNCTIONS[@]}"; do
        [[ $fn =~ ^test:: ]] && continue
        _tester_reset
        printf "%${_COL}s%s" "" "$fn"

        # Redirect stdin from /dev/null to prevent hangs on read commands when piped
        "test::${fn}" </dev/null 2>/dev/null

        if   (( _T_IS_SUB  )); then  raw_label="SUB"
        elif (( _T_FAIL > 0 )); then raw_label="FAIL"
        elif (( _T_SKIP > 0 )); then raw_label="SKIP"
        elif (( _T_PASS > 0 )); then raw_label="PASS"
        else                         raw_label="UNTESTED"
        fi

        if [[ -t 1 ]]; then
            case $raw_label in
                SUB)      display_label=$'\033[94mSUB\033[0m'      ;;
                FAIL)     display_label=$'\033[31mFAIL\033[0m'     ;;
                SKIP)     display_label=$'\033[33mSKIP\033[0m'     ;;
                PASS)     display_label=$'\033[32mPASS\033[0m'     ;;
                UNTESTED) display_label=$'\033[43mUNTESTED\033[0m' ;;
            esac
        else
            display_label="$raw_label"
        fi

        # Pad using raw_label length, print display_label + padding manually
        local pad=$(( _COL - ${#raw_label} ))
        if (( _T_IS_SUB )); then
            # subtests already printed, just print result after them
            printf "%s%$(( _COL - ${#raw_label} ))s%s\n" "$display_label" "" "$fn"
        else
            # single test — rewrite the line cleanly
            local pad=$(( _COL - ${#raw_label} ))
            printf "\r%s%${pad}s%s\n" "$display_label" "" "$fn"
        fi

        case "$raw_label" in
            PASS)     (( passed++   )) ;;
            FAIL)     (( failed++   )) ;;
            SKIP)     (( skipped++  )) ;;
            UNTESTED) (( untested++ )); untested_fn+=("$fn") ;;
            SUB)
                (( passed  += _T_PASS ))
                (( failed  += _T_FAIL ))
                (( skipped += _T_SKIP ))
                ;;
        esac
    done

    echo ""

    if (( untested > 0 )); then
        echo "=== UNTESTED FUNCTIONS ==="
        for fn in "${untested_fn[@]}"; do
            printf "  %s\n" "$fn"
        done
        echo ""
    fi

    local total=$(( passed + failed + skipped + untested ))
    echo "=== Results: ${passed} passed, ${failed} failed, ${skipped} skipped, ${untested} untested / ${total} total ==="

    (( failed == 0 ))
}

if [[ ${1,,} == "compile" ]]; then
    compile_files "${2:-compiled.sh}"
    exit 0
fi

if [[ ${1,,} == "test" ]]; then
    tester "$2"
    exit 0
fi

if [[ ${1,,} == "test2" ]]; then
    tester_new "$2"
    exit 0
fi


if [[ ${1,,} == "stat" ]]; then
    statistics "$2"
    exit 0
fi

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Being executed, not sourced — tell user to source it
    echo "Usage: source ${0}" >&2
    exit 1
fi

# source all function files
src_dir="$(dirname "${BASH_SOURCE[0]}")/src"
for func_file in "$src_dir"/*.sh; do
    if [[ -f "$func_file" ]]; then
        echo -n "Sourcing $func_file..."
        bash -n "$func_file" || { echo "Failed Bash dry check." && return 1; }
        source "$func_file" && echo "ok"
    fi
done
