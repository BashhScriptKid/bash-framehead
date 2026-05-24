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

tester() {
    local file="$1"
    shift
    local -a filter_modules=("$@")
    local filter_active=0
    (( ${#filter_modules[@]} > 0 )) && filter_active=1

    # Helper: extract module name from a namespaced function name
    # "string::upper" → "string", "test::json::get" → "json"
    _extract_module() {
        local fn="$1"
        [[ $fn =~ ^test:: ]] && fn="${fn#test::}"
        echo "${fn%%::*}"
    }

    local passed=0 failed=0 skipped=0 untested=0
    local -a untested_fn

    source "$file"
    source "$(_tools_dir)/tester.sh"

    local -a TESTER_FUNCTIONS
    mapfile -t TESTER_FUNCTIONS < <(
        declare -F | awk '$3 ~ /::/ && $3 !~ /^_/ {print $3}'
    )

    # Save an unfiltered snapshot so the extension pass can skip already-seen
    # core functions even when the filter excludes them from the core run.
    local -a _ALL_FUNCTIONS=("${TESTER_FUNCTIONS[@]}")

    # Filter to specified modules when ./main.sh test <file> [module ...]
    if (( filter_active )); then
        local -a _filtered=()
        local _mod
        for fn in "${TESTER_FUNCTIONS[@]}"; do
            _mod="$(_extract_module "$fn")"
            for _f in "${filter_modules[@]}"; do
                [[ "$_mod" == "$_f" ]] && { _filtered+=("$fn"); break; }
            done
        done
        TESTER_FUNCTIONS=("${_filtered[@]}")
        unset _filtered _mod _f
    fi

    # Result label column width — wide enough for 'UNTESTED' (8) + 4 spaces gap
    local -r _COL=12
    local fn raw_label display_label
    local is_tty=false
    [[ -t 1 ]] && is_tty=true

    for fn in "${TESTER_FUNCTIONS[@]}"; do
        # Skip test:: wrappers except ::global — those run inline below
        [[ $fn =~ ^test:: ]] && [[ ! $fn =~ ::global$ ]] && continue
        _tester_reset

        if [[ $fn =~ ::global$ ]]; then
            "$fn" </dev/null       # already prefixed: test::json::global
        else
            "test::${fn}" </dev/null
        fi

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

    # ── extensions ────────────────────────────────────────────────────
    local ext_dir ext_name ext_mod ext_test
    local -A _seen_fn
    for fn in "${_ALL_FUNCTIONS[@]}"; do _seen_fn["$fn"]=1; done

    for ext_test in ext/*/test_ext.sh; do
        [[ -f "$ext_test" ]] || continue
        ext_dir="$(dirname "$ext_test")"
        ext_name="$(basename "$ext_dir")"

        # Skip extensions not in the module filter list
        if (( filter_active )); then
            local _match=0
            for _f in "${filter_modules[@]}"; do
                [[ "$ext_name" == "$_f" ]] && { _match=1; break; }
            done
            (( _match )) || continue
        fi

        ext_mod="$ext_dir/$ext_name.sh"

        [[ -f "$ext_mod" ]] || { echo "WARNING: $ext_test exists but $ext_mod not found — skipping" >&2; continue; }

        source "$ext_mod"
        source "$ext_test"

        # Discover extension test functions that weren't in the core pass
        local -a EXT_FUNCTIONS=()
        while IFS= read -r fn; do
            [[ -n "${_seen_fn[$fn]:-}" ]] && continue
            [[ $fn =~ :: ]] || continue
            EXT_FUNCTIONS+=("$fn")
            _seen_fn["$fn"]=1
        done < <(declare -F | awk '$3 ~ /::/ && $3 !~ /^_/ {print $3}')

        (( ${#EXT_FUNCTIONS[@]} == 0 )) && continue

        echo "--- ext/$ext_name ---"

        for fn in "${EXT_FUNCTIONS[@]}"; do
            [[ $fn =~ ^test:: ]] && [[ ! $fn =~ ::global$ ]] && continue
            _tester_reset

            if [[ $fn =~ ::global$ ]]; then
                "$fn" </dev/null
            else
                "test::${fn}" </dev/null
            fi

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
                printf "%s%$(( _COL - ${#raw_label} ))s%s\n" "$display_label" "" "$fn"
            elif $is_tty; then
                printf "%${_COL}s%s" "" "$fn"
                local pad=$(( _COL - ${#raw_label} ))
                printf "\r%s%${pad}s%s\n" "$display_label" "" "$fn"
            else
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
    done
    # ── end extensions ───────────────────────────────────────────────

    if (( untested > 0 )); then
        echo "=== UNTESTED FUNCTIONS ==="
        for fn in "${untested_fn[@]}"; do
            printf "  %s\n" "$fn"
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

if [[ ${1,,} == "compile" ]]; then
    compile_files "${2:-compiled.sh}"
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
    echo "  compile_extended [output.sh]         Compile src/ + all ext/ with dep checks"
    echo "  dry_compile      [shellcheck-args]    ShellCheck all modules and extensions"
    echo "  test             <compiled.sh>        Run the test suite"
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
