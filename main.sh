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

    # Check if running in strict mode (OPTIMIZE=1 or MINIFY=1)
    local is_strict_mode=false
    if [[ "${OPTIMIZE:-0}" == "1" || "${MINIFY:-0}" == "1" ]]; then
        is_strict_mode=true
    fi

    # Use temp file for atomic write
    local temp_file="${output_file}.tmp"
    local buffer=""

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

            # In strict mode, bail on any errors
            if $is_strict_mode && (( err_file > 0 )); then
                echo "" >&2
                echo "ERROR: ShellCheck found $err_file error(s) in $fname" >&2
                echo "Compilation aborted due to syntax errors in strict mode." >&2
                echo "" >&2
                echo "To force compilation despite errors (NOT RECOMMENDED):" >&2
                echo "  OPTIMIZE=0 MINIFY=0 ./main.sh compile $output_file << ''" >&2
                echo "" >&2
                echo "Fix the syntax errors above and re-run compilation." >&2
                rm -f "$temp_file" 2>/dev/null
                return 1
            fi
        fi

        echo -n "Processing $fname..."

        # Read file content
        local content
        content=$(cat "$func_file")

        # Strip shebang from all files (we'll add one at the end)
        if [[ "$content" =~ ^#! ]]; then
            content="${content#*$'\n'}"
        fi

        # Step 1: OPTIMIZE (if OPTIMIZE=1)
        if [[ "${OPTIMIZE:-0}" == "1" ]]; then
            local optimized
            optimized=$(optimize - <<< "$content")
            if ! bash -n <<< "$optimized" 2>/dev/null; then
                echo "Warning: Optimization produced invalid syntax for $fname, using original" >&2
            else
                content="$optimized"
            fi
        fi

        # Append to buffer
        if [[ -n "$buffer" ]]; then
            buffer+=$'\n'"$content"
        else
            buffer="$content"
        fi

        echo " ok${issue_str_file}"
        (( i++ ))
    done

    # Nothing was actually written (all files were empty)
    if (( i == 0 )); then
        echo "Error: All source files were empty, output not written" >&2
        rm -f "$temp_file" 2>/dev/null
        return 1
    fi

    # Step 2: MINIFY entire buffer (if MINIFY=1)
    if [[ "${MINIFY:-0}" == "1" ]]; then
        echo -n "Minifying entire buffer..."
        local minified
        minified=$(minify - <<< "$buffer")
        if ! bash -n <<< "$minified" 2>/dev/null; then
            echo "Warning: Minification produced invalid syntax, using pre-minified version" >&2
        else
            buffer="$minified"
            echo " ok"
        fi
    fi

    # Step 3: Prepend shebang and license header
    local final_content="#!/usr/bin/env bash"$'\n'"$LICENSE"$'\n'"$buffer"

    # Write to temp file first (atomic write)
    printf '%s\n' "$final_content" > "$temp_file"

    # Step 4: Validate final output with bash -n
    echo -n "Validating final output..."
    if ! bash -n "$temp_file" 2>/dev/null; then
        echo " FAILED" >&2
        echo "Error: Compiled output failed syntax check" >&2
        bash -n "$temp_file" 2>&1 | head -5 >&2
        rm -f "$temp_file"
        return 1
    fi
    echo " ok"

    # Step 5: Add version and move to final location
    if (( ! ${_COMPILE_SKIP_VERSION:-0} )); then
        local VERSION
        read -r -t 0.1 -n 10000 _drain 2>/dev/null || true
        read -r -p "Input a version for this file: " VERSION
        VERSION=${VERSION:-"$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")-dev+$(date +%d%m%y).$(date +%S)"}
        sed -i "s/## Version:/## Version: ${VERSION}/" "$temp_file"
    fi

    chmod +x "$temp_file" 2>/dev/null

    # Atomic move to final location
    mv "$temp_file" "$output_file"

    local total_issues=$(( total_err + total_warn + total_info ))
    local final_issue_str=""
    if (( total_issues > 0 )); then
        final_issue_str=" — $total_issues total issues ($total_err errors, $total_warn warnings, $total_info info)"
    fi

    echo "Compiled $i file(s) to $output_file${final_issue_str}"
}

# ==============================================================================
# compile_extended — compile core + extensions into a single file
#
# Runs the standard core compilation first, then processes each extension in
# ext/ with compile-time dependency validation before appending.
#
# Dependency checks (per extension):
#   1. Parses the header block for declared core: and external: dependencies
#   2. Parses the guard block for _guard_core_deps / _guard_ext_deps arrays
#   3. Cross-checks header vs guard — warns on mismatch
#   4. Verifies every listed core function exists (declare -f)
#   5. Verifies every listed external tool exists (command -v)
#      Supports | -separated alternatives from the header (e.g. nc|socat|tcpserver)
#   6. ShellCheck is run on every extension file (same as core)
#
# Usage:
#   ./main.sh compile_extended [output.sh]
#   OPTIMIZE=1 MINIFY=0 ./main.sh compile_extended out.sh
# ==============================================================================
compile_extended() {
    local output_file="${1:-bash-framehead-extended.sh}"
    local ext_base
    ext_base="$(dirname "${BASH_SOURCE[0]}")/ext"

    if [[ ! -d "$ext_base" ]]; then
        echo "Error: ext/ directory not found: $ext_base" >&2
        return 1
    fi

    # -- collect extension directories -----------------------------------------
    local -a ext_names=()
    local ext_dir ext_name ext_file
    for ext_dir in "$ext_base"/*/; do
        [[ -d "$ext_dir" ]] || continue
        ext_name="$(basename "$ext_dir")"
        ext_file="$ext_dir/$ext_name.sh"
        [[ -f "$ext_file" ]] || continue
        ext_names+=("$ext_name")
    done

    if (( ${#ext_names[@]} == 0 )); then
        echo "Error: No extensions found in $ext_base" >&2
        return 1
    fi

    # -- Step 1: compile core to a temp file ----------------------------------
    local core_temp
    core_temp=$(mktemp)
    _COMPILE_SKIP_VERSION=1 compile_files "$core_temp" <<< ""

    # -- Step 2: source core so declare -f works for dep checking -------------
    source "$core_temp"

    # -- Step 3: extract core content (strip shebang + license) ---------------
    local buffer
    local license_lines
    license_lines=$(printf '%s\n' "$LICENSE" | wc -l)
    buffer=$(sed "1,$((1 + license_lines))d" "$core_temp")
    rm -f "$core_temp"

    # -- Step 4: process each extension ---------------------------------------
    local is_strict_mode=false
    [[ "${OPTIMIZE:-0}" == "1" || "${MINIFY:-0}" == "1" ]] && is_strict_mode=true
    local has_shellcheck=false
    command -v shellcheck >/dev/null 2>&1 && has_shellcheck=true

    local total_err=0 total_warn=0 total_info=0
    local ext_count=0

    for ext_name in "${ext_names[@]}"; do
        ext_dir="$ext_base/$ext_name"
        ext_file="$ext_dir/$ext_name.sh"

        echo -n "Processing ext/$ext_name..."

        # ---- ShellCheck ------------------------------------------------------
        local err_file=0 warn_file=0 info_file=0 issue_str_file=""
        if $has_shellcheck; then
            local sc_out
            sc_out=$(shellcheck --format=gcc "$ext_file" 2>/dev/null)
            err_file=$(echo "$sc_out"  | grep -c ': error:')
            warn_file=$(echo "$sc_out" | grep -c ': warning:')
            info_file=$(echo "$sc_out" | grep -c ': note:')

            shellcheck --color=auto --format=tty "$ext_file" 2>/dev/null || true
            echo

            local file_issues=$(( err_file + warn_file + info_file ))
            if (( file_issues > 0 )); then
                issue_str_file=" — $file_issues issues ($err_file errors, $warn_file warnings, $info_file info)"
                (( total_err  += err_file  ))
                (( total_warn += warn_file ))
                (( total_info += info_file ))
            fi

            if $is_strict_mode && (( err_file > 0 )); then
                echo "" >&2
                echo "ERROR: ShellCheck found $err_file error(s) in ext/$ext_name" >&2
                echo "Compilation aborted due to syntax errors in strict mode." >&2
                return 1
            fi
        fi

        # ---- Parse header dependencies --------------------------------------
        local hdr_core="" hdr_ext=""
        local line
        while IFS= read -r line; do
            if [[ "$line" =~ ^#[[:space:]]*core:[[:space:]]+(.*) ]]; then
                hdr_core="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^#[[:space:]]*external:[[:space:]]+(.*) ]]; then
                hdr_ext="${BASH_REMATCH[1]}"
            fi
            [[ "$line" == "# --- guard ---" ]] && break
            [[ "$line" =~ ^[^#] && -n "$line" ]] && break
        done < "$ext_file"

        # Normalise no-dependency sentinels to empty
        [[ "$hdr_core" == "none" || "$hdr_core" == "-" ]] && hdr_core=""
        [[ "$hdr_ext" == "none" || "$hdr_ext" == "-" ]] && hdr_ext=""

        # ---- Parse guard arrays ---------------------------------------------
        local guard_core="" guard_ext=""
        while IFS= read -r line; do
            if [[ "$line" =~ _guard_core_deps=\((.*)\) ]]; then
                guard_core="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ _guard_ext_deps=\((.*)\) ]]; then
                guard_ext="${BASH_REMATCH[1]}"
            fi
        done < "$ext_file"

        # ---- Cross-check header vs guard (external deps) --------------------
        # Build a normalised set from header external (split on | and space)
        local -A _hdr_ext_set=()
        local _tok
        for _tok in ${hdr_ext//|/ }; do
            [[ -n "$_tok" ]] && _hdr_ext_set["$_tok"]=1
        done
        for _tok in $guard_ext; do
            [[ -n "$_tok" ]] && unset '_hdr_ext_set[$_tok]'
        done
        # Anything left in _hdr_ext_set is in the header but not the guard
        local _hdr_only=()
        for _tok in "${!_hdr_ext_set[@]}"; do
            _hdr_only+=("$_tok")
        done
        if (( ${#_hdr_only[@]} > 0 )); then
            echo ""
            echo "  Warning: header lists external deps not in guard: ${_hdr_only[*]}" >&2
            echo "  These will be checked as alternatives (any one must be present)." >&2
        fi
        unset _hdr_ext_set _tok _hdr_only

        # ---- Dependency verification ----------------------------------------
        local dep_fail=0
        local dep

        # Core deps from guard (function-level)
        for dep in $guard_core; do
            if ! declare -f "$dep" &>/dev/null; then
                echo ""
                echo "  ERROR: missing core function '$dep'" >&2
                dep_fail=1
            fi
        done

        # External deps from guard
        for dep in $guard_ext; do
            if ! command -v "$dep" &>/dev/null; then
                echo ""
                echo "  ERROR: missing external tool '$dep'" >&2
                dep_fail=1
            fi
        done

        # External deps from header (handles | alternatives)
        for dep in $hdr_ext; do
            if [[ "$dep" == *"|"* ]]; then
                local _alt _found=0
                local -a _alts
                IFS='|' read -ra _alts <<< "$dep"
                for _alt in "${_alts[@]}"; do
                    command -v "$_alt" &>/dev/null && { _found=1; break; }
                done
                if (( ! _found )); then
                    echo ""
                    echo "  ERROR: requires at least one of: ${dep//|/, }" >&2
                    dep_fail=1
                fi
            else
                if ! command -v "$dep" &>/dev/null; then
                    echo ""
                    echo "  ERROR: missing external tool '$dep'" >&2
                    dep_fail=1
                fi
            fi
        done

        if (( dep_fail )); then
            echo "  Compilation aborted due to missing dependencies." >&2
            return 1
        fi

        # ---- Strip shebang, header, and guard -------------------------------
        local ext_content
        ext_content=$(cat "$ext_file")

        # Strip shebang if present
        if [[ "$ext_content" =~ ^#! ]]; then
            ext_content="${ext_content#*$'\n'}"
        fi

        # Strip from line 1 through "# --- end guard ---"
        ext_content=$(sed '1,/^# --- end guard ---$/d' <<< "$ext_content")

        # ---- Optimize (if enabled) ------------------------------------------
        if [[ "${OPTIMIZE:-0}" == "1" ]]; then
            local optimized
            optimized=$(optimize - <<< "$ext_content")
            if bash -n <<< "$optimized" 2>/dev/null; then
                ext_content="$optimized"
            else
                echo "  Warning: Optimization produced invalid syntax for ext/$ext_name, using original" >&2
            fi
        fi

        # ---- Append ---------------------------------------------------------
        buffer+=$'\n'$'\n'"$ext_content"

        # ---- Append sub-modules (*.sh in ext dir, excluding main/test/bench) -
        local _sub_mod
        for _sub_mod in "$ext_dir"/*.sh; do
            [[ -f "$_sub_mod" ]] || continue
            [[ "$_sub_mod" == "$ext_file" ]] && continue
            [[ "$_sub_mod" == *test_ext.sh || "$_sub_mod" == *benchmark.sh ]] && continue
            local _sub_content
            _sub_content=$(cat "$_sub_mod")
            if [[ "$_sub_content" =~ ^#! ]]; then
                _sub_content="${_sub_content#*$'\n'}"
            fi
            _sub_content=$(sed '1,/^# --- end guard ---$/d' <<< "$_sub_content")
            if [[ "${OPTIMIZE:-0}" == "1" ]]; then
                local _sub_opt
                _sub_opt=$(optimize - <<< "$_sub_content")
                if bash -n <<< "$_sub_opt" 2>/dev/null; then
                    _sub_content="$_sub_opt"
                fi
            fi
            buffer+=$'\n'$'\n'"$_sub_content"
        done

        echo " ok${issue_str_file}"
        (( ext_count++ ))
    done

    # -- Step 5: Minify entire buffer (if enabled) ----------------------------
    if [[ "${MINIFY:-0}" == "1" ]]; then
        echo -n "Minifying entire buffer..."
        local minified
        minified=$(minify - <<< "$buffer")
        if bash -n <<< "$minified" 2>/dev/null; then
            buffer="$minified"
            echo " ok"
        else
            echo "  Warning: Minification produced invalid syntax, using pre-minified version" >&2
        fi
    fi

    # -- Step 6: Wrap with shebang + license, validate, version, write --------
    local final_content="#!/usr/bin/env bash"$'\n'"$LICENSE"$'\n'"$buffer"

    local temp_file="${output_file}.tmp"
    printf '%s\n' "$final_content" > "$temp_file"

    echo -n "Validating final output..."
    if ! bash -n "$temp_file" 2>/dev/null; then
        echo " FAILED" >&2
        echo "Error: Compiled output failed syntax check" >&2
        bash -n "$temp_file" 2>&1 | head -5 >&2
        rm -f "$temp_file"
        return 1
    fi
    echo " ok"

    # Version
    local VERSION
    read -r -t 0.1 -n 10000 _drain 2>/dev/null || true
    read -r -p "Input a version for this file: " VERSION
    VERSION=${VERSION:-"$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")-dev+$(date +%d%m%y).$(date +%S)"}
    sed -i "s/## Version:/## Version: ${VERSION}/" "$temp_file"

    chmod +x "$temp_file" 2>/dev/null
    mv "$temp_file" "$output_file"

    local total_issues=$(( total_err + total_warn + total_info ))
    local final_issue_str=""
    if (( total_issues > 0 )); then
        final_issue_str=" — $total_issues total issues ($total_err errors, $total_warn warnings, $total_info info)"
    fi

    echo "Compiled core + ${ext_count} extension(s) to $output_file${final_issue_str}"
}

# ==============================================================================
# dry_compile — ShellCheck all core modules and extensions without compiling
#
# Passes additional arguments through to shellcheck (e.g. --include, --exclude).
#
# Usage:
#   ./main.sh dry_compile
#   ./main.sh dry_compile --include=SC2034
# ==============================================================================
dry_compile() {
    local shellcheck_args=("$@")
    local src_dir="$(dirname "${BASH_SOURCE[0]}")/src"
    local ext_base="$(dirname "${BASH_SOURCE[0]}")/ext"

    if ! command -v shellcheck >/dev/null 2>&1; then
        echo "Error: shellcheck not found on PATH" >&2
        return 1
    fi

    local -a files=()
    local f
    for f in "$src_dir"/*.sh; do
        [[ -f "$f" ]] && files+=("$f")
    done

    local ext_dir ext_name ext_file
    for ext_dir in "$ext_base"/*/; do
        [[ -d "$ext_dir" ]] || continue
        ext_name="$(basename "$ext_dir")"
        ext_file="$ext_dir/$ext_name.sh"
        [[ -f "$ext_file" ]] && files+=("$ext_file")
    done

    if (( ${#files[@]} == 0 )); then
        echo "Error: No files found" >&2
        return 1
    fi

    echo "=== ShellCheck: ${#files[@]} files ==="
    echo ""

    local total_err=0 total_warn=0 total_info=0
    local failed=0

    for f in "${files[@]}"; do
        local fname="$(basename "$f")"
        local dir_label
        [[ "$f" == "$src_dir"/* ]] && dir_label="src" || dir_label="ext"

        local sc_out
        sc_out=$(shellcheck "${shellcheck_args[@]}" --format=gcc "$f" 2>/dev/null)
        local err_file warn_file info_file
        err_file=$(echo "$sc_out"  | grep -c ': error:')
        warn_file=$(echo "$sc_out" | grep -c ': warning:')
        info_file=$(echo "$sc_out" | grep -c ': note:')

        local issues=$(( err_file + warn_file + info_file ))
        if (( issues > 0 )); then
            printf '%s\n' "$sc_out"
            printf "  %-25s %s  %d issues (%d errors, %d warnings, %d info)\n" \
                "$fname" "$dir_label" "$issues" "$err_file" "$warn_file" "$info_file"
            (( total_err  += err_file  ))
            (( total_warn += warn_file ))
            (( total_info += info_file ))
            (( err_file > 0 )) && (( failed++ ))
        else
            printf "  %-25s %s  clean\n" "$fname" "$dir_label"
        fi
        echo
    done

    local total_issues=$(( total_err + total_warn + total_info ))
    echo "=== $total_issues total issues ($total_err errors, $total_warn warnings, $total_info info) across ${#files[@]} files ==="

    (( failed == 0 ))
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

# ==============================================================================
# ==============================================================================
# TOKENISER
# ==============================================================================
#
# Pure lexer — crawls source characters with lookaheads, emits a flat token
# stream into a caller-supplied associative array.  No transformation, no
# joining, no removal.  Every byte of the original source is represented.
#
# Token types:
#   WORD          bare word: identifiers, keywords, numbers, unquoted globs
#   OP            shell operators: ; ;; ;;& ;& && || | & \ and literal newline
#   REDIRECT      redirection operators: > >> < 2>&1 &> etc  (NOT << or <<<)
#   HEREDOC_HEAD  << <<- or <<< (here-string)
#   HEREDOC_TAG   the marker word immediately following HEREDOC_HEAD
#   HEREDOC_BODY  opaque body — embedded newlines stored as literal \n
#   HEREDOC_TAIL  the closing marker line
#   COMMENT       # through end of line (including the #)
#   STRING_SQ     '...'  fully opaque; val is interior (no surrounding quotes)
#   STRING_DQ     "..."  boundary known; val is interior with \n \t literalised
#   ARITH         $(( )) or (( )) val is interior, literalised
#   CMD_SUB       $( ) val is interior, literalised
#   PROC_SUB      <( ) or >( ) val is interior, literalised (includes direction)
#   PARAM_EXP     ${ }  val is interior (no surrounding delimiters)
#   VAR_LITERAL   $var $1 $# $@ etc — unbraced variable expansions
#
# Storage — flat associative array, two keys per token N:
#   tk[${N}_type]   tk[${N}_val]
# A separate integer holds the token count.
#
# Caller pattern:
#   local -A tokens
#   local token_count=0
#   tokenise "$source" tokens token_count
#
# All helpers are private subfunctions of tokenise().

# ==============================================================================
# tokenise — main entry point
#
# Usage:
#   local -A tokens
#   local token_count=0
#   tokenise "$source" tokens token_count
# ==============================================================================

# ==============================================================================
# STUBS — delegate to tools/
# ==============================================================================

_tools_dir() {
    echo "$(dirname "${BASH_SOURCE[0]}")/tools"
}

minify() {
    bash "$(_tools_dir)/obfuscate.sh" --skip-obfuscator "$@"
}

obfuscate() {
    bash "$(_tools_dir)/obfuscate.sh" "$@"
}

optimize() {
    bash "$(_tools_dir)/optimize.sh" "$@"
}

wiki() {
    bash "$(_tools_dir)/wiki-gen.sh" "$@"
}

# ==============================================================================
# tester — snapshot-based test orchestrator
#
# Usage: tester [compiled.sh] [module ...]
#   Without a compiled file, live-sources src/*.sh directly.
#
# ═══════════════════════════════════════════════════════════════════════
# ⚠  MODEL GUARD — DO NOT ADD DEBUG OUTPUT HERE ⚠
#
#   This function is the orchestrator. It runs in-process with sourced
#   framework code and controls stdout/stderr routing for every test.
#   A stray echo, declare -p, or printf to stderr can hang the whole
#   runner (redirect loops, broken TTY carriage-return formatting, etc.).
#
#   If you need to debug a test failure, add instrumentation INSIDE the
#   test:: function in tools/tester.sh — never here.  The test:: functions
#   are isolated; breaking one leaves the rest of the suite intact.
#
#   The pattern is:
#     ❌  echo "DEBUG: ..." >&2         # NO — in the orchestrator
#     ❌  declare -p VAR >&2 2>&1      # NO — redirect tangle, blocks TTY
#     ✅  _fail "got $x, expected $y"   # YES — inside a test:: function
#     ✅  _sub_fail "label" "$exp" "$got"  # YES — structured, routed
#
#   If you're tempted: don't.  Walk away from the orchestrator and go
#   find the test:: function that's actually failing.
# ═══════════════════════════════════════════════════════════════════════
# ==============================================================================
tester() {
    local file="$1"
    shift
    local -a filter_modules=("$@")
    local filter_active=0
    (( ${#filter_modules[@]} > 0 )) && filter_active=1

    # ── helpers ────────────────────────────────────────────────────────

    # _delta BASELINE TARGET
    # Snapshots declare -F, subtracts BASELINE, filters to namespaced
    # non-private symbols, stores in TARGET (nameref, overwritten).
    _delta() {
        local -n _base="$1"
        local -n _out="$2"
        local -A _bmap=()
        local _fn
        for _fn in "${_base[@]}"; do _bmap["$_fn"]=1; done
        _out=()
        while IFS= read -r _fn; do
            [[ -n "${_bmap[$_fn]:-}" ]] && continue
            [[ $_fn =~ ::       ]] || continue
            [[ $_fn =~ ^_       ]] && continue
            _out+=("$_fn")
        done < <(declare -F | awk '{print $3}')
    }

    # _extract_module "string::upper" → "string"
    # "string::upper" → "string", "test::json::get" → "json"
    _extract_module() {
        local _m="${1%%::*}"
        [[ $_m =~ ^test:: ]] && _m="${_m#test::}"
        echo "$_m"
    }

    # _matches_filter SYMBOL — true if symbol matches any filter term
    _matches_filter() {
        local _sym="$1"
        local _f
        for _f in "${filter_modules[@]}"; do
            [[ "$_sym" == "$_f" || "$_sym" == "$_f"::* ]] && return 0
        done
        return 1
    }

    local passed=0 failed=0 skipped=0 untested=0
    local -a untested_fn
    local -a unrun_tests
    # STATUSSTATUS_COLUMN_WIDTHUMN_WIDTH: width of the PASS/FAIL/SKIP status column for alignment
    local -r STATUSSTATUS_COLUMN_WIDTHUMN_WIDTH=12
    local is_tty=false
    [[ -t 1 ]] && is_tty=true

    # ── Stage A: orchestrator baseline ─────────────────────────────────
    local -a MAIN_FUNC=()
    mapfile -t MAIN_FUNC < <(declare -F | awk '{print $3}')

    # ── Stage B: framework load → CORE_API ─────────────────────────────
    if [[ -n "$file" && -f "$file" ]]; then
        source "$file"
    else
        local _src f
        _src="$(dirname "${BASH_SOURCE[0]}")/src"
        for f in "$_src"/*.sh; do
            [[ -f "$f" ]] || continue
            bash -n "$f" >/dev/null 2>&1 || { echo "ERROR: syntax check failed for $f" >&2; return 1; }
            source "$f"
        done
    fi

    local -a CORE_API=()
    _delta MAIN_FUNC CORE_API

    # ── Stage C: tester load → TEST_SYMBOLS ────────────────────────────
    source "$(_tools_dir)/tester.sh"

    local -a COMBINED=("${MAIN_FUNC[@]}" "${CORE_API[@]}")
    local -a TEST_SYMBOLS=()
    _delta COMBINED TEST_SYMBOLS

    local -a ALL_API=("${CORE_API[@]}")

    # ── apply module filter ────────────────────────────────────────────
    if (( filter_active )); then
        local -a _f_core=()
        local _fn
        for _fn in "${CORE_API[@]}"; do
            _matches_filter "$_fn" && _f_core+=("$_fn")
        done
        CORE_API=("${_f_core[@]}")

        local -a _f_test=()
        for _fn in "${TEST_SYMBOLS[@]}"; do
            _matches_filter "$_fn" && _f_test+=("$_fn")
        done
        TEST_SYMBOLS=("${_f_test[@]}")
    fi

    # ── Stage D: partition — extract extension API from CORE_API ───────
    local -A EXT_PRELOADED=()
    local _ext_test _ext_name _fn
    for _ext_test in ext/*/test_ext.sh; do
        [[ -f "$_ext_test" ]] || continue
        _ext_name="$(basename "$(dirname "$_ext_test")")"
        local -a _matched=()
        for _fn in "${CORE_API[@]}"; do
            [[ "$_fn" == "$_ext_name"::* ]] && _matched+=("$_fn")
        done
        if (( ${#_matched[@]} > 0 )); then
            EXT_PRELOADED["$_ext_name"]="${_matched[*]}"
            local -a _keep=()
            for _fn in "${CORE_API[@]}"; do
                [[ "$_fn" != "$_ext_name"::* ]] && _keep+=("$_fn")
            done
            CORE_API=("${_keep[@]}")
        fi
    done

    # Build lookup for quick test::fn existence checks
    local -A _test_map=()
    for _fn in "${TEST_SYMBOLS[@]}"; do
        [[ $_fn =~ ^test:: ]] && _test_map["$_fn"]=1
    done

    # ── test runner ────────────────────────────────────────────────────
    _run_one_test() {
        local _ts="$1"    # test symbol to call
        local _dn="$2"    # display name
        local _raw _disp _pad
        _tester_reset
        "$_ts" </dev/null
        if   (( _T_IS_SUB  )); then _raw="SUB"
        elif (( _T_FAIL > 0 )); then _raw="FAIL"
        elif (( _T_SKIP > 0 )); then _raw="SKIP"
        elif (( _T_PASS > 0 )); then _raw="PASS"
        else                       _raw="UNTESTED"
        fi

        if $is_tty; then
            case $_raw in
                SUB)      _disp=$'\033[94mSUB\033[0m'      ;;
                FAIL)     _disp=$'\033[31mFAIL\033[0m'     ;;
                SKIP)     _disp=$'\033[33mSKIP\033[0m'     ;;
                PASS)     _disp=$'\033[32mPASS\033[0m'     ;;
                UNTESTED) _disp=$'\033[43mUNTESTED\033[0m' ;;
            esac
        else
            _disp="$_raw"
        fi

        if (( _T_IS_SUB )); then
            printf "%s%$(( STATUS_COLUMN_WIDTH - ${#_raw} ))s%s\n" "$_disp" "" "$_dn"
        elif $is_tty; then
            printf "%${STATUS_COLUMN_WIDTH}s%s" "" "$_dn"
            _pad=$(( STATUS_COLUMN_WIDTH - ${#_raw} ))
            printf "\r%s%${_pad}s%s\n" "$_disp" "" "$_dn"
        else
            printf "%s%$(( STATUS_COLUMN_WIDTH - ${#_raw} ))s%s\n" "$_disp" "" "$_dn"
        fi

        case $_raw in
            PASS)     (( passed++   )) ;;
            FAIL)     (( failed++   )) ;;
            SKIP)     (( skipped++  )) ;;
            UNTESTED) (( untested++ )); untested_fn+=("$_dn") ;;
            SUB)
                (( passed  += _T_PASS ))
                (( failed  += _T_FAIL ))
                (( skipped += _T_SKIP ))
                ;;
        esac
    }

    # ── Stage E: core execution (guard: skip if empty) ────────────────
    if (( ${#CORE_API[@]} > 0 )); then
        local _prev_mod="" _mod _gts
        for _fn in "${CORE_API[@]}"; do
            _mod="$(_extract_module "$_fn")"
            if [[ "$_mod" != "$_prev_mod" ]]; then
                _prev_mod="$_mod"
                _gts="test::${_mod}::global"
                if [[ -n "${_test_map[$_gts]:-}" ]]; then
                    _run_one_test "$_gts" "${_mod}::global"
                fi
            fi
            if [[ -n "${_test_map["test::${_fn}"]:-}" ]]; then
                _run_one_test "test::${_fn}" "$_fn"
            else
                (( untested++ ))
                untested_fn+=("$_fn")
            fi
        done
        echo ""
    fi

    # ── Stage F: extension pass ────────────────────────────────────────
    local _ext_test _ext_dir _ext_name _ext_mod
    local -a EXT_ALL_TESTS=()
    for _ext_test in ext/*/test_ext.sh; do
        [[ -f "$_ext_test" ]] || continue
        _ext_dir="$(dirname "$_ext_test")"
        _ext_name="$(basename "$_ext_dir")"
        _ext_mod="$_ext_dir/$_ext_name.sh"

        # filter check
        if (( filter_active )); then
            local _match=0
            local _f
            for _f in "${filter_modules[@]}"; do
                [[ "$_ext_name" == "$_f" ]] && { _match=1; break; }
            done
            (( _match )) || continue
        fi

        [[ -f "$_ext_mod" ]] || { echo "WARNING: $_ext_test exists but $_ext_mod not found — skipping" >&2; continue; }

        local -a EXT_API=()
        local -a EXT_TESTS=()
        local -a SNAP_PRE=()

        if [[ -n "${EXT_PRELOADED[$_ext_name]:-}" ]]; then
            # Extension API already loaded (compiled target included it)
            read -ra EXT_API <<< "${EXT_PRELOADED[$_ext_name]}"
            mapfile -t SNAP_PRE < <(declare -F | awk '{print $3}')
            source "$_ext_test"
            local -a EXT_NEW=()
            _delta SNAP_PRE EXT_NEW
            for _fn in "${EXT_NEW[@]}"; do
                [[ $_fn =~ ^test:: ]] && EXT_TESTS+=("$_fn")
            done
        else
            # Live-source the extension
            if ! source "$_ext_mod" >/dev/null 2>&1; then
                echo "--- ext/$_ext_name ---"
                echo "  skip: extension failed to load"
                echo ""
                continue
            fi
            # Collect extension API functions before loading tests
            while IFS= read -r _fn; do
                [[ "$_fn" =~ ^${_ext_name}:: ]] || continue
                [[ "$_fn" =~ ^_ ]] && continue
                EXT_API+=("$_fn")
            done < <(declare -F | awk '{print $3}')
            mapfile -t SNAP_PRE < <(declare -F | awk '{print $3}')
            source "$_ext_test"
            local -a EXT_NEW=()
            _delta SNAP_PRE EXT_NEW
            for _fn in "${EXT_NEW[@]}"; do
                if [[ $_fn =~ ^test:: ]]; then
                    EXT_TESTS+=("$_fn")
                else
                    EXT_API+=("$_fn")
                fi
            done
        fi

        # Accumulate into global symbol tables
        ALL_API+=("${EXT_API[@]}")
        EXT_ALL_TESTS+=("${EXT_TESTS[@]}")
        for _fn in "${EXT_TESTS[@]}"; do
            _test_map["$_fn"]=1
        done

        (( ${#EXT_API[@]} == 0 && ${#EXT_TESTS[@]} == 0 )) && continue

        echo "--- ext/$_ext_name ---"

        # Extension globals + per-function (same module-transition pattern)
        local -A _global_ran=()
        if (( ${#EXT_API[@]} > 0 )); then
            local _prev_mod="" _mod _gts
            for _fn in "${EXT_API[@]}"; do
                _mod="$(_extract_module "$_fn")"
                if [[ "$_mod" != "$_prev_mod" ]]; then
                    _prev_mod="$_mod"
                    _gts="test::${_mod}::global"
                    if [[ -n "${_test_map[$_gts]:-}" ]]; then
                        _run_one_test "$_gts" "${_mod}::global"
                        _global_ran["$_gts"]=1
                    fi
                fi
                if [[ -n "${_test_map["test::${_fn}"]:-}" ]]; then
                    _run_one_test "test::${_fn}" "$_fn"
                else
                    (( untested++ ))
                    untested_fn+=("$_fn")
                fi
            done
        fi

        # Run remaining extension globals that had no API functions
        for _fn in "${EXT_TESTS[@]}"; do
            [[ $_fn =~ ::global$ ]] || continue
            [[ -n "${_global_ran[$_fn]:-}" ]] && continue
            _run_one_test "$_fn" "${_fn#test::}"
        done

        echo ""
    done
    # ── end extensions ─────────────────────────────────────────────────

    # ── Stage G: reports ───────────────────────────────────────────────

    # UNRUN TESTS: test::* symbols whose stripped fn ∉ ALL_API
    local -A _all_api_map=()
    for _fn in "${ALL_API[@]}"; do _all_api_map["$_fn"]=1; done

    for _fn in "${TEST_SYMBOLS[@]}"; do
        [[ $_fn =~ ^test:: ]] || continue
        [[ $_fn =~ ::global$ ]] && continue
        local _bare="${_fn#test::}"
        [[ -n "${_all_api_map[$_bare]:-}" ]] && continue
        unrun_tests+=("$_fn")
    done

    # Accumulate extension test symbols into UNRUN check too
    for _fn in "${EXT_ALL_TESTS[@]}"; do
        [[ $_fn =~ ::global$ ]] && continue
        local _bare="${_fn#test::}"
        [[ -n "${_all_api_map[$_bare]:-}" ]] && continue
        # Avoid duplicates
        local _dup=0 _u
        for _u in "${unrun_tests[@]}"; do
            [[ "$_u" == "$_fn" ]] && { _dup=1; break; }
        done
        (( _dup )) || unrun_tests+=("$_fn")
    done

    # Deduplicate untested_fn array before reporting
    if (( ${#untested_fn[@]} > 0 )); then
        local -A _untested_map=()
        local -a _untested_unique=()
        for _fn in "${untested_fn[@]}"; do
            [[ -n "${_untested_map[$_fn]:-}" ]] && continue
            _untested_map["$_fn"]=1
            _untested_unique+=("$_fn")
        done
        untested_fn=("${_untested_unique[@]}")
        untested=${#untested_fn[@]}
    fi

    if (( untested > 0 )); then
        echo "=== UNTESTED FUNCTIONS ==="
        for _fn in "${untested_fn[@]}"; do
            printf "  %s\n" "$_fn"
        done
        echo ""
    fi

    if (( ${#unrun_tests[@]} > 0 )); then
        echo "=== UNRUN TESTS ==="
        for _fn in "${unrun_tests[@]}"; do
            printf "  %s\n" "$_fn"
        done
        echo ""
    fi

    local total=$(( passed + failed + skipped + untested ))
    echo "=== Results: ${passed} passed, ${failed} failed, ${skipped} skipped, ${untested} untested / ${total} total ==="

    if (( total == 0 )); then
        echo "WARNING: No tests seem to be run. Make sure your module is written correctly, including cases."
    fi

    (( failed == 0 ))
}

# --- compile_bare -----------------------------------------------------------
# Usage: compile_bare <pattern> [output.sh]
#
# Reduces a compiled script to only the functions reachable from <pattern>
# via a fixed-point call-graph discovery loop.
#
#   compile_bare "json::" out.sh
#
#  1. Load all function definitions AND global variables from src/ and ext/.
#  2. Seed candidates by matching function names against <pattern>.
#  3. Iterate: scan candidate bodies for module::function calls AND
#     global-variable references, adding any found that aren't already
#     a candidate.
#  4. Stop when the candidate set stops growing.
#  5. Emit global vars first, then functions in dependency order.
compile_bare() {
    local _pattern="${1:-}"
    local _output="${2:-bare.sh}"

    [[ -n "$_pattern" ]] || { echo "Usage: compile_bare <pattern> [output.sh]" >&2; return 1; }

    local _src_dir="$(dirname "${BASH_SOURCE[0]}")/src"
    local _ext_dir="$(dirname "${BASH_SOURCE[0]}")/ext"

    # --- helpers ---
    _cb_in_array() {
        local _needle="$1"; shift
        local _e
        for _e in "$@"; do [[ "$_e" == "$_needle" ]] && return 0; done
        return 1
    }

    # --- Step 1: load all functions AND global variables ---
    local -A _cb_fn_body=()
    local -A _cb_fn_file=()
    local -A _cb_global_var=()   # var_name → declaration line
    local -a _cb_files=()

    local _cb_f
    while IFS= read -r -d '' _cb_f; do
        _cb_files+=("$_cb_f")
        local _cb_in_fn=false _cb_fn_name="" _cb_fn_body=""
        local _cb_line
        while IFS= read -r _cb_line; do
            # Detect function start: module::name() {
            if [[ "$_cb_line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)::([a-zA-Z_][a-zA-Z0-9_:]*)\(\) ]]; then
                _cb_in_fn=true
                _cb_fn_name="${BASH_REMATCH[1]}::${BASH_REMATCH[2]}"
                _cb_fn_body="$_cb_line"$'\n'
            elif $_cb_in_fn; then
                _cb_fn_body+="$_cb_line"$'\n'
                if [[ "$_cb_line" == '}' ]]; then
                    _cb_fn_body["$_cb_fn_name"]="$_cb_fn_body"
                    _cb_fn_file["$_cb_fn_name"]="$_cb_f"
                    _cb_in_fn=false
                fi
            else
                # Top-level: capture global variable declarations
                # declare, readonly, or bare VAR=value assignments
                if [[ "$_cb_line" =~ ^(declare\s|readonly\s|export\s) ]] || \
                   [[ "$_cb_line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)= ]] || \
                   [[ "$_cb_line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)\[\".*\"\] ]]; then
                    local _cb_global_name="${BASH_REMATCH[1]}"
                    _cb_global_name="${_cb_global_name%%=*}"
                    _cb_global_name="${_cb_global_name%%[*}"
                    _cb_global_name="${_cb_global_name#[[:space:]]}"
                    # Strip leading keyword
                    _cb_global_name="${_cb_global_name#declare }"
                    _cb_global_name="${_cb_global_name#readonly }"
                    _cb_global_name="${_cb_global_name#export }"
                    _cb_global_name="${_cb_global_name#-a }"
                    _cb_global_name="${_cb_global_name#-A }"
                    _cb_global_name="${_cb_global_name#-i }"
                    _cb_global_name="${_cb_global_name## }"
                    if [[ -n "$_cb_global_name" ]] && [[ -z "${_cb_global_var[$_cb_global_name]:-}" ]]; then
                        # Convert readonly → plain assignment for standalone reuse
                        local _cb_gv_line="$_cb_line"
                        _cb_gv_line="${_cb_gv_line#readonly }"
                        _cb_gv_line="${_cb_gv_line#export }"
                        # Only keep if it's an assignment (not just "declare name")
                        if [[ "$_cb_gv_line" =~ = ]]; then
                            _cb_global_var["$_cb_global_name"]="$_cb_gv_line"
                        fi
                    fi
                fi
            fi
        done < "$_cb_f"
    done < <(find "$_src_dir" "$_ext_dir" -name '*.sh' -print0 2>/dev/null | sort -z)

    echo "Loaded ${#_cb_fn_body[@]} functions + ${#_cb_global_var[@]} globals from ${#_cb_files[@]} files." >&2

    # --- Step 2: seed candidates from pattern ---
    local -a _cb_candidates=()
    local _cb_name
    for _cb_name in "${!_cb_fn_body[@]}"; do
        # bash glob-style pattern match
        local _match=false
        case "$_cb_name" in
            $_pattern) _match=true ;;
        esac
        if $_match; then
            _cb_candidates+=("$_cb_name")
        fi
    done

    if (( ${#_cb_candidates[@]} == 0 )); then
        echo "compile_bare: no functions matched pattern '$_pattern'" >&2
        return 1
    fi

    echo "Seed: ${#_cb_candidates[@]} functions matched '$_pattern' (${#_cb_global_var[@]} globals loaded)" >&2

    # --- Step 3/4: fixed-point call-graph discovery ---
    local _cb_round=0 _cb_any_new=true
    while $_cb_any_new; do
        (( _cb_round++ ))
        _cb_any_new=false
        # Snapshot current candidates for this round
        local -a _cb_snapshot=("${_cb_candidates[@]}")

        for _cb_name in "${_cb_snapshot[@]}"; do
            local _cb_body="${_cb_fn_body[$_cb_name]:-}"
            [[ -z "$_cb_body" ]] && continue

            # Find all module::function calls in the body
            local _cb_dep
            while IFS= read -r _cb_dep; do
                if [[ -n "${_cb_fn_body[$_cb_dep]:-}" ]] && ! _cb_in_array "$_cb_dep" "${_cb_candidates[@]}"; then
                    _cb_candidates+=("$_cb_dep")
                    _cb_any_new=true
                fi
            done < <(echo "$_cb_body" | grep -oE '\b[a-zA-Z_][a-zA-Z0-9_]*::[a-zA-Z_][a-zA-Z0-9_:]*' | sort -u)

            # Also scan for references to known global variables
            if (( ${#_cb_global_var[@]} > 0 )); then
                local _cb_gv
                for _cb_gv in "${!_cb_global_var[@]}"; do
                    # Skip very short names (too many false positives: $1, $a, etc.)
                    [[ ${#_cb_gv} -le 2 ]] && continue
                    # Check if body references this global: ${VAR}, $VAR, or bare VAR
                    if [[ "$_cb_body" = *'${'_cb_gv'}'* ]] || \
                       [[ "$_cb_body" = *'${'_cb_gv':'* ]] || \
                       [[ "$_cb_body" = *'${'_cb_gv'['* ]] || \
                       [[ "$_cb_body" = *'$'_cb_gv* ]] || \
                       [[ "$_cb_body" =~ (^|[^a-zA-Z0-9_])${_cb_gv}([^a-zA-Z0-9_]|$) ]]; then
                        if ! _cb_in_array "_cb_global_var:$_cb_gv" "${_cb_candidates[@]}"; then
                            _cb_candidates+=("_cb_global_var:$_cb_gv")
                            _cb_any_new=true
                        fi
                    fi
                done
            fi
        done
    done

    echo "Round $_cb_round: ${#_cb_candidates[@]} total functions (dependencies resolved)" >&2

    # --- Step 5: emit globals first, then functions in dependency order ---
    local -A _cb_emitted=()
    {
        echo '#!/usr/bin/env bash'
        echo "# Generated by compile_bare '$1'"
        echo "# $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
        echo "# ${#_cb_candidates[@]} total (functions + globals)"

        # Emit discovered global variables first
        local _cb_cand
        for _cb_cand in "${_cb_candidates[@]}"; do
            if [[ "$_cb_cand" == _cb_global_var:* ]]; then
                local _cb_gv_name="${_cb_cand#_cb_global_var:}"
                if [[ -z "${_cb_emitted[$_cb_cand]:-}" ]] && [[ -n "${_cb_global_var[$_cb_gv_name]:-}" ]]; then
                    _cb_emitted["$_cb_cand"]=1
                    echo "${_cb_global_var[$_cb_gv_name]}"
                fi
            fi
        done

        # Then emit functions: runtime.sh deps first, then src/, then ext/
        local _cb_pass _cb_fn _cb_file
        for _cb_pass in runtime src ext; do
            for _cb_cand in "${_cb_candidates[@]}"; do
                [[ "$_cb_cand" == _cb_global_var:* ]] && continue
                _cb_fn="$_cb_cand"
                _cb_file="${_cb_fn_file[$_cb_fn]:-}"
                if [[ -n "${_cb_emitted[$_cb_fn]:-}" ]]; then
                    continue
                fi
                _cb_emitted["$_cb_fn"]=1
                echo "${_cb_fn_body[$_cb_fn]}"
            done
        done
    } > "$_output"

    echo "Wrote $_output (${#_cb_candidates[@]} total: functions + globals)" >&2
}

if [[ ${1,,} == "compile" ]]; then
    compile_files "${2:-compiled.sh}"
    exit $?
fi

if [[ ${1,,} == "compile_bare" ]]; then
    compile_bare "${@:2}"
    exit $?
fi

if [[ ${1,,} == "compile_extended" ]]; then
    compile_extended "${2:-bash-framehead-extended.sh}"
    exit $?
fi

if [[ ${1,,} == "dry_compile" ]]; then
    dry_compile "${@:2}"
    exit $?
fi

if [[ ${1,,} == "obfuscate" ]]; then
    obfuscate "$2" "$3"
    exit $?
fi

if [[ ${1,,} == "wiki" ]]; then
    wiki "$2" "$3"
    exit $?
fi

if [[ ${1,,} == "help" ]] || [[ -z "$1" ]]; then
    echo "Usage: ./main.sh <command> [args]"
    echo ""
    echo "  compile          [output.sh]         Compile src/ modules into a single file"
    echo "  compile_bare     <pattern> [output]  Compile only functions reachable from pattern"
    echo "  compile_extended [output.sh]         Compile src/ + all ext/ with dep checks"
    echo "  dry_compile      [shellcheck-args]    ShellCheck all modules and extensions"
    echo "  test             [compiled.sh]        Run the test suite (live-source from src/ if omitted)"
    echo "  stat             <compiled.sh>        Show diagnostics and function counts"
    echo "  profile          <compiled.sh>        Profile per-function load times"
    echo "  optimize         <input> [output]     Optimize a compiled file  (tools/optimize.sh)"
    echo "  minify           <input> [output]     Minify a compiled file    (tools/obfuscate.sh)"
    echo "  obfuscate        <input> [output]     Obfuscate a compiled file (tools/obfuscate.sh)"
    echo "  wiki             <compiled> <dir>     Generate wiki documentation"
    exit 0
fi

if [[ ${1,,} == "test" ]]; then
    tester "${@:2}"
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

if [[ ${1,,} == "optimize" ]]; then
    optimize_file "$2" "$3"
    exit $?
fi

if [[ ${1,,} == "minify" ]]; then
    minify "$2" "$3"
    exit $?
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