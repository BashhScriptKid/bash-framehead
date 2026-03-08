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
    local src_dir="$(dirname "${BASH_SOURCE[0]}")/src"

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
        local fname="$(basename "$func_file")"

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

# Profile individual function load times
# Usage: profiler [file]
# Measures load time per function by sourcing each in isolation
profiler() {
    local file="${1:-bash-framehead.sh}"
    local tmpdir
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    # Source the framework to get function definitions
    source "$file" >/dev/null 2>&1 || {
        echo "Error: Failed to source $file" >&2
        return 1
    }

    # Collect all public functions (those with :: that don't start with _)
    local -a functions
    mapfile -t functions < <(
        declare -F | awk '$3 ~ /::/ && $3 !~ /^_/ {print $3}' | sort -u
    )

    echo "=== Profiling ${#functions[@]} functions ==="
    echo ""

    # Associative array to store timings
    declare -A timings

    # Extract each function's source and write to temp file
    for fn in "${functions[@]}"; do
        local func_file="$tmpdir/${fn//::/_}.sh"

        # Get the function definition using declare -f
        local func_def
        func_def=$(declare -f "$fn" 2>/dev/null)

        if [[ -n "$func_def" ]]; then
            # Write function to isolated file
            cat > "$func_file" <<EOF
#!/usr/bin/env bash
$func_def
EOF
        fi
    done

    # Now measure each function's load time in isolation
    local count=0
    for fn in "${functions[@]}"; do
        local func_file="$tmpdir/${fn//::/_}.sh"

        if [[ -f "$func_file" ]]; then
            # Create a fresh bash instance, source the function, measure time
            local duration_sec
            duration_sec=$(bash -c '
                if [[ "${BASH_VERSINFO[0]}" -ge 5 ]]; then
                    start=$EPOCHREALTIME
                    source "'"$func_file"'" >/dev/null 2>&1
                    end=$EPOCHREALTIME
                    awk "BEGIN {printf \"%.6f\", $end - $start}"
                else
                    echo "0"
                fi
            ' 2>/dev/null)

            # Store timing in seconds
            if [[ -n "$duration_sec" && "$duration_sec" != "0" ]]; then
                timings["$fn"]="$duration_sec"
            else
                timings["$fn"]="0"
            fi
            ((count++))
        fi
    done

    # Sort by timing (descending) and display
    echo "=== Function Load Times (slowest first) ==="
    echo ""

    # Create sortable output: timing function_name
    local -a sorted
    for fn in "${!timings[@]}"; do
        sorted+=("${timings[$fn]} $fn")
    done

    # Sort numerically descending and print
    printf '%s\n' "${sorted[@]}" | sort -rn | while read -r time fname; do
        # Convert seconds to milliseconds for display
        local ms
        ms=$(awk "BEGIN {printf \"%.3f\", $time * 1000}")
        printf "%10s ms  %s\n" "$ms" "$fname"
    done

    echo ""
    echo "Profiled $count functions in $tmpdir"
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
    local is_tty=false
    [[ -t 1 ]] && is_tty=true

    for fn in "${TESTER_FUNCTIONS[@]}"; do
        [[ $fn =~ ^test:: ]] && continue
        _tester_reset

        # Redirect stdin from /dev/null to prevent hangs on read commands when piped
        "test::${fn}" </dev/null 2>/dev/null

        if   (( _T_IS_SUB  )); then  raw_label="SUB"
        elif (( _T_FAIL > 0 )); then raw_label="FAIL"
        elif (( _T_SKIP > 0 )); then raw_label="SKIP"
        elif (( _T_PASS > 0 )); then raw_label="PASS"
        else                         raw_label="UNTESTED"
        fi

        if $is_tty; then
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

        if (( _T_IS_SUB )); then
            # subtests already printed, just print result after them
            printf "%s%$(( _COL - ${#raw_label} ))s%s\n" "$display_label" "" "$fn"
        elif $is_tty; then
            # TTY: print function name first, then rewrite with result
            printf "%${_COL}s%s" "" "$fn"
            local pad=$(( _COL - ${#raw_label} ))
            printf "\r%s%${pad}s%s\n" "$display_label" "" "$fn"
        else
            # Pipe: print linear format without \r
            printf "%s%$(( _COL - ${#raw_label} ))s%s\n" "$display_label" "" "$fn"
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

if [[ ${1,,} == "stat" ]]; then
    statistics "$2"
    exit 0
fi

if [[ ${1,,} == "profile" ]]; then
    profiler "$2"
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
