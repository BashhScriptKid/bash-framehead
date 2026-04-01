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

# Pipeline logging controls (shared by tokeniser + minifier)
# _pipeline_log_mode: unset = progress (default when MINIFY=1), "verbose" = verbose, "quiet" = quiet
# Set via env MINIFY_LOG or MINIFY_LOG_MODE for backwards-compat
_pipeline_log_mode="${MINIFY_LOG_MODE:-${MINIFY_LOG:-}}"
if [[ -z "$_pipeline_log_mode" && "${MINIFY:-0}" == "1" ]]; then
    _pipeline_log_mode="progress"
fi

# Shared log queue + helpers for dynamic progress output
LOG_QUEUE=()
pipeline_verbose() {
    [[ "$_pipeline_log_mode" == verbose ]] || return 0
    LOG_QUEUE+=("$1")
}

# Strip ANSI CSI sequences to keep logs readable
sanitize_ansi() {
    # Replace ESC byte or literal \e with <ESC>, leave following text intact for readability
    sed -e $'s/\x1B/<ESC>/g' \
        -e $'s/\\e/<ESC>/g'
}

pipeline_flush() {
    local label="$1"
    if [[ "$_pipeline_log_mode" == progress || "$_pipeline_log_mode" == verbose ]]; then
        if [[ ${#LOG_QUEUE[@]} -gt 0 ]]; then
            printf '%s\n%s\r' "$(printf '%s\n' "${LOG_QUEUE[@]}")" "$label" >&2
        else
            printf '%s\r' "$label" >&2
        fi
        LOG_QUEUE=()
    fi
}

pipeline_flush_final() {
    [[ "$_pipeline_log_mode" == progress || "$_pipeline_log_mode" == verbose ]] && echo >&2
}
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
            optimized=$(optimize_function "$content")
            # Validate optimization output
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
        minified=$(minify "$buffer")
        # Validate minified output
        if ! bash -n <<< "$minified" 2>/dev/null; then
            echo "Warning: Minification produced invalid syntax, using pre-minified version" >&2
            bash -n <<< "$minified" 2>&1 | head -3 >&2
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
    local VERSION
    read -r -t 0.1 -n 10000 _drain 2>/dev/null || true
    read -r -p "Input a version for this file: " VERSION
    VERSION=${VERSION:-"$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")-dev+$(date +%d%m%y).$(date +%S)"}
    sed -i "s/## Version:/## Version: ${VERSION}/" "$temp_file"

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
tokenise() {
    local input="$1"
    local -n _tk="$2"
    local -n _tc="$3"
    _tc=0

    # Local state variables
    local _src="" _pos=0 _li=0
    local _pending_heredoc=false _pending_marker="" _pending_has_dash=false
    local _sq_open=0  # set when _sq returned 94 (multi-line string in progress)
    local _dq_open=0  # set when _dq returned 94 (multi-line double-quoted string in progress)
    local -a _dq_stack=()  # quote stack, preserved across _dq line continuations
    local _dq_cmd_depth=0  # $( nesting depth inside _dq — suppresses quote stack while > 0
    local _case_state=OFF _case_depth=0  # case pattern consumption state
    local -a _lines=()

    # --------------------------------------------------------------------------
    # _emit — append one token
    # --------------------------------------------------------------------------
    _emit() {
        _tk[${_tc}_type]="$1"
        _tk[${_tc}_val]="$2"
        (( _tc++ ))
    }

    # --------------------------------------------------------------------------
    # _lit — replace control characters with escape sequences for storage
    # --------------------------------------------------------------------------
    _lit() {
        local s="$1"
        s="${s//\\/\\\\}"
        s="${s//$'\n'/\\n}"
        s="${s//$'\t'/\\t}"
        printf '%s' "$s"
    }

    # --------------------------------------------------------------------------
    # _sq — consume '...' starting at _pos; emits STRING_SQ
    # Returns 94 when EOL is reached without finding closing ' (multi-line string).
    # Caller must append subsequent lines to the last token val until closed.
    # --------------------------------------------------------------------------
    _sq() {
        local i=$(( _pos + 1 ))
        while (( i < ${#_src} )); do
            [[ "${_src:i:1}" == "'" ]] && {
                _emit STRING_SQ "${_src:_pos+1:i-_pos-1}"
                _pos=$(( i + 1 ))
                return 0
            }
            (( i++ ))
        done
        # EOL without closing ' — emit partial, signal continuation
        _emit STRING_SQ "${_src:_pos+1}"
        _pos=${#_src}
        return 94
    }

    # --------------------------------------------------------------------------
    # _dq — consume "..." starting at _pos; emits STRING_DQ (interior lit'd)
    # Returns 94 when EOL is reached without closing " (multi-line string).
    # Uses closure-level _dq_stack to track nested quote contexts across lines.
    # Stack entries are the closing character: " or `
    # Single-quotes are inert inside "..." — never pushed.
    # --------------------------------------------------------------------------
    _dq() {
        # QUOTE_PAT: characters that open a new quote context inside "..."
        # Only " and ` are valid openers — ' is inert inside double-quotes
        local QUOTE_PAT='^(["`])$'
        local i=$(( _pos + 1 ))
        # Push root " onto stack if starting fresh (not continuing a multi-line)
        (( ${#_dq_stack[@]} == 0 )) && _dq_stack+=('"')
        while (( i < ${#_src} )); do
            local c="${_src:i:1}"
            # Backslash escape — skip 2 chars (only meaningful outside subshell)
            if [[ "$c" == '\' ]] && (( _dq_cmd_depth == 0 )); then
                (( i += 2 ))
                continue
            fi
            # Track $( subshell depth — suppresses quote stack while inside
            if [[ "$c" == '$' && "${_src:i+1:1}" == '(' ]]; then
                (( _dq_cmd_depth++ ))
                (( i += 2 ))
                continue
            fi
            if (( _dq_cmd_depth > 0 )); then
                [[ "$c" == '(' ]] && (( _dq_cmd_depth++ ))
                [[ "$c" == ')' ]] && (( _dq_cmd_depth-- ))
                (( i++ ))
                continue
            fi
            # Try pop: does c close the current context?
            if [[ "$c" == "${_dq_stack[-1]}" ]]; then
                unset '_dq_stack[-1]'
                # Stack empty — closed the root "
                if (( ${#_dq_stack[@]} == 0 )); then
                    _emit STRING_DQ "$(_lit "${_src:_pos+1:i-_pos-1}")"
                    _pos=$(( i + 1 ))
                    return 0
                fi
                (( i++ ))
                continue
            fi
            # Try push: does c open a new context?
            if [[ "$c" =~ $QUOTE_PAT ]]; then
                _dq_stack+=("${BASH_REMATCH[1]}")
                (( i++ ))
                continue
            fi
            (( i++ ))
        done
        # EOL without closing " — emit partial, signal continuation
        _emit STRING_DQ "$(_lit "${_src:_pos+1}")"
        _pos=${#_src}
        return 94
    }

    # --------------------------------------------------------------------------
    # _arith — consume $(( )) starting at _pos; emits ARITH (interior lit'd)
    # --------------------------------------------------------------------------
    _arith() {
        local i=$(( _pos + 3 )) depth=1
        while (( i < ${#_src} && depth > 0 )); do
            local two="${_src:i:2}"
            if   [[ "$two" == '((' ]]; then (( depth++ )); (( i += 2 ))
            elif [[ "$two" == '))' ]]; then
                (( depth-- ))
                (( depth == 0 )) && { (( i += 2 )); break; }  # Skip past )) then break
                (( i += 2 ))
            else (( i++ ))
            fi
        done
        # Capture interior: from after $(( to before ))
        _emit ARITH "$(_lit "${_src:_pos+3:i-_pos-5}")"
        _pos=$i  # _pos is now at position after ))
    }

    # --------------------------------------------------------------------------
    # _arith_stmt — arithmetic (( )) at statement level; emits ARITH
    # --------------------------------------------------------------------------
    _arith_stmt() {
        local i=$(( _pos + 2 )) depth=1
        while (( i < ${#_src} && depth > 0 )); do
            local two="${_src:i:2}"
            if   [[ "$two" == '((' ]]; then (( depth++ )); (( i += 2 ))
            elif [[ "$two" == '))' ]]; then
                (( depth-- ))
                (( depth == 0 )) && break
                (( i += 2 ))
            else (( i++ ))
            fi
        done
        _emit ARITH "$(_lit "${_src:_pos+2:i-_pos-2}")"
        _pos=$(( i + 2 ))
    }

    # --------------------------------------------------------------------------
    # _cmdsub — consume $( ) starting at _pos; emits CMD_SUB
    # Handles multi-line command substitutions by pulling additional lines from
    # _lines/_li when the closing ) is not found on the current line.
    # Tracks single-quote state so ) inside 'awk scripts' is not mistaken for close.
    # --------------------------------------------------------------------------
    _cmdsub() {
        local depth=1 in_sq=0
        local body="" start_src="$_src" start_pos=$(( _pos + 2 ))
        local ci=$start_pos

        while true; do
            while (( ci < ${#_src} )); do
                local c="${_src:ci:1}"

                if [[ "$c" == "'" && "$in_sq" -eq 0 ]]; then
                    in_sq=1; (( ci++ )); continue
                fi
                if [[ "$c" == "'" && "$in_sq" -eq 1 ]]; then
                    in_sq=0; (( ci++ )); continue
                fi

                if [[ "$in_sq" -eq 0 ]]; then
                    if   [[ "$c" == '(' ]]; then (( depth++ ))
                    elif [[ "$c" == ')' ]]; then
                        (( depth-- ))
                        if (( depth == 0 )); then
                            body+="${_src:start_pos:ci-start_pos}"
                            _emit CMD_SUB "$(_lit "$body")"
                            _pos=$(( ci + 1 ))
                            return 0
                        fi
                    fi
                fi
                (( ci++ ))
            done

            # EOL without close — accumulate this line and pull the next
            if (( _li >= ${#_lines[@]} )); then break; fi
            body+="${_src:start_pos}"$'\n'
            _src="${_lines[_li]}"
            (( _li++ ))
            start_pos=0
            ci=0
        done

        # Unterminated — emit what we have
        body+="${_src:start_pos}"
        _emit CMD_SUB "$(_lit "$body")"
        _pos=${#_src}
        return 94
    }

    # --------------------------------------------------------------------------
    # _cmdsub_ps — process substitution <( ) or >( ); emits PROC_SUB
    # --------------------------------------------------------------------------
    _cmdsub_ps() {
        local dir="$1"
        local i=$(( _pos + 2 )) depth=1
        while (( i < ${#_src} && depth > 0 )); do
            local c="${_src:i:1}"
            if   [[ "$c" == '(' ]]; then (( depth++ ))
            elif [[ "$c" == ')' ]]; then
                (( depth-- ))
                (( depth == 0 )) && break
            fi
            (( i++ ))
        done
        # Store direction + interior content
        _emit PROC_SUB "${dir}|$(_lit "${_src:_pos+2:i-_pos-2}")"
        _pos=$(( i + 1 ))
    }

    # --------------------------------------------------------------------------
    # _backtick — consume `...` starting at _pos; emits CMD_SUB
    # --------------------------------------------------------------------------
    _backtick() {
        local i=$(( _pos + 1 ))
        while (( i < ${#_src} )); do
            local c="${_src:i:1}"
            [[ "$c" == '\' ]] && { (( i += 2 )); continue; }
            [[ "$c" == '`' ]] && {
                _emit CMD_SUB "$(_lit "${_src:_pos+1:i-_pos-1}")"
                _pos=$(( i + 1 ))
                return
            }
            (( i++ ))
        done
        _emit CMD_SUB "$(_lit "${_src:_pos+1}")"
        _pos=${#_src}
    }

    # --------------------------------------------------------------------------
    # _paramexp — consume ${ } starting at _pos; emits PARAM_EXP
    # --------------------------------------------------------------------------
    _paramexp() {
        local i=$(( _pos + 2 )) depth=1
        while (( i < ${#_src} && depth > 0 )); do
            local c="${_src:i:1}"
            if   [[ "$c" == '{' ]]; then (( depth++ ))
            elif [[ "$c" == '}' ]]; then
                (( depth-- ))
                (( depth == 0 )) && break
            fi
            (( i++ ))
        done
        _emit PARAM_EXP "${_src:_pos+2:i-_pos-2}"
        _pos=$(( i + 1 ))
    }

    # --------------------------------------------------------------------------
    # _var_literal — consume $var, $1, $#, $@, etc.; emits VAR_LITERAL
    # --------------------------------------------------------------------------
    _var_literal() {
        local start=$_pos
        (( _pos++ ))
        local next="${_src:_pos:1}"
        case "$next" in
            '#'|'@'|'*'|'?'|'$'|'!'|'-'|'0')
                _emit VAR_LITERAL "\$${next}"
                (( _pos++ ))
                return
                ;;
        esac
        if [[ "$next" =~ [a-zA-Z_] ]]; then
            (( _pos++ ))
            while (( _pos < ${#_src} )); do
                local c="${_src:_pos:1}"
                [[ "$c" =~ [a-zA-Z0-9_] ]] || break
                (( _pos++ ))
            done
        elif [[ "$next" =~ [1-9] ]]; then
            (( _pos++ ))
        fi
        _emit VAR_LITERAL "${_src:start:_pos-start}"
    }

    # --------------------------------------------------------------------------
    # _comment — consume # through end of _src; emits COMMENT
    # --------------------------------------------------------------------------
    _comment() {
        _emit COMMENT "${_src:_pos}"
        _pos=${#_src}
    }

    # --------------------------------------------------------------------------
    # _heredoc_body — consume heredoc body; emits HEREDOC_BODY + HEREDOC_TAIL
    # --------------------------------------------------------------------------
    _heredoc_body() {
        local marker="$1" has_dash="$2"
        local body="" sep=""
        while (( _li < ${#_lines[@]} )); do
            local line="${_lines[_li]}"
            (( _li++ ))
            local check="$line"
            [[ "$has_dash" == true ]] && check="${line#"${line%%[!$'\t']*}"}"
            if [[ "$check" == "$marker" ]]; then
                _emit HEREDOC_BODY "$(_lit "$body")"
                _emit HEREDOC_TAIL "$check"
                return
            fi
            body="${body}${sep}${line}"
            sep=$'\n'
        done
        _emit HEREDOC_BODY "$(_lit "$body")"
    }

    # --------------------------------------------------------------------------
    # _op — consume an operator at _pos; emits OP, REDIRECT, or HEREDOC_HEAD
    # --------------------------------------------------------------------------
    _op() {
        local three="${_src:_pos:3}" two="${_src:_pos:2}" one="${_src:_pos:1}"

        # Three-char operators
        case "$three" in
            ';;&') _emit OP  ';;&'; (( _pos += 3 )); [[ "$_case_state" == BODY ]] && _case_state=PAT; return ;;
            '&>>'|'2>>'|'2>&'|'1>&')
                   _emit REDIRECT "$three"; (( _pos += 3 )); return ;;
            '<<<') _emit HEREDOC_HEAD '<<<'; (( _pos += 3 )); return ;;
            '<<-') _emit HEREDOC_HEAD '<<-'; (( _pos += 3 )); return ;;
        esac

        # Two-char operators
        case "$two" in
            '<<')  _emit HEREDOC_HEAD '<<'; (( _pos += 2 )); return ;;
            '<('|'>(') _cmdsub_ps "${two:0:1}"; return ;;
            '((')  _arith_stmt; return ;;
            ';;')  _emit OP  ';;'; (( _pos += 2 )); [[ "$_case_state" == BODY ]] && _case_state=PAT; return ;;
            ';&')  _emit OP  ';&'; (( _pos += 2 )); [[ "$_case_state" == BODY ]] && _case_state=PAT; return ;;
            '&&')  _emit OP  '&&'; (( _pos += 2 )); return ;;
            '||')  _emit OP  '||'; (( _pos += 2 )); return ;;
            '>>'|'>&'|'<&'|'<>'|'&>')
                   _emit REDIRECT "$two"; (( _pos += 2 )); return ;;
        esac

        # Single-char
        case "$one" in
            ';'|'|'|'&'|'('|')')
                         _emit OP       "$one"; (( _pos++ )); return ;;
            '{'|'}')     _emit OP       "$one"; (( _pos++ )); return ;;
            '>'|'<')     _emit REDIRECT "$one"; (( _pos++ )); return ;;
            $'\n')       _emit OP       $'\n';  (( _pos++ )); return ;;
            '\')         _emit OP '\'; (( _pos += 2 )); return ;;
        esac

        _word
    }

    # --------------------------------------------------------------------------
    # _word — consume a bare word at _pos; emits WORD
    # --------------------------------------------------------------------------
    _word() {
        local start=$_pos
        while (( _pos < ${#_src} )); do
            local c="${_src:_pos:1}"
            [[ "$c" =~ [[:space:]] ]] && break
            [[ "$c" =~ [';|&<>()'\''"''\`$#{}\'] ]] && break
            (( _pos++ ))
        done
        local word="${_src:start:_pos-start}"
        [[ -z "$word" ]] && { (( _pos++ )); return; }

        if [[ "$word" =~ ^[0-9]+$ ]]; then
            local next_two="${_src:_pos:2}" next_one="${_src:_pos:1}"
            local _redir_pat='^[><]'
            if [[ "$next_two" =~ $_redir_pat || "$next_one" =~ $_redir_pat ]]; then
                local _before=$_tc
                _op
                if (( _tc > _before )); then
                    local _rval="${word}${_tk[$(( _tc - 1 ))_val]}"
                    if [[ "${_rval: -1}" == '&' && "${_src:_pos:1}" =~ [0-9] ]]; then
                        (( _pos++ ))
                        _rval+="${_src:_pos-1:1}"
                    fi
                    _tk[$(( _tc - 1 ))_val]="$_rval"
                fi
                return
            fi
        fi
        _emit WORD "$word"

        # After =~, raw-scan to ]] and emit the entire regex as REGEX_PATTERN
        if [[ "$word" == "=~" ]]; then
            # Skip leading whitespace
            while (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" =~ [[:space:]] ]]; do
                (( _pos++ ))
            done
            local _rx_start=$_pos
            # Scan until ]] (not inside a subexpression)
            while (( _pos < ${#_src} )); do
                if [[ "${_src:_pos:2}" == "]]" ]]; then
                    break
                fi
                (( _pos++ ))
            done
            local _rx="${_src:_rx_start:_pos-_rx_start}"
            # Trim trailing whitespace
            while [[ "${_rx: -1}" =~ [[:space:]] ]]; do _rx="${_rx%?}"; done
            [[ -n "$_rx" ]] && _emit REGEX_PATTERN "$_rx"
            # Emit ]] as WORD
            if [[ "${_src:_pos:2}" == "]]" ]]; then
                _emit WORD "]]"
                (( _pos += 2 ))
            fi
            return
        fi

        # case state transitions
        case "$word" in
            case) _case_state=WORD ;;
            in)   [[ "$_case_state" == WORD ]] && { _case_state=PAT; _case_depth=0; } ;;
            'esac') _case_state=OFF ;;
        esac
    }

    # --------------------------------------------------------------------------
    # _case_pat — consume a case arm pattern starting at _pos
    # Called when _case_state==PAT; consumes until ) at _case_depth,
    # emits REGEX_PATTERN with verbatim content, then OP ")"
    # --------------------------------------------------------------------------
    _case_pat() {
        local depth=0 buf=""
        # Skip leading whitespace first, then check for esac
        while (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" =~ [[:space:]] ]]; do
            (( _pos++ ))
        done
        # esac closes the case statement — don't consume it as a pattern
        if [[ "${_src:_pos:4}" == "esac" && ( ${#_src} -eq _pos+4 || "${_src:_pos+4:1}" =~ [[:space:]\;] ) ]]; then
            _case_state=OFF
            return
        fi
        # comment line — skip to EOL so we don't spin in PAT state on inline comments
        if [[ "${_src:_pos:1}" == '#' ]]; then
            _pos=${#_src}
            return
        fi
        while (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" =~ [[:space:]] ]]; do
            (( _pos++ ))
        done
        # Skip optional leading ( — it's syntactic sugar, not part of the pattern
        local _cp_c="${_src:_pos:1}"
        if [[ "$_cp_c" == '(' ]]; then
            (( _pos++ ))
        fi
        local start=$_pos
        while (( _pos < ${#_src} )); do
            local c="${_src:_pos:1}"
            if [[ "$c" == '(' ]]; then
                (( depth++ ))
            elif [[ "$c" == ')' ]]; then
                if (( depth == _case_depth )); then
                    # This ) closes the arm pattern
                    buf="${_src:start:_pos-start}"
                    _emit REGEX_PATTERN "$buf"
                    _emit OP "CASE)"
                    (( _pos++ ))
                    _case_state=BODY
                    return
                fi
                (( depth-- ))
            fi
            (( _pos++ ))
        done
        # EOL without closing ) — shouldn't happen in valid bash but emit what we have
        buf="${_src:start:_pos-start}"
        [[ -n "$buf" ]] && _emit REGEX_PATTERN "$buf"
    }

    # --------------------------------------------------------------------------
    # _scan_line — tokenise one logical line stored in _src
    # --------------------------------------------------------------------------
    _scan_line() {
        _pos=0
        local len=${#_src}
        while (( _pos < len )); do
            local c="${_src:_pos:1}" two="${_src:_pos:2}"

            # Case pattern consumption — highest priority
            if [[ "$_case_state" == PAT ]]; then
                _case_pat; continue
            fi

            # Whitespace — skip
            if [[ "$c" =~ [[:space:]] && "$c" != $'\n' ]]; then
                (( _pos++ )); continue
            fi

            # Comment
            if [[ "$c" == '#' ]]; then
                local prev=""
                (( _pos > 0 )) && prev="${_src:_pos-1:1}"
                if [[ "$prev" != '$' ]]; then
                    _comment; continue
                fi
            fi

            # Expansions — longest match first
            local three_c="${_src:_pos:3}"
            case "$three_c" in
                '$((') _arith;    continue ;;
            esac
            case "$two" in
                '$(')  _cmdsub;   continue ;;
                '${')  _paramexp; continue ;;
            esac

            # $'...' ANSI-C quoted string — must be before bare $var check
            if [[ "$two" == "$'" ]]; then
                local _qs=$(( _pos + 2 ))
                while (( _qs < ${#_src} )); do
                    local _qc="${_src:_qs:1}"
                    [[ "$_qc" == '\' ]] && (( _qs += 2 )) && continue
                    if [[ "$_qc" == "'" ]]; then
                        _emit RICH_STRING "${_src:_pos:_qs-_pos+1}"
                        _pos=$(( _qs + 1 ))
                        break
                    fi
                    (( _qs++ ))
                done
                continue
            fi

            # Unbraced variable expansion
            if [[ "$c" == '$' ]]; then
                local next_pos=$(( _pos + 1 ))
                local next="${_src:next_pos:1}"
                case "$next" in
                    [a-zA-Z_]|'#'|'@'|'*'|'?'|'$'|'!'|'-'|'0'|[1-9])
                        _var_literal; continue
                        ;;
                    *)
                        _emit WORD '$'
                        (( _pos++ ))
                        continue
                        ;;
                esac
            fi

            # Quoted strings and backtick
            case "$c" in
                "'") _sq; [[ $? -eq 94 ]] && _sq_open=1; continue ;;
                '"') _dq_stack=(); _dq_cmd_depth=0; _dq
                      [[ $? -eq 94 ]] && _dq_open=1
                      continue ;;
                '`') _backtick; continue ;;
            esac

            # Operators
            local _meta_pat=$'[;|&<>(){}\\\\\n]'
            if [[ "$c" =~ $_meta_pat ]]; then
                _op; continue
            fi

            _word
        done
    }

    # ============================================================================
    # MAIN TOKENISATION LOOP
    # ============================================================================

    # Split into lines
    while IFS= read -r line || [[ -n "$line" ]]; do
        _lines+=("$line")
    done <<< "$input"

    while (( _li < ${#_lines[@]} )); do
        if [[ "$_pipeline_log_mode" == progress || "$_pipeline_log_mode" == verbose ]]; then
                if [[ ${#LOG_QUEUE[@]} -gt 0 ]]; then
                echo -ne "$(printf '%s\n' "${LOG_QUEUE[@]}")\nTokenise: processed ${_li}/${#_lines[@]} lines\r" >&2
                else
                    echo -ne "Tokenise: processed ${_li}/${#_lines[@]} lines\r" >&2
                fi
                LOG_QUEUE=()
        fi

        # Multi-line single-quoted string continuation
        if (( _sq_open )); then
            [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line ${_li}: sq_open continuation")
            local _sq_line="${_lines[_li]}"
            (( _li++ ))
            # Scan for closing ' — first ' on the line closes it (no escapes in '...')
            local _sq_close=-1
            local _sq_ci=0
            while (( _sq_ci < ${#_sq_line} )); do
                if [[ "${_sq_line:_sq_ci:1}" == "'" ]]; then
                    _sq_close=$_sq_ci
                    break
                fi
                (( _sq_ci++ ))
            done

            local _last=$(( _tc - 1 ))
            if (( _sq_close >= 0 )); then
                [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line ${_li}: sq closed at col ${_sq_close}, remainder: '${_sq_line:$(( _sq_close + 1 ))}'")
                # Found closing ' — append prefix (with \n separator) and close
                _tk[${_last}_val]+=$'\n'"${_sq_line:0:_sq_close}"
                _sq_open=0
                # Remainder of the line needs normal tokenisation
                _src="${_sq_line:$(( _sq_close + 1 ))}"
                _pos=0
                _scan_line
            else
                [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line ${_li}: sq still open, appending whole line")
                # Still no closing ' — append whole line and keep waiting
                _tk[${_last}_val]+=$'\n'"$_sq_line"
            fi
            continue
        fi

        # Multi-line double-quoted string continuation
        if (( _dq_open )); then
            [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line ${_li}: dq_open continuation")
            local _dq_line="${_lines[_li]}"
            (( _li++ ))
            local _last=$(( _tc - 1 ))
            # Append newline + new line content to last token val
            _tk[${_last}_val]+="\n"
            _src="$_dq_line"
            _pos=0
            _dq
            if (( $? == 94 )); then
                [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line ${_li}: dq still open, merging partial token $_tc into $_last")
                # Still unclosed — append what _dq scanned and keep waiting
                _tk[${_last}_val]+="${_tk[$(( _tc - 1 ))_val]}"
                (( _tc-- ))
            else
                [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line ${_li}: dq closed, merging token $_tc into $_last, tc now $(( _tc - 1 ))")
                # Closed — merge the continuation into the original token
                _tk[${_last}_val]+="${_tk[$(( _tc - 1 ))_val]}"
                (( _tc-- ))
                _dq_open=0
            fi
            continue
        fi

        if $_pending_heredoc; then
            [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line ${_li}: consuming heredoc body for marker '${_pending_marker}' (dash=${_pending_has_dash})")
            _heredoc_body "$_pending_marker" "$_pending_has_dash"
            _pending_heredoc=false
            _pending_marker=""
            _pending_has_dash=false
            continue
        fi

        _src="${_lines[_li]}"
        local clean_src
        clean_src=${_src//\\/\\\\}
        [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line ${_li}: normal scan, src='${clean_src}'")
        (( _li++ ))

        (( _tc > 0 )) && _emit OP $'\n'
        _scan_line
        [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line $(( _li - 1 )): scan_line done, tc=${_tc}")

        # Look back for HEREDOC_HEAD + TAG
        local _i=$(( _tc - 1 ))
        while (( _i >= 0 )); do
            local _t="${_tk[${_i}_type]}"
            [[ "$_t" == "OP" && "${_tk[${_i}_val]}" == $'\n' ]] && break
            if [[ "$_t" == "HEREDOC_HEAD" ]]; then
                [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line $(( _li - 1 )): found HEREDOC_HEAD at token ${_i}, val='${_tk[${_i}_val]}'")
                # <<< is a herestring — no body/marker follows, skip pending
                [[ "${_tk[${_i}_val]}" == '<<<' ]] && { [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line $(( _li - 1 )): herestring (<<<), skipping pending"); break; }
                local _j=$(( _i + 1 ))
                while (( _j < _tc )); do
                    local _tj="${_tk[${_j}_type]}"
                    if [[ "$_tj" == "WORD" || "$_tj" == "STRING_SQ" || "$_tj" == "STRING_DQ" ]]; then
                        [[ "$_pipeline_log_mode" == verbose ]] && LOG_QUEUE+=("[tokenise] line $(( _li - 1 )): heredoc tag found at token ${_j}, marker='${_tk[${_j}_val]}' dash=${_pending_has_dash}")
                        _tk[${_j}_type]="HEREDOC_TAG"
                        _pending_marker="${_tk[${_j}_val]}"
                        _pending_has_dash=false
                        [[ "${_tk[${_i}_val]}" == '<<-' ]] && _pending_has_dash=true
                        _pending_heredoc=true
                        break
                    fi
                    (( _j++ ))
                done
                break
            fi
            (( _i-- ))
        done
    done
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

# ==============================================================================
# COMPILER OPTIMIZER
# Aggressively inlines positional argument variables to reduce local declarations
# ==============================================================================




# Optimize a function by inlining positional argument variables
# Uses multi-pass with dirty flag until no more optimizations possible
# Usage: optimize_function "file_content"
optimize_function() {
    local input="$1"
    local -a output=()
    local in_function=false
    local func_body=""
    local func_indent=""
    local brace_count=0

    # --------------------------------------------------------------------------
    # Sub-functions for optimization passes
    # --------------------------------------------------------------------------

    # Normalize test conditionals: convert [ ] to [[ ]]
    _normalize_test_conditionals() {
        local input="$1"
        local output="$input"

        # Convert single [ to double [[ for test conditionals
        # Pattern: [ followed by space and test operator/content, ending with ]
        # Handle multiple [ ] on same line

        # Step 1: Convert "[ " to "[[ " but NOT if already "[[ "
        output=$(echo "$output" | sed 's/\[\[ /__DBL_OPEN__/g')       # Protect existing [[
        output=$(echo "$output" | sed 's/\[ /[[ /g')                   # Convert [ to [[
        output=$(echo "$output" | sed 's/__DBL_OPEN__/[[ /g')          # Restore

        # Step 2: Convert " ]" to " ]]" but NOT if already " ]]"
        # Match " ]" followed by end-of-line, semicolon, pipe, ampersand, or closing paren
        output=$(echo "$output" | sed 's/ \]\]/__DBL_CLOSE__/g')       # Protect existing ]]
        output=$(echo "$output" | sed 's/ \]/ ]]/g')                   # Convert ] to ]]
        output=$(echo "$output" | sed 's/__DBL_CLOSE__/ ]]/g')         # Restore with space

        printf '%s' "$output"
    }

    # Fold constants and inline constant variables within a function
    _fold_constants() {
        local input="$1"
        local current="$input"
        local dirty=1
        local pass=0

        while (( dirty )); do
            ((pass++))
            dirty=0

            local -a lines=()
            while IFS= read -r line; do
                lines+=("$line")
            done <<< "$current"

            # PASS 1: Collect constant assignments (local/readonly VAR=NUMBER)
            declare -A constants=()
            for line in "${lines[@]}"; do
                # Match: local VAR=N or readonly VAR=N (where N is integer, line ends there)
                if [[ "$line" =~ ^[[:space:]]*(local|readonly)[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)=(-?[0-9]+)[[:space:]]*$ ]]; then
                    constants["${BASH_REMATCH[2]}"]="${BASH_REMATCH[3]}"
                elif [[ "$line" =~ ^[[:space:]]*(local|readonly)[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)=\"(-?[0-9]+)\"[[:space:]]*$ ]]; then
                    constants["${BASH_REMATCH[2]}"]="${BASH_REMATCH[3]}"
                fi
            done

            # PASS 2: Check which constants are safe to inline
            declare -A to_inline=()
            for const_var in "${!constants[@]}"; do
                local const_val="${constants[$const_var]}"
                local safe=true
                local usage_count=0

                for line in "${lines[@]}"; do
                    # Skip the declaration line itself
                    [[ "$line" =~ ^[[:space:]]*(local|readonly)[[:space:]]+${const_var}= ]] && continue

                    # Check if variable is reassigned
                    [[ "$line" =~ ${const_var}= ]] && { safe=false; break; }

                    # Check if variable is modified in arithmetic, allowing whitespace
                    [[ "$line" =~ \(\([[:space:]]*${const_var}[[:space:]]*(\+\+|--|\+=|-=|\*=|/=|%=|=) ]] && { safe=false; break; }

                    # Count usages - match $VAR, ${VAR}, or bare VAR in arithmetic
                    local temp="$line"
                    while [[ "$temp" =~ \$${const_var}([^a-zA-Z0-9_]|$) ]] || \
                          [[ "$temp" =~ \$\{${const_var}\} ]] || \
                          [[ "$temp" =~ [^a-zA-Z0-9_]${const_var}([^a-zA-Z0-9_]|$) ]]; do
                        ((usage_count++))
                        temp="${temp#*${const_var}}"
                    done
                done

                # Safe if used at least once and never reassigned
                if $safe && (( usage_count > 0 )); then
                    to_inline["$const_var"]="$const_val"
                fi
            done

            # PASS 3: Apply inlining and folding
            if (( ${#to_inline[@]} > 0 )); then
                local -a new_output=()
                for line in "${lines[@]}"; do
                    local skip_line=false

                    # Check if this line declares a constant we're inlining
                    for const_var in "${!to_inline[@]}"; do
                        if [[ "$line" =~ ^[[:space:]]*(local|readonly)[[:space:]]+${const_var}= ]]; then
                            # Only skip if it's the ONLY thing on the line
                            if [[ "$line" =~ ^[[:space:]]*(local|readonly)[[:space:]]+${const_var}=[^[:space:]]*$ ]]; then
                                skip_line=true
                            fi
                            break
                        fi
                    done

                    if ! $skip_line; then
                        # Inline constants
                        for const_var in "${!to_inline[@]}"; do
                            local const_val="${to_inline[$const_var]}"
                            # Replace ${VAR} with value
                            line="${line//\$\{${const_var}\}/${const_val}}"
                            # Replace $VAR with value
                            line="${line//\$${const_var}/${const_val}}"
                            # Replace bare VAR in arithmetic using sed
                            line=$(echo "$line" | sed "s/\\([^a-zA-Z0-9_]\\)${const_var}\\([^a-zA-Z0-9_]\\)/\\1${const_val}\\2/g")
                        done

                        # Fold arithmetic: $(( N )) → result
                        while [[ "$line" =~ \$\(\([[:space:]]*(-?[0-9]+)[[:space:]]*\+\ *[[:space:]]*(-?[0-9]+)[[:space:]]*\)\) ]]; do
                            local a="${BASH_REMATCH[1]}"
                            local b="${BASH_REMATCH[2]}"
                            local result=$(( a + b ))
                            line="${line//\$(\(( $a + $b \)))/$result}"
                            line="${line//\$(\(( $a  +  $b \)))/$result}"
                            line="${line//\$(\(( $a + $b \)))/$result}"
                            line="${line//\$(\(( $a  + $b \)))/$result}"
                        done
                        while [[ "$line" =~ \$\(\([[:space:]]*(-?[0-9]+)[[:space:]]*-[[:space:]]*(-?[0-9]+)[[:space:]]*\)\) ]]; do
                            local a="${BASH_REMATCH[1]}"
                            local b="${BASH_REMATCH[2]}"
                            local result=$(( a - b ))
                            line="${line//\$(\(( $a - $b \)))/$result}"
                            line="${line//\$(\(( $a  -  $b \)))/$result}"
                        done
                        while [[ "$line" =~ \$\(\([[:space:]]*(-?[0-9]+)[[:space:]]*\*[[:space:]]*(-?[0-9]+)[[:space:]]*\)\) ]]; do
                            local a="${BASH_REMATCH[1]}"
                            local b="${BASH_REMATCH[2]}"
                            local result=$(( a * b ))
                            line="${line//\$(\(( $a * $b \)))/$result}"
                            line="${line//\$(\(( $a  *  $b \)))/$result}"
                        done
                        while [[ "$line" =~ \$\(\([[:space:]]*(-?[0-9]+)[[:space:]]*\/[[:space:]]*(-?[0-9]+)[[:space:]]*\)\) ]]; do
                            local a="${BASH_REMATCH[1]}"
                            local b="${BASH_REMATCH[2]}"
                            if (( b != 0 )); then
                                local result=$(( a / b ))
                                line="${line//\$(\(( $a \/ $b \)))/$result}"
                                line="${line//\$(\(( $a  \/  $b \)))/$result}"
                            fi
                        done

                        new_output+=("$line")
                    fi
                done

                current=$(printf '%s\n' "${new_output[@]}")
                dirty=1
            fi

            unset constants to_inline
        done

        printf '%s' "$current"
    }

    # Eliminate dead code within a function (function-scoped only)
    _eliminate_dead_code() {
        local input="$1"
        local current="$input"
        local dirty=1

        while (( dirty )); do
            dirty=0

            local -a lines=()
            while IFS= read -r line; do
                lines+=("$line")
            done <<< "$current"

            # PASS 1: Remove dead branches: if (( 0 )); then ... fi
            local -a new_output=()
            local skip_until_fi=0
            local in_else=0
            local skip_else=0

            for line in "${lines[@]}"; do
                if (( skip_until_fi > 0 )); then
                    # Check for nested if
                    if [[ "$line" =~ ^[[:space:]]*if[[:space:]] ]]; then
                        ((skip_until_fi++))
                    elif [[ "$line" =~ ^[[:space:]]*fi[[:space:]]*$ ]] || [[ "$line" =~ ^[[:space:]]*fi\; ]]; then
                        ((skip_until_fi--))
                        if (( skip_until_fi == 0 )); then
                            in_else=0
                            skip_else=0
                        fi
                    elif [[ "$line" =~ ^[[:space:]]*else[[:space:]]*$ ]] || [[ "$line" =~ ^[[:space:]]*else\; ]]; then
                        in_else=1
                    fi

                    # If we're in else block and should skip it, continue skipping
                    # If we're in then block and else follows, start skipping else
                    if (( skip_until_fi > 0 )); then
                        continue
                    fi
                fi

                # Check for if (( 0 )) or if (( 1 ))
                if [[ "$line" =~ ^[[:space:]]*if[[:space:]]+\(\([[:space:]]*0[[:space:]]*\)\)[[:space:]]*(\;|then) ]]; then
                    # Dead branch - skip until fi, but don't skip else
                    skip_until_fi=1
                    in_else=0
                    dirty=1
                    continue
                elif [[ "$line" =~ ^[[:space:]]*if[[:space:]]+\(\([[:space:]]*1[[:space:]]*\)\)[[:space:]]*(\;|then) ]]; then
                    # Always true - remove the if line, keep body, remove else if present
                    # Just output the line without the if
                    continue
                fi

                new_output+=("$line")
            done

            current=$(printf '%s\n' "${new_output[@]}")

            # PASS 2: Remove unused local variables (function-scoped)
            lines=()
            while IFS= read -r line; do
                lines+=("$line")
            done <<< "$current"

            # Collect declared locals and their usage
            declare -A declared=()
            for line in "${lines[@]}"; do
                if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)= ]]; then
                    declared["${BASH_REMATCH[1]}"]=1
                fi
            done

            for decl_var in "${!declared[@]}"; do
                local usage_count=0
                for line in "${lines[@]}"; do
                    [[ "$line" =~ ^[[:space:]]*local[[:space:]]+${decl_var}= ]] && continue
                    # Match $VAR, ${VAR}, or bare VAR in arithmetic
                    if [[ "$line" =~ \$\{?${decl_var}\}? ]] || [[ "$line" =~ [^a-zA-Z0-9_]${decl_var}([^a-zA-Z0-9_]|$) ]]; then
                        ((usage_count++))
                    fi
                done

                if (( usage_count == 0 )); then
                    # Variable is declared but never used - remove it
                    new_output=()
                    for line in "${lines[@]}"; do
                        if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+${decl_var}= ]]; then
                            dirty=1
                            continue
                        fi
                        new_output+=("$line")
                    done
                    current=$(printf '%s\n' "${new_output[@]}")
                    # Re-read lines after modification
                    lines=()
                    while IFS= read -r line; do
                        lines+=("$line")
                    done <<< "$current"
                fi
            done

            unset declared
        done

        printf '%s' "$current"
    }

    # Optimize a single function body with multi-pass
    _optimize_function_body() {
        local input="$1"
        local dirty=1
        local current="$input"
        local pass=0

        while (( dirty )); do
            ((pass++))
            dirty=0
            declare -A candidates=()
            declare -A to_inline=()
            declare -A array_candidates=()
            declare -A array_to_inline=()

            local -a lines=()
            while IFS= read -r line; do
                lines+=("$line")
            done <<< "$current"

            # PASS 1: Collect candidates (scalars and arrays)
            for line in "${lines[@]}"; do
                # Scalar: local var="$1", local var="${2:-default}", etc.
                # Skip nameref declarations (local -n) as they're used for output, not input
                if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+ ]] && [[ ! "$line" =~ ^[[:space:]]*local[[:space:]]+-n[[:space:]] ]] && [[ ! "$line" =~ ^[[:space:]]*local[[:space:]]+-n$ ]]; then
                    local decl_part="${line#*local }"
                    local remaining="$decl_part"
                    while [[ "$remaining" =~ ([a-zA-Z_][a-zA-Z0-9_]*)=\"([^\"]+)\" ]]; do
                        local varname="${BASH_REMATCH[1]}"
                        local value="${BASH_REMATCH[2]}"
                        remaining="${remaining#*"${BASH_REMATCH[0]}"}"

                        if [[ "$value" =~ ^\$([0-9]+)$ ]]; then
                            candidates["$varname"]="\$${BASH_REMATCH[1]}"
                        elif [[ "$value" =~ ^\$\{([0-9]+)\}$ ]]; then
                            candidates["$varname"]="\$${BASH_REMATCH[1]}"
                        elif [[ "$value" =~ ^\$\{([0-9]+)(:-[^}]+)\}$ ]]; then
                            candidates["$varname"]="\${${BASH_REMATCH[1]}${BASH_REMATCH[2]}}"
                        elif [[ "$value" =~ ^\$\{([0-9]+)([#%][^/}]+)\}$ ]]; then
                            candidates["$varname"]="\${${BASH_REMATCH[1]}${BASH_REMATCH[2]}}"
                        elif [[ "$value" == "\$@" ]]; then
                            candidates["$varname"]="\$@"
                        elif [[ "$value" == '"$@"' ]]; then
                            candidates["$varname"]="\$@"
                        fi
                    done
                fi

                # Array: local -a var=("$@") or local -a var=("${src[@]}")
                if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+-a[[:space:]]+([a-zA_Z_][a-zA-Z0-9_]*)=\(\"?\$@\"?\)$ ]]; then
                    array_candidates["${BASH_REMATCH[1]}"]='AT_SIGN_ARRAY'
                elif [[ "$line" =~ ^[[:space:]]*local[[:space:]]+-a[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)=\(\"?\$\{([a-zA-Z_][a-zA-Z0-9_]*)\[@\]\}\"?\)$ ]]; then
                    array_candidates["${BASH_REMATCH[1]}"]="SRC_ARRAY:${BASH_REMATCH[2]}"
                fi
            done

            # PASS 2: Check legality for scalars
            # First, check if function uses both shift AND $@ (dangerous combination)
            local has_shift=false
            local has_at=false
            for line in "${lines[@]}"; do
                [[ "$line" =~ shift([[:space:]]|\;|$) ]] && has_shift=true
                # Detect $@ in all forms: $@, "$@", ${@}, "${@}", ${@:offset:length}
                [[ "$line" =~ \$@ ]] && has_at=true
                [[ "$line" =~ \$\{@ ]] && has_at=true
            done

            # Only mark positional inlining as illegal if BOTH shift and $@ are present
            local shift_at_conflict=false
            if $has_shift && $has_at; then
                shift_at_conflict=true
            fi

            for target_var in "${!candidates[@]}"; do
                local replacement="${candidates[$target_var]}"
                local illegal=0

                # If function has both shift and $@, inlining positional args is dangerous
                if $shift_at_conflict && [[ "$replacement" =~ ^\$[0-9]+$ ]]; then
                    illegal=1
                fi

                for line in "${lines[@]}"; do
                    [[ "$line" =~ ^[[:space:]]*local[[:space:]]+${target_var}= ]] && continue

                    # Check illegal patterns
                    [[ "$line" =~ unset[[:space:]]+${target_var}([[:space:]]|$) ]] && { illegal=1; break; }
                    [[ "$line" =~ export[[:space:]]+${target_var}([[:space:]]|$) ]] && { illegal=1; break; }
                    [[ "$line" =~ read[[:space:]]+(.*[[:space:]]+)?${target_var}([[:space:]]|$) ]] && { illegal=1; break; }
                    [[ "$line" =~ getopts[[:space:]] ]] && [[ "$line" =~ ${target_var}([[:space:]]|$) ]] && { illegal=1; break; }
                    [[ "$line" =~ printf[[:space:]]+[^[:space:]]*[[:space:]]+-v[[:space:]]+${target_var}([[:space:]]|$) ]] && { illegal=1; break; }
                    [[ "$line" =~ \(\([[:space:]]*${target_var}(\+\+|--|\+=|-=) ]] && { illegal=1; break; }
                    [[ "$line" =~ \$\{!${target_var} ]] && { illegal=1; break; }

                    # Check for arithmetic usage (e.g., (( i % size )) - cannot inline in complex expressions)
                    [[ "$line" =~ "(( ".*${target_var}.*"))" ]] && { illegal=1; break; }
                done

                (( !illegal )) && to_inline["$target_var"]="$replacement"
            done

            # If we're inlining positional args and there's a shift, we need to handle offset
            # For now, just remove shift lines (simpler approach)
            local remove_shift=false
            for target_var in "${!to_inline[@]}"; do
                if [[ "${to_inline[$target_var]}" =~ ^\$[0-9]+$ ]]; then
                    remove_shift=true
                    break
                fi
            done

            # PASS 2b: Check legality for arrays
            for arr_var in "${!array_candidates[@]}"; do
                local illegal=0
                local usage_count=0
                local array_type="${array_candidates[$arr_var]}"

                for line in "${lines[@]}"; do
                    # Skip declaration line
                    [[ "$line" =~ ^[[:space:]]*local[[:space:]]+-a[[:space:]]+${arr_var}= ]] && continue

                    # Check for modifications
                    [[ "$line" =~ ${arr_var}\[.*\]= ]] && { illegal=1; break; }
                    [[ "$line" =~ ${arr_var}\+=\( ]] && { illegal=1; break; }
                    [[ "$line" =~ unset[[:space:]]+\'?${arr_var} ]] && { illegal=1; break; }

                    # Count usages of "${arr_var[@]}"
                    local temp="$line"
                    while [[ "$temp" =~ \"\$\{${arr_var}\[@\]\}\" ]]; do
                        ((usage_count++))
                        temp="${temp#*"${BASH_REMATCH[0]}"}"
                    done

                    # Also count index access: ${arr_var[N]} or ${arr_var[-1]}
                    temp="$line"
                    while [[ "$temp" =~ \$\{${arr_var}\[[-0-9]+\]\} ]]; do
                        ((usage_count++))
                        temp="${temp#*"${BASH_REMATCH[0]}"}"
                    done
                done

                # Safe if used at least once and not modified
                if (( !illegal && usage_count > 0 )); then
                    array_to_inline["$arr_var"]="$array_type"
                fi
            done

            # Check for eval (flag entire function as unsafe)
            for line in "${lines[@]}"; do
                [[ "$line" =~ eval[[:space:]] ]] && { to_inline=(); array_to_inline=(); break; }
            done

            # PASS 3: Apply transformations
            if (( ${#to_inline[@]} > 0 || ${#array_to_inline[@]} > 0 )); then
                local -a new_output=()
                for line in "${lines[@]}"; do
                    local skip_line=false
                    local is_local_line=false

                    # Check if this is a local declaration line
                    if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+ ]]; then
                        is_local_line=true
                    fi

                    # Skip shift lines if we're inlining positional args
                    # Match: "shift" at start of line OR after semicolon
                    if $remove_shift; then
                        if [[ "$line" =~ ^[[:space:]]*shift([[:space:]]|\;|$) ]] || [[ "$line" =~ \;[[:space:]]*shift([[:space:]]|\;|$) ]]; then
                            skip_line=true
                        fi
                    fi

                    # Skip array declaration lines (these are fully removed)
                    for arr_var in "${!array_to_inline[@]}"; do
                        if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+-a[[:space:]]+${arr_var}= ]]; then
                            skip_line=true
                            break
                        fi
                    done

                    if ! $skip_line; then
                        # Apply scalar replacements first
                        for target_var in "${!to_inline[@]}"; do
                            local replacement="${to_inline[$target_var]}"
                            [[ "$line" =~ \'[^\']*\$${target_var}[^\']*\' ]] && continue

                            while [[ "$line" =~ \$\{([a-zA-Z_][a-zA-Z0-9_]*)\[${target_var}\]\} ]]; do
                                local arr_name="${BASH_REMATCH[1]}"
                                local new_val="\${${arr_name}[${replacement}]}"
                                local old_val="\${${arr_name}[${target_var}]}"
                                line="${line//"$old_val"/"$new_val"}"
                            done
                            while [[ "$line" =~ \$\{([a-zA-Z_][a-zA-Z0-9_]*)\[\$${target_var}\]\} ]]; do
                                local arr_name="${BASH_REMATCH[1]}"
                                local new_val="\${${arr_name}[${replacement}]}"
                                local old_val="\${${arr_name}[\$${target_var}]}"
                                line="${line//"$old_val"/"$new_val"}"
                            done

                            line="${line//\$\{${target_var}\}/${replacement}}"
                            line="${line//\$${target_var}/${replacement}}"

                            local unescaped_replacement="$replacement"
                            unescaped_replacement="${unescaped_replacement#\$}"
                            line="${line//\\\$${target_var}/\\\$${unescaped_replacement}}"
                        done

                        # After replacements, clean up local declarations
                        # IMPORTANT: Preserve "local" for remaining variables to avoid global leakage
                        if $is_local_line; then
                            for target_var in "${!to_inline[@]}"; do
                                # Remove just the variable assignment, keep "local" for other vars
                                line=$(printf '%s' "$line" | sed -E "s/${target_var}=\"[^\"]*\" *//")
                                # Clean up: "local  " -> "local "
                                line=$(printf '%s' "$line" | sed 's/local  */local /')
                                # Clean up "local ;" -> ";"
                                line=$(printf '%s' "$line" | sed 's/local ;/;/')
                            done
                            # Clean up leading "; " if local was removed
                            line=$(printf '%s' "$line" | sed 's/^[[:space:]]*;[[:space:]]*//')
                            # Clean up standalone "local" with no variables
                            if [[ "$line" =~ ^[[:space:]]*local[[:space:]]*$ ]]; then
                                skip_line=true
                            fi
                            # Skip if line is now empty or just whitespace
                            if [[ -z "${line}" || "$line" =~ ^[[:space:]]*$ ]]; then
                                skip_line=true
                            fi
                        fi

                        # Apply array replacements
                        for arr_var in "${!array_to_inline[@]}"; do
                            local array_type="${array_to_inline[$arr_var]}"
                            local replacement

                            # Convert marker to actual replacement
                            if [[ "$array_type" == "AT_SIGN_ARRAY" ]]; then
                                replacement='"$@"'
                            elif [[ "$array_type" =~ ^SRC_ARRAY:(.+)$ ]]; then
                                local src_var="${BASH_REMATCH[1]}"
                                replacement="\"\${${src_var}[@]}\""
                            else
                                continue
                            fi

                            # Replace "${arr_var[@]}" with replacement using sed for safety
                            line=$(echo "$line" | sed "s/\"\\\${${arr_var}\[@\]}\"/${replacement//\//\\/}/g")

                            # Replace ${#arr_var[@]} with $#
                            line="${line//\$\{#${arr_var}\[@\]\}/\$#}"

                            # Replace ${arr_var[N]} with $(N+1)
                            while [[ "$line" =~ \$\{${arr_var}\[([0-9]+)\]\} ]]; do
                                local idx="${BASH_REMATCH[1]}"
                                local new_idx=$((idx + 1))
                                line="${line//\$\{${arr_var}\[$idx\]\}/\$${new_idx}}"
                            done

                            # Replace ${arr_var[-1]} with ${!#}
                            line="${line//\$\{${arr_var}\[-1\]\}/\$\{!#\}}"
                        done

                        if ! $skip_line; then
                            new_output+=("$line")
                        fi
                    fi
                done

                # Post-process: collapse consecutive blank lines
                local -a final_output=()
                local prev_blank=false
                for line in "${new_output[@]}"; do
                    if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
                        if ! $prev_blank; then
                            final_output+=("$line")
                            prev_blank=true
                        fi
                        # Skip consecutive blank lines
                    else
                        final_output+=("$line")
                        prev_blank=false
                    fi
                done

                current=$(printf '%s\n' "${final_output[@]}")
                dirty=1
            fi

            unset candidates to_inline array_candidates array_to_inline
        done

        # Apply constant folding and dead code elimination as post-processing passes
        current=$(_fold_constants "$current")
        current=$(_eliminate_dead_code "$current")

        printf '%s' "$current"
    }

    # Optimize a single line in global scope (simplified, no multi-pass)
    _optimize_global_line() {
        printf '%s' "$1"
    }

    # --------------------------------------------------------------------------
    # Main optimization logic
    # --------------------------------------------------------------------------

    # First pass: identify and optimize function-scoped code
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Detect function start: name() { or name() \n {
        if [[ "$line" =~ ^([[:space:]]*)([a-zA-Z_][a-zA-Z0-9_::]*)\(\)[[:space:]]*(\{?) ]]; then
            local indent="${BASH_REMATCH[1]}"
            local func_name="${BASH_REMATCH[2]}"
            local open_brace="${BASH_REMATCH[3]}"

            if [[ -n "$open_brace" ]]; then
                # Single-line or same-line body start
                in_function=true
                func_indent="$indent"
                func_body="$line"$'\n'
                brace_count=1

                # Count braces in the line
                local temp="${line//[^\{]/}"
                brace_count=${#temp}
                temp="${line//[^\}]/}"
                ((brace_count -= ${#temp}))

                if (( brace_count == 0 )); then
                    # Function closed on same line
                    in_function=false
                    output+=("$(_optimize_function_body "$func_body")")
                    func_body=""
                fi
            else
                # Opening brace on next line
                in_function=true
                func_indent="$indent"
                func_body="$line"$'\n'
                brace_count=0
            fi
        elif $in_function; then
            func_body+="$line"$'\n'

            # Count braces
            local temp="${line//[^\{]/}"
            ((brace_count += ${#temp}))
            temp="${line//[^\}]/}"
            ((brace_count -= ${#temp}))

            if (( brace_count <= 0 )); then
                # Function ended
                in_function=false
                output+=("$(_optimize_function_body "$func_body")")
                func_body=""
            fi
        else
            # Global scope - optimize directly
            output+=("$(_optimize_global_line "$line")")
        fi
    done <<< "$input"

    # Handle any remaining function body
    if [[ -n "$func_body" ]]; then
        output+=("$(_optimize_function_body "$func_body")")
    fi

    # Print result
    printf '%s\n' "${output[@]}"
}

# Optimize a single function body with multi-pass


# ==============================================================================
# ==============================================================================
# TOKEN-BASED MINIFIER
# Conservative approach: newlines become semicolons, then we handle exceptions
# Uses paren_depth counter to handle arrays and subshells correctly
# ==============================================================================

# Main minification entry point using tokens
# Usage: minify "content"
minify() {
    local input="$1"
    local -A tokens=()
    local token_count=0
    pipeline_verbose "[Minifier] tokenising input..."
    pipeline_flush "Minifier: tokenising input..."
    # Tokenize input
    tokenise "$input" tokens token_count
    pipeline_verbose "[Minifier] tokenise done (${token_count} tokens)"
    pipeline_flush "Minifier: tokenise done (${token_count} tokens)"

    # Pre-processing: remove COMMENT tokens, collapse consecutive newlines,
    # rebuild as clean associative array
    local -A clean_tokens=()
    local ti=0 ci=0 _prev_was_nl=0

    pipeline_verbose
    pipeline_verbose "Filtering COMMENT tokens..."
    for (( ti=0; ti<token_count; ti++ )); do
        local _tt="${tokens[${ti}_type]}" _tv="${tokens[${ti}_val]}"
        [[ "$_tt" == "COMMENT" ]] && continue
        if [[ "$_tt" == "OP" && "$_tv" == $'\n' ]]; then
            (( _prev_was_nl )) && continue
            _prev_was_nl=1
        else
            _prev_was_nl=0
        fi
        clean_tokens[${ci}_type]="$_tt"
        clean_tokens[${ci}_val]="$_tv"
        (( ci++ ))
    done
    unset tokens
    declare -A tokens=()
    pipeline_verbose "Rebuilding clean token table..."
    for (( ti=0; ti<ci; ti++ )); do
        tokens[${ti}_type]="${clean_tokens[${ti}_type]}"
        tokens[${ti}_val]="${clean_tokens[${ti}_val]}"
    done
    token_count=$ci
    unset clean_tokens

    # Build minified output from tokens
    local buffer=""
    local prev_type="" prev_val=""
    local i=0
    local paren_depth=0      # Track depth inside () for arrays/subshells
    local array_depth=0      # Track depth inside [[]] for arrays
    local bracket_depth=0    # Track depth inside [] for array subscripts

    pipeline_verbose "[Minifier] Processing ${token_count} tokens..."

    # --------------------------------------------------------------------------
    # _update_depth — track bracket/paren depth for array/subshell handling
    # --------------------------------------------------------------------------
    _update_depth() {
        local type="$1" val="$2"
        local old_paren_depth=$paren_depth old_array_depth=$array_depth old_bracket_depth=$bracket_depth
        if [[ "$type" == "OP" ]]; then
            case "$val" in
                '(')  (( paren_depth++ )) ;;
                ')')  (( paren_depth > 0 )) && (( paren_depth-- )) ;;
                '[[') (( array_depth++ )) ;;
                ']]') (( array_depth > 0 )) && (( array_depth-- )) ;;
                '[')  (( bracket_depth++ )) ;;
                ']')  (( bracket_depth > 0 )) && (( bracket_depth-- )) ;;
            esac
        fi
        (( old_array_depth != array_depth || old_paren_depth != paren_depth || old_bracket_depth != bracket_depth )) && pipeline_verbose "Updated depths: paren=$paren_depth, array=$array_depth, bracket=$bracket_depth"

    }

    # --------------------------------------------------------------------------
    # _unescape — convert literalized \\n \\t back to \n \t for output
    # Also converts \\\\ to \\
    # --------------------------------------------------------------------------
    _unescape() {
        local s="$1"
        # Convert \\n to actual newline, \\t to actual tab
        s="${s//\\n/$'\n'}"
        s="${s//\\t/$'\t'}"
        # Convert \\\\ to single \\
        s="${s//\\\\/\\}"
        printf '%s' "$s"
    }

    # --------------------------------------------------------------------------
    # _unescape_str — convert literalized escapes for string output
    # Converts \\n to \n (the two-char sequence), \\t to \t, \\\\ to \\
    # --------------------------------------------------------------------------
    _unescape_str() {
        local s="$1"
        # For string output, we want to preserve escape sequences as-is
        # Just convert \\\\ to \\
        s="${s//\\\\/\\}"
        printf '%s' "$s"
    }

    # --------------------------------------------------------------------------
    # _token_to_string — rebuild token content for output
    # --------------------------------------------------------------------------
    _token_to_string() {
        local type="$1" val="$2"
        case "$type" in
            WORD|REDIRECT|VAR_LITERAL|RICH_STRING|REGEX_PATTERN) printf '%s' "$val" ;;
            OP) [[ "$val" == 'CASE)' ]] && printf ')' || printf '%s' "$val" ;;
            STRING_SQ)
                if [[ "$val" == *$'\n'* ]]; then
                    # Multi-line — convert to $'...' so output stays on one line.
                    # Only two substitutions: \ → \\ and real newline → \n.
                    # Everything else (including \033, \n as two chars, etc.) is untouched.
                    local _sq="$val"
                    _sq="${_sq//\\/\\\\}"       # \ → \\ (must be first)
                    _sq="${_sq//'/\\'}"          # ' → \' (needed inside $'...')
                    _sq="${_sq//$'\n'/\\n}"      # real newline → \n
                    printf "\$'%s'" "$_sq"
                else
                    printf "'%s'" "$val"
                fi ;;
            STRING_DQ) printf '"%s"' "$(_unescape_str "$val")" ;;
            ARITH)
                # Statement position: (( )) — no $ prefix
                # Expression position: $(( )) — needs $ prefix
                # Statement position = after keywords, semicolons, newlines, or braces
                local _arith_stmt=0
                if [[ "$prev_val" =~ ^(for|if|while|elif|then|do|else|esac|done|fi|\{)$ ]]; then
                    _arith_stmt=1
                elif [[ "$prev_type" == "OP" && ( "$prev_val" == ';' || "$prev_val" == $'\n' || "$prev_val" == '{' || "$prev_val" == '(' ) ]]; then
                    _arith_stmt=1
                elif [[ -z "$prev_type" ]]; then
                    _arith_stmt=1
                fi
                if (( _arith_stmt )); then
                    printf '((%s))' "$(_unescape "$val")"
                else
                    printf '$((%s))' "$(_unescape "$val")"
                fi
                ;;
            CMD_SUB)
                # Newlines in body become spaces — bare newlines before | are invalid bash
                local _cs="$val"
                _cs="${_cs//\\n/ }"
                _cs="${_cs//\\t/ }"
                _cs="${_cs//\\\\/\\}"
                printf '$(%s)' "$_cs" ;;
            PROC_SUB)
                local dir="${val%%|*}"
                local content="${val#*|}"
                printf '%s(%s)' "$dir" "$(_unescape "$content")"
                ;;
            PARAM_EXP) printf '${%s}' "$val" ;;
            HEREDOC_HEAD) printf '%s' "$val" ;;
            HEREDOC_TAG) printf '%s' "$val" ;;
            HEREDOC_BODY) printf '\n%s' "$(_unescape "$val")" ;;
            HEREDOC_TAIL) printf '\n%s' "$val" ;;
            *) printf '%s' "$val" ;;
        esac
    }

    # --------------------------------------------------------------------------
    # _skip_semi — return 0 (true) if we should NOT add semicolon
    # --------------------------------------------------------------------------
    _skip_semi() {
        local prev_type="$1" prev_val="$2" curr_type="$3" curr_val="$4"

        # Never insert semi before a comment (shouldn't reach here after pre-processing)
        [[ "$curr_type" == "COMMENT" ]] && return 0

        # Never insert semi around REGEX_PATTERN
        [[ "$curr_type" == "REGEX_PATTERN" ]] && return 0
        [[ "$prev_type" == "REGEX_PATTERN" ]] && return 0

        # Never insert semi around heredoc tokens
        [[ "$curr_type" =~ ^HEREDOC ]] && return 0
        [[ "$prev_type" =~ ^(HEREDOC_TAG|HEREDOC_HEAD)$ ]] && return 0

        # No semi after background operator
        [[ "$prev_type" == "OP" && "$prev_val" == "&" ]] && return 0

        # No semi before closing parens (but DO add before })
        [[ "$curr_type" == "OP" && "$curr_val" == ")" ]] && return 0

        # No semi before block STARTERS (then/do/in) - they follow conditionals
        [[ "$curr_type" == "WORD" && "$curr_val" =~ ^(then|do|in)$ ]] && return 0

        # No semi after opening braces/parens
        [[ "$prev_type" == "OP" && "$prev_val" == "(" ]] && return 0
        [[ "$prev_type" == "OP" && "$prev_val" == "{" ]] && return 0

        # No semi after block keywords (then/do/in/else/elif)
        [[ "$prev_type" == "WORD" && "$prev_val" =~ ^(then|do|in|else|elif)$ ]] && return 0

        # No semi after case operators or case arm terminator
        [[ "$prev_type" == "OP" && "$prev_val" =~ ^(;;|;;&|;&|CASE\))$ ]] && return 0

        # No semi after heredoc
        [[ "$prev_type" == "HEREDOC_TAIL" ]] && return 0

        # No semi after && or || (they continue the expression)
        [[ "$prev_type" == "OP" && "$prev_val" == "&&" ]] && return 0
        [[ "$prev_type" == "OP" && "$prev_val" == "||" ]] && return 0

        return 1  # Default: add semi (including before fi/done/esac/})
    }

    # --------------------------------------------------------------------------
    # _needs_space — conservative space handling
    # --------------------------------------------------------------------------
    _needs_space() {
        local prev_type="$1" prev_val="$2" curr_type="$3" curr_val="$4"

        # WORD WORD always needs space (except for var= assignments like "flag=" not "==" or "!=")
        if [[ "$prev_type" == "WORD" && "$curr_type" == "WORD" ]]; then
            # Exception: var= assignments
            # (no special rule: WORD= before WORD always needs space, e.g. IFS= read)
            # Exception: for/in loops need space
            [[ "$prev_val" == "in" ]] && return 0
            return 0
        fi

        # WORD before PARAM_EXP needs space (e.g., "in ${var}")
        if [[ "$prev_type" == "WORD" && "$curr_type" == "PARAM_EXP" ]]; then
            [[ "$prev_val" =~ [a-zA-Z0-9_]=$ ]] && return 1  # var=${x} — no space
            return 0  # other WORD before PARAM_EXP needs space
        fi

        # WORD ending with = followed by expansion/literal needs no space — it's the RHS
        # But WORD followed by another WORD (e.g. IFS= read) still needs space
        if [[ "$prev_type" == "WORD" && "$prev_val" =~ (([a-zA-Z0-9_]|\])=)$ ]]; then
            [[ "$curr_type" =~ ^(ARITH|CMD_SUB|PARAM_EXP|VAR_LITERAL|RICH_STRING)$ ]] && return 1
        fi

        # VAR before WORD needs space
        [[ "$prev_type" == "VAR_LITERAL" && "$curr_type" == "WORD" ]] && return 0

        # WORD before VAR needs space
        [[ "$prev_type" == "WORD" && "$curr_type" == "VAR_LITERAL" ]] && return 0

        # WORD before STRING needs space (but not for glob * before string or var= assignments)
        # Skip space if prev is * (glob) or ends with = (assignment)
        if [[ "$prev_type" == "WORD" && "$curr_type" =~ ^STRING ]]; then
            [[ "$prev_val" == "*" ]] && return 1
            { [[ "$prev_val" =~ [a-zA-Z0-9_]=$ ]] || [[ "$prev_val" =~ \]=$ ]]; } && return 1
            return 0
        fi

        # STRING/RICH_STRING before STRING needs space
        [[ "$prev_type" =~ ^(STRING|RICH) && "$curr_type" =~ ^(STRING|RICH) ]] && return 0

        # WORD before RICH_STRING needs space
        [[ "$prev_type" == "WORD" && "$curr_type" == "RICH_STRING" ]] && return 0

        # RICH_STRING before WORD needs space
        [[ "$prev_type" == "RICH_STRING" && "$curr_type" == "WORD" ]] && return 0

        # STRING before WORD needs space (but not for glob * after string)
        [[ "$prev_type" =~ ^STRING && "$curr_type" == "WORD" ]] && { [[ "$curr_val" != "*" ]] && return 0; }

        # WORD before REDIRECT needs space
        [[ "$prev_type" == "WORD" && "$curr_type" == "REDIRECT" ]] && return 0

        # REDIRECT target attaches directly — no space (e.g. 2>/dev/null, >>file)
        [[ "$prev_type" == "REDIRECT" && "$curr_type" == "WORD" ]] && return 1

        # WORD before HEREDOC_HEAD needs space
        [[ "$prev_type" == "WORD" && "$curr_type" == "HEREDOC_HEAD" ]] && return 0

        # { before content needs space
        [[ "$prev_type" == "OP" && "$prev_val" == "{" && "$curr_type" != "OP" ]] && return 0

        # ) before { needs space (function def)
        [[ "$prev_type" == "OP" && "$prev_val" == ")" && "$curr_type" == "OP" && "$curr_val" == "{" ]] && return 0

        # ) before WORD needs space
        [[ "$prev_type" == "OP" && "$prev_val" == ")" && "$curr_type" == "WORD" ]] && return 0

        # [[ before content needs space
        [[ "$prev_type" == "WORD" && "$prev_val" == "[[" && "$curr_type" != "OP" ]] && return 0

        # ]] after content needs space before next token
        [[ "$prev_type" == "WORD" && "$prev_val" == "]]" && "$curr_type" != "OP" ]] && return 0

        # ARITH needs space around it
        [[ "$prev_type" == "ARITH" && "$curr_type" != "OP" ]] && return 0
        [[ "$prev_type" != "OP" && "$curr_type" == "ARITH" ]] && return 0

        # REGEX_PATTERN: space before it; space after it (before ]]); CASE) attaches directly
        [[ "$curr_type" == "REGEX_PATTERN" ]] && return 0
        # REGEX_PATTERN before ]] needs space; but CASE) attaches directly (no space)
        [[ "$prev_type" == "REGEX_PATTERN" && "$curr_type" == "OP" && "$curr_val" == 'CASE)' ]] && return 1
        [[ "$prev_type" == "REGEX_PATTERN" ]] && return 0
        # Space after CASE) before body
        [[ "$prev_type" == "OP" && "$prev_val" == 'CASE)' ]] && return 0

        # CMD_SUB needs space around it
        [[ "$prev_type" == "CMD_SUB" && "$curr_type" != "OP" ]] && return 0
        # WORD before CMD_SUB needs space unless it's an assignment (ends with =)
        if [[ "$prev_type" == "WORD" && "$curr_type" == "CMD_SUB" ]]; then
            [[ "$prev_val" =~ (([a-zA-Z0-9_]|\])=)$ ]] && return 1
            return 0
        fi

        # PROC_SUB needs space around it
        [[ "$prev_type" == "PROC_SUB" && "$curr_type" != "OP" ]] && return 0
        [[ "$prev_type" != "OP" && "$curr_type" == "PROC_SUB" ]] && return 0

        # PARAM_EXP before WORD needs space
        [[ "$prev_type" == "PARAM_EXP" && "$curr_type" == "WORD" ]] && return 0

        # ; before keywords needs space
        [[ "$prev_type" == "OP" && "$prev_val" == ";" && "$curr_type" == "WORD" ]] && return 0

        # && and || operators need spaces around them
        [[ "$prev_type" == "OP" && "$prev_val" == "&&" ]] && return 0
        [[ "$prev_type" == "OP" && "$prev_val" == "||" ]] && return 0
        [[ "$curr_type" == "OP" && "$curr_val" == "&&" ]] && return 0
        [[ "$curr_type" == "OP" && "$curr_val" == "||" ]] && return 0

        # =~ regex operator needs space after it (tokenized as WORD)
        [[ "$prev_type" == "WORD" && "$prev_val" == "=~" ]] && return 0

        # case terminators ;; ;;& ;& need spaces on both sides
        [[ "$prev_type" == "OP" && "$prev_val" =~ ^(;;|;;&|;&)$ ]] && return 0
        [[ "$curr_type" == "OP" && "$curr_val" =~ ^(;;|;;&|;&)$ ]] && return 0

        # } after ; needs space
        [[ "$prev_type" == "OP" && "$prev_val" == ";" && "$curr_type" == "OP" && "$curr_val" == "}" ]] && return 0

        # ( after = needs no space (array assignment: _var=(
        [[ "$prev_type" == "WORD" && "$prev_val" =~ (([a-zA-Z0-9_]|\])=)$ && "$curr_type" == "OP" && "$curr_val" == "(" ]] && return 1

        # STRING after = needs no space (var="value")
        [[ "$prev_type" == "WORD" && "$prev_val" =~ (([a-zA-Z0-9_]|\])=)$ && "$curr_type" =~ ^STRING ]] && return 1
        # NOTE: WORD after = (e.g. IFS= read) DOES need space — do not suppress

        return 1  # Default: no space
    }

    # --------------------------------------------------------------------------
    # Main token processing loop
    # --------------------------------------------------------------------------
    while (( i < token_count )); do
        local type="${tokens[${i}_type]}"
        local val="${tokens[${i}_val]}"
        (( i++ ))

        if [[ "$_pipeline_log_mode" == progress || "$_pipeline_log_mode" == verbose ]]; then
            pipeline_flush "Minify: processed ${i}/${token_count} tokens"
        fi

        # Handle newlines: convert to semicolons (conservative default)
        if [[ "$type" == "OP" && "$val" == $'\n' ]]; then
            # Backslash continuation — strip the \ already in buffer and join with space
            if [[ "$prev_type" == "OP" && "$prev_val" == '\' ]]; then
                pipeline_verbose "Backslash continuation in token $i, joining."
                buffer="${buffer%\\} "
                prev_type=""
                prev_val=""
                _update_depth "$type" "$val"
                continue
            fi

            # Preserve newline after HEREDOC_TAIL
            if [[ "$prev_type" == "HEREDOC_TAIL" ]]; then
                pipeline_verbose "HEREDOC Tail on token $i, preserving newline."
                buffer+=$'\n'
                prev_type=""
                prev_val=""
                _update_depth "$type" "$val"
                continue
            fi

            # Skip consecutive newlines
            while (( i < token_count )); do
                pipeline_verbose "Skipped redundant newline."
                local next_type="${tokens[${i}_type]}"
                local next_val="${tokens[${i}_val]}"
                [[ "$next_type" == "OP" && "$next_val" == $'\n' ]] && { (( i++ )); continue; }
                break
            done

            # Inside brackets/parens (arrays), use space instead of semicolon
            if (( paren_depth > 0 || array_depth > 0 || bracket_depth > 0 )); then
                pipeline_verbose "Inside brackets or arrays. Using space separator instead."
                buffer+=" "
                prev_type="OP"; prev_val=" "
            elif [[ -n "$prev_type" && "$buffer" =~ [^[:space:]]$ ]]; then
                if (( i < token_count )); then
                    local next_type="${tokens[${i}_type]}"
                    local next_val="${tokens[${i}_val]}"
                    if ! _skip_semi "$prev_type" "$prev_val" "$next_type" "$next_val"; then
                        pipeline_verbose "[Minifier] Using semicolons for a valid pattern in token $i (within bracket/array)"
                        buffer+="; "
                        prev_type="OP"; prev_val=";"
                    fi
                fi
            fi
            _update_depth "$type" "$val"
            continue
        fi

        # Update depth tracking before processing token
        _update_depth "$type" "$val"

        # Add space if needed
        if [[ -n "$prev_type" && "$buffer" =~ [^[:space:]]$ ]]; then
            if _needs_space "$prev_type" "$prev_val" "$type" "$val"; then
                pipeline_verbose "[Minifier] Pattern in token $i required space, adding."
                buffer+=" "
            fi
        fi

        # Append token
        buffer+="$(_token_to_string "$type" "$val")"
        prev_type="$type"
        prev_val="$val"
    done

    if [[ "$_pipeline_log_mode" == progress || "$_pipeline_log_mode" == verbose ]]; then
        pipeline_flush "Minify: processed ${token_count}/${token_count} tokens"
    fi

    pipeline_verbose "[Minifier] Done. Output: ${#buffer} bytes"
    if [[ "$_pipeline_log_mode" == progress || "$_pipeline_log_mode" == verbose ]]; then
        pipeline_flush "Minify: done"
        pipeline_flush_final
    fi

    # Final cleanup
    buffer="${buffer//  / }"
    buffer="${buffer# }"
    buffer="${buffer% }"
    buffer="${buffer%;}"

    printf '%s\n' "$buffer"
}

# Optimize a file and output to stdout or file
# Usage: optimize_file input.sh [output.sh|-]
optimize_file() {
    local input_file="$1"
    local output_file="${2:-}"

    if [[ -z "$input_file" ]]; then
        echo "Error: No input file specified" >&2
        echo "Usage: optimize_file input.sh [output.sh|-]" >&2
        return 1
    fi

    if [[ ! -f "$input_file" ]]; then
        echo "Error: File not found: $input_file" >&2
        return 1
    fi

    # Run shellcheck and bail on errors
    local has_shellcheck=false
    command -v shellcheck >/dev/null 2>&1 && has_shellcheck=true

    if $has_shellcheck; then
        local sc_out sc_errors
        sc_out=$(shellcheck --format=gcc "$input_file" 2>&1)
        sc_errors=$(echo "$sc_out" | grep -c ': error:')

        if (( sc_errors > 0 )); then
            echo "Error: ShellCheck found $sc_errors error(s) in $input_file" >&2
            echo "" >&2
            shellcheck --color=auto --format=tty "$input_file" 2>&1 || true
            echo "" >&2
            echo "Optimization aborted. Fix the errors above and re-run." >&2
            return 1
        fi
    fi

    local content
    content=$(cat "$input_file")

    local optimized
    optimized=$(optimize_function "$content")

    # Validate syntax
    if ! bash -n <<< "$optimized" 2>/dev/null; then
        echo "Error: Optimization produced invalid syntax" >&2
        bash -n <<< "$optimized" 2>&1 | head -3 >&2
        if [[ -n "$output_file" ]]; then
            printf '%s\n' "$optimized" > "${output_file}.broken"
            echo "Debug: broken output written to ${output_file}.broken" >&2
        fi
        return 1
    fi

    if [[ "$output_file" == "-" ]] || [[ -z "$output_file" && ! -t 1 ]]; then
        # Output to stdout (explicit - or piped)
        printf '%s\n' "$optimized"
    elif [[ -n "$output_file" ]]; then
        printf '%s\n' "$optimized" > "$output_file"
        chmod +x "$output_file"
        echo "Optimized $input_file -> $output_file"
    else
        # Interactive stdout
        printf '%s\n' "$optimized"
    fi
}

# Minify a file and output to stdout or file
# Usage: minify_files input.sh [output.sh|-]
minify_files() {
    local input_file="$1"
    local output_file="${2:-}"

    if [[ -z "$input_file" ]]; then
        echo "Error: No input file specified" >&2
        echo "Usage: minify_files input.sh [output.sh|-]" >&2
        return 1
    fi

    if [[ ! -f "$input_file" ]]; then
        echo "Error: File not found: $input_file" >&2
        return 1
    fi

    # Run shellcheck and bail on errors
    local has_shellcheck=false
    command -v shellcheck >/dev/null 2>&1 && has_shellcheck=true

    if $has_shellcheck; then
        local sc_out sc_errors
        sc_out=$(shellcheck --format=gcc "$input_file" 2>&1)
        sc_errors=$(echo "$sc_out" | grep -c ': error:')

        if (( sc_errors > 0 )); then
            echo "Error: ShellCheck found $sc_errors error(s) in $input_file" >&2
            echo "" >&2
            shellcheck --color=auto --format=tty "$input_file" 2>&1 || true
            echo "" >&2
            echo "Minification aborted. Fix the errors above and re-run." >&2
            return 1
        fi
    fi

    local content
    content=$(cat "$input_file")

    local minified
    minified=$(minify "$content")

    # Validate syntax
    if ! bash -n <<< "$minified" 2>/dev/null; then
        echo "Error: Minification produced invalid syntax" >&2
        bash -n <<< "$minified" 2>&1 | head -3 >&2
        if [[ -n "$output_file" ]]; then
            printf '%s\n' "$minified" > "${output_file}.broken"
            echo "Debug: broken output written to ${output_file}.broken" >&2
        fi
        return 1
    fi

    if [[ "$output_file" == "-" ]] || [[ -z "$output_file" && ! -t 1 ]]; then
        # Output to stdout (explicit - or piped)
        printf '%s\n' "$minified"
    elif [[ -n "$output_file" ]]; then
        printf '%s\n' "$minified" > "$output_file"
        chmod +x "$output_file"
        echo "Minified $input_file -> $output_file"
    else
        # Default to <input_name>_min.sh for interactive use
        local default_output="${input_file%.sh}_min.sh"
        printf '%s\n' "$minified" > "$default_output"
        chmod +x "$default_output"
        echo "Minified $input_file -> $default_output"
    fi
}

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
        # Stderr is NOT redirected to show error messages for debugging
        "test::${fn}" </dev/null

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
    exit $?
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

if [[ ${1,,} == "optimize" ]]; then
    optimize_file "$2" "$3"
    exit $?
fi

if [[ ${1,,} == "minify" ]]; then
    minify_files "$2" "$3"
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
