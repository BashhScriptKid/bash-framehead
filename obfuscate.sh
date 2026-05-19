#!/usr/bin/env bash
# obfuscate.sh — standalone Bash obfuscator
#
# Renames functions, variables, and encodes string literals to make
# Bash scripts harder to reverse-engineer.
#
# Usage:
#   ./obfuscate.sh [options] input.sh [output.sh]
#   ./obfuscate.sh [options] -          # read from stdin
#
# Options:
#   --obfuscate=PASSES  Comma-separated list of passes to apply:
#                       all, private_functions, functions, local_variables,
#                       variables, strings
#                       (default: private_functions,local_variables)
#   --skip-minifier     Obfuscate raw source without minifying first
#   --check             Validate output syntax only, do not write
#   --verbose           Log every tokeniser/obfuscator decision to stderr
#   --quiet             Suppress progress output entirely
#
# When sourceable:
#   source ./obfuscate.sh
#   obfuscate "$content" passes_assoc_array
#
# Flag precedence: first flag specified wins (--verbose --quiet = verbose)
#
# Requires: bash 4.3+ (namerefs), base32 (GNU coreutils, build-time only)
# _minify_log_mode: unset = progress, "verbose" = verbose, "quiet" = quiet
_minify_log_mode=""
_progress_line=""        # current progress line content, for redraw after log lines
_progress_active=0       # 1 when cursor is hidden and progress is showing

# _B32D_HELPER — source text of the _b32d runtime decode helper.
# Embedded verbatim into obfuscated output when string encoding is active.
# Single-quoted heredoc prevents any expansion during assignment.
readonly _B32D_HELPER=$(cat << 'B32D_EOF'
_b32d() {
    local s="${1//=}" i
    local -i a b c d e f g h
    s="${s^^}"
    for (( i=0; i<${#s}; i+=8 )); do
        local c0="${s:$i:1}" c1="${s:$((i+1)):1}" c2="${s:$((i+2)):1}" c3="${s:$((i+3)):1}"
        local c4="${s:$((i+4)):1}" c5="${s:$((i+5)):1}" c6="${s:$((i+6)):1}" c7="${s:$((i+7)):1}"
        case "$c0" in A) a=0;; B) a=1;; C) a=2;; D) a=3;; E) a=4;; F) a=5;; G) a=6;; H) a=7;; I) a=8;; J) a=9;; K) a=10;; L) a=11;; M) a=12;; N) a=13;; O) a=14;; P) a=15;; Q) a=16;; R) a=17;; S) a=18;; T) a=19;; U) a=20;; V) a=21;; W) a=22;; X) a=23;; Y) a=24;; Z) a=25;; 2) a=26;; 3) a=27;; 4) a=28;; 5) a=29;; 6) a=30;; 7) a=31;; *) a=0;; esac
        case "$c1" in A) b=0;; B) b=1;; C) b=2;; D) b=3;; E) b=4;; F) b=5;; G) b=6;; H) b=7;; I) b=8;; J) b=9;; K) b=10;; L) b=11;; M) b=12;; N) b=13;; O) b=14;; P) b=15;; Q) b=16;; R) b=17;; S) b=18;; T) b=19;; U) b=20;; V) b=21;; W) b=22;; X) b=23;; Y) b=24;; Z) b=25;; 2) b=26;; 3) b=27;; 4) b=28;; 5) b=29;; 6) b=30;; 7) b=31;; *) b=0;; esac
        case "$c2" in A) c=0;; B) c=1;; C) c=2;; D) c=3;; E) c=4;; F) c=5;; G) c=6;; H) c=7;; I) c=8;; J) c=9;; K) c=10;; L) c=11;; M) c=12;; N) c=13;; O) c=14;; P) c=15;; Q) c=16;; R) c=17;; S) c=18;; T) c=19;; U) c=20;; V) c=21;; W) c=22;; X) c=23;; Y) c=24;; Z) c=25;; 2) c=26;; 3) c=27;; 4) c=28;; 5) c=29;; 6) c=30;; 7) c=31;; *) c=0;; esac
        case "$c3" in A) d=0;; B) d=1;; C) d=2;; D) d=3;; E) d=4;; F) d=5;; G) d=6;; H) d=7;; I) d=8;; J) d=9;; K) d=10;; L) d=11;; M) d=12;; N) d=13;; O) d=14;; P) d=15;; Q) d=16;; R) d=17;; S) d=18;; T) d=19;; U) d=20;; V) d=21;; W) d=22;; X) d=23;; Y) d=24;; Z) d=25;; 2) d=26;; 3) d=27;; 4) d=28;; 5) d=29;; 6) d=30;; 7) d=31;; *) d=0;; esac
        case "$c4" in A) e=0;; B) e=1;; C) e=2;; D) e=3;; E) e=4;; F) e=5;; G) e=6;; H) e=7;; I) e=8;; J) e=9;; K) e=10;; L) e=11;; M) e=12;; N) e=13;; O) e=14;; P) e=15;; Q) e=16;; R) e=17;; S) e=18;; T) e=19;; U) e=20;; V) e=21;; W) e=22;; X) e=23;; Y) e=24;; Z) e=25;; 2) e=26;; 3) e=27;; 4) e=28;; 5) e=29;; 6) e=30;; 7) e=31;; *) e=0;; esac
        case "$c5" in A) f=0;; B) f=1;; C) f=2;; D) f=3;; E) f=4;; F) f=5;; G) f=6;; H) f=7;; I) f=8;; J) f=9;; K) f=10;; L) f=11;; M) f=12;; N) f=13;; O) f=14;; P) f=15;; Q) f=16;; R) f=17;; S) f=18;; T) f=19;; U) f=20;; V) f=21;; W) f=22;; X) f=23;; Y) f=24;; Z) f=25;; 2) f=26;; 3) f=27;; 4) f=28;; 5) f=29;; 6) f=30;; 7) f=31;; *) f=0;; esac
        case "$c6" in A) g=0;; B) g=1;; C) g=2;; D) g=3;; E) g=4;; F) g=5;; G) g=6;; H) g=7;; I) g=8;; J) g=9;; K) g=10;; L) g=11;; M) g=12;; N) g=13;; O) g=14;; P) g=15;; Q) g=16;; R) g=17;; S) g=18;; T) g=19;; U) g=20;; V) g=21;; W) g=22;; X) g=23;; Y) g=24;; Z) g=25;; 2) g=26;; 3) g=27;; 4) g=28;; 5) g=29;; 6) g=30;; 7) g=31;; *) g=0;; esac
        case "$c7" in A) h=0;; B) h=1;; C) h=2;; D) h=3;; E) h=4;; F) h=5;; G) h=6;; H) h=7;; I) h=8;; J) h=9;; K) h=10;; L) h=11;; M) h=12;; N) h=13;; O) h=14;; P) h=15;; Q) h=16;; R) h=17;; S) h=18;; T) h=19;; U) h=20;; V) h=21;; W) h=22;; X) h=23;; Y) h=24;; Z) h=25;; 2) h=26;; 3) h=27;; 4) h=28;; 5) h=29;; 6) h=30;; 7) h=31;; *) h=0;; esac
        printf "\\$(printf '%03o' $(( (a << 3) | (b >> 2) )))"
        (( i+2 < ${#s} )) && printf "\\$(printf '%03o' $(( ((b & 3) << 6) | (c << 1) | (d >> 4) )))"
        (( i+4 < ${#s} )) && printf "\\$(printf '%03o' $(( ((d & 15) << 4) | (e >> 1) )))"
        (( i+5 < ${#s} )) && printf "\\$(printf '%03o' $(( ((e & 1) << 7) | (f << 2) | (g >> 3) )))"
        (( i+7 < ${#s} )) && printf "\\$(printf '%03o' $(( ((g & 7) << 5) | h )))"
    done
    echo
}
B32D_EOF
)

# _progress_render — build and overwrite the progress line in place
# Usage: _progress_render "label" current total [unit]
# unit defaults to "tokens". Emits nothing if not a TTY or quiet mode.
_progress_render() {
    [[ "$_minify_log_mode" == quiet ]] && return 0
    [[ -t 2 ]] || return 0
    local label="$1" cur="$2" total="$3" unit="${4:-tokens}"
    local pct=0 filled=0 bar="" empty
    local bar_width=40
    (( total > 0 )) && pct=$(( cur * 100 / total ))
    (( total > 0 )) && filled=$(( cur * bar_width / total ))
    (( filled > bar_width )) && filled=$bar_width
    empty=$(( bar_width - filled ))
    bar="$(printf '%*s' "$filled" '' | tr ' ' '=')"
    bar+="$(printf '%*s' "$empty" '')"
    _progress_line="$(printf '%s [%s] %d/%d %s (%d%%)' "$label" "$bar" "$cur" "$total" "$unit" "$pct")"
    # Hide cursor on first render
    if (( !_progress_active )); then
        printf '\033[?25l' >&2
        _progress_active=1
    fi
    printf '\r\033[2K%s' "$_progress_line" >&2
}

# _progress_done — restore cursor, erase progress line
# Always emits cursor-restore when stderr is a TTY — _progress_active flag is
# unreliable when _progress_render ran inside a subshell (minify/obfuscate).
_progress_done() {
    [[ "$_minify_log_mode" == quiet ]] && return 0
    [[ -t 2 ]] || return 0
    printf '\033[?25h' >&2   # restore cursor unconditionally
    printf '\r\033[2K' >&2   # erase progress line
    _progress_active=0
    _progress_line=""
}

# _log — emit a log line without stomping the progress bar
# In verbose mode: always prints. In progress mode: erases bar, prints, redraws bar.
# In quiet mode: suppressed.
_log() {
    [[ "$_minify_log_mode" == quiet ]] && return 0
    if [[ -t 2 ]] && (( _progress_active )); then
        printf '\r\033[2K%s\n' "$*" >&2     # erase progress, print log line
        printf '%s' "$_progress_line" >&2   # redraw progress on fresh line
    else
        printf '%s\n' "$*" >&2
    fi
}

_log_verbose() {
    [[ "$_minify_log_mode" == verbose ]] || return 0
    _log "$*"
}

# _log_progress / _log_progress_nl kept for call-site compat but now delegate
# to the new system. Call sites that know current/total should use _progress_render.
_log_progress() {
    [[ "$_minify_log_mode" == quiet ]] && return 0
    [[ "$_minify_log_mode" == verbose ]] && return 0
    [[ -t 2 ]] || return 0
    _progress_line="$*"
    if (( !_progress_active )); then
        printf '\033[?25l' >&2
        _progress_active=1
    fi
    printf '\r\033[2K%s' "$_progress_line" >&2
}

_log_progress_nl() {
    _progress_done
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
#   local -a tokens_type tokens_val
#   local token_count=0
#   tokenise "$source" tokens token_count
#
# With PE parsing:
#   local -a tokens_type tokens_val
#   local -A pe_table
#   local token_count=0
#   PARSE_PE=1 tokenise "$source" tokens token_count pe_table
#
# All helpers are private subfunctions of tokenise().

# ==============================================================================
# tokenise — main entry point
#
# Usage:
#   local -a tokens_type tokens_val
#   local token_count=0
#   tokenise "$source" tokens token_count [pe_table_name]
# ==============================================================================
tokenise() {
    local input="$1"
    # Parallel indexed arrays: caller passes a base name; we bind _tk_type and _tk_val
    # to <base>_type[] and <base>_val[] respectively.
    local -n _tk_type="${2}_type"
    local -n _tk_val="${2}_val"
    local -n _tc="$3"
    _tc=0

    # PE table — only active when PARSE_PE=1 and 4th arg provided
    local _pe_enabled=0
    local _pe_counter=0  # monotonic counter for pe_table keys, independent of _tc
    if [[ "${PARSE_PE:-0}" == "1" ]]; then
        if [[ -n "${4:-}" ]]; then
            local -n _pe_tbl="$4"
            _pe_enabled=1
        else
            echo "tokenise: PARSE_PE=1 requires a pe_table nameref as 4th argument — resetting PARSE_PE=0" >&2
            PARSE_PE=0
        fi
    fi

    # Local state variables
    local _src="" _pos=0 _li=0
    local _pending_heredoc=false _pending_marker="" _pending_has_dash=false
    local _sq_open=0  # set when _sq returned 94 (multi-line string in progress)
    local _dq_open=0  # set when _dq returned 94 (multi-line double-quoted string in progress)
    local -a _dq_stack=()  # quote stack, preserved across _dq line continuations
    local _dq_cmd_depth=0  # $( nesting depth inside _dq — suppresses quote stack while > 0
    local -a _case_stack=()  # case nesting stack; each entry is STATE (WORD/PAT/BODY); depth = stack length
    local -a _lines=()

    # --------------------------------------------------------------------------
    # _emit — append one token
    # --------------------------------------------------------------------------
    _emit() {
        _tk_type[_tc]="$1"
        _tk_val[_tc]="$2"
        _log_verbose "[Tokeniser] Tokenised '${2}' as ${1}"
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
            # When PARSE_PE active: call _paramexp for ${ inside DQ so pe_table
            # gets populated for embedded expansions — STRING_DQ still emitted as-is
            if [[ "$_pe_enabled" == "1" && "$c" == '$' && "${_src:i+1:1}" == '{' ]]; then
                local _dq_saved_pos=$_pos
                _pos=$i
                local _pe_dq_mode=1
                _paramexp
                i=$_pos
                _pos=$_dq_saved_pos
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
    #
    # Uses a serialised frame stack to track quote context across nested subshells.
    # Each frame is a serialised _dq_stack (entries joined by $'\x01').
    # Push on $(, pop on ) at depth 0 of the current frame.
    # This correctly handles ' inside "..." inside $(...) and arbitrary nesting.
    # --------------------------------------------------------------------------
    _cmdsub() {
        local _FSEP=$'\x01'  # frame serialisation delimiter — can't appear in quote chars

        # Frame stack: each entry is a serialised dq_stack for that subshell level
        # Index 0 = outermost $( ... ) frame
        local -a _fs=()       # frame stack (serialised dq_stacks)
        local -a _cur_dq=()   # current frame's dq_stack
        local _cur_sq=0       # single-quote open flag for current frame

        # Push the initial frame for the opening $(
        _fs+=("")             # empty dq_stack — fresh subshell context

        local body="" start_pos=$(( _pos + 2 ))
        local ci=$start_pos

        while true; do
            while (( ci < ${#_src} )); do
                local c="${_src:ci:1}"

                # Inside single-quoted string — only ' closes it
                if (( _cur_sq )); then
                    if [[ "$c" == "'" ]]; then
                        _cur_sq=0
                    fi
                    (( ci++ )); continue
                fi

                # Inside double-quoted string (cur_dq non-empty, top is ")
                if (( ${#_cur_dq[@]} > 0 )) && [[ "${_cur_dq[-1]}" == '"' ]]; then
                    if [[ "$c" == '\' ]]; then
                        (( ci += 2 )); continue  # skip escaped char
                    fi
                    if [[ "$c" == '$' && "${_src:ci+1:1}" == '(' ]]; then
                        # Nested $( inside "..." — push new frame
                        local _serial
                        printf -v _serial '%s' "${_cur_dq[*]+${_cur_dq[*]}}"
                        # Serialise: join with _FSEP
                        local _s="" _j
                        for _j in "${_cur_dq[@]}"; do _s+="${_FSEP}${_j}"; done
                        _fs+=("${_s:${#_FSEP}}")  # strip leading sep
                        _cur_dq=()
                        _cur_sq=0
                        (( ci += 2 )); continue
                    fi
                    if [[ "$c" == '"' ]]; then
                        unset '_cur_dq[-1]'  # close dq context
                    fi
                    (( ci++ )); continue
                fi

                # Backslash outside quotes — skip next char
                if [[ "$c" == '\' ]]; then
                    (( ci += 2 )); continue
                fi

                # Single-quote open
                if [[ "$c" == "'" ]]; then
                    _cur_sq=1; (( ci++ )); continue
                fi

                # Double-quote open
                if [[ "$c" == '"' ]]; then
                    _cur_dq+=('"'); (( ci++ )); continue
                fi

                # Nested $( — push new frame
                if [[ "$c" == '$' && "${_src:ci+1:1}" == '(' ]]; then
                    local _s="" _j
                    for _j in "${_cur_dq[@]}"; do _s+="${_FSEP}${_j}"; done
                    _fs+=("${_s:${#_FSEP}}")
                    _cur_dq=()
                    _cur_sq=0
                    (( ci += 2 )); continue
                fi

                # ( not preceded by $ — just depth within current frame
                if [[ "$c" == '(' ]]; then
                    local _s="" _j
                    for _j in "${_cur_dq[@]}"; do _s+="${_FSEP}${_j}"; done
                    _fs+=("${_s:${#_FSEP}}")
                    _cur_dq=()
                    _cur_sq=0
                    (( ci++ )); continue
                fi

                # ) — pop frame
                if [[ "$c" == ')' ]]; then
                    if (( ${#_fs[@]} == 1 )); then
                        # Closing the outermost $(  — we're done
                        body+="${_src:start_pos:ci-start_pos}"
                        _emit CMD_SUB "$(_lit "$body")"
                        _pos=$(( ci + 1 ))
                        return 0
                    fi
                    # Pop frame — restore parent dq_stack
                    local _top="${_fs[-1]}"
                    unset '_fs[-1]'
                    _cur_dq=()
                    _cur_sq=0
                    if [[ -n "$_top" ]]; then
                        local _old_IFS="$IFS"
                        IFS="$_FSEP" read -ra _cur_dq <<< "$_top"
                        IFS="$_old_IFS"
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
    #
    # When PARSE_PE=1, emits structured val: prefix\x1Ename\x1Eop\x1Eoperand
    # Otherwise emits raw interior (legacy behaviour).
    #
    # Structured fields:
    #   prefix  — leading # (length) or ! (indirect/nameref) or empty
    #   name    — variable/array name, including [idx] subscript if present
    #   op      — operator: :- := :+ :? : # ## % %% / // /# /% ^ ^^ , ,, @ or empty
    #   operand — remainder after op (pattern, word, offset, letter) or empty
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
        local _interior="${_src:_pos+2:i-_pos-2}"

        if [[ "$_pe_enabled" == "1" ]]; then
            local _pe_idx="$_pe_counter"
            local _pe_prefix _pe_name _pe_op _pe_operand
            _parse_pe "$_interior" _pe_prefix _pe_name _pe_op _pe_operand
            _pe_tbl[${_pe_idx}_prefix]="$_pe_prefix"
            _pe_tbl[${_pe_idx}_name]="$_pe_name"
            _pe_tbl[${_pe_idx}_op]="$_pe_op"
            _pe_tbl[${_pe_idx}_operand]="$_pe_operand"
            (( _pe_counter++ ))
            # In DQ context: populate pe_table only, don't emit a token
            # (the enclosing STRING_DQ token covers the whole quoted string)
            [[ "${_pe_dq_mode:-0}" != "1" ]] && _emit PARAM_EXP "__PE_${_pe_idx}__"
        else
            _emit PARAM_EXP "$_interior"
        fi
        _pos=$(( i + 1 ))
    }

    # --------------------------------------------------------------------------
    # _parse_pe — parse PE interior into four fields via namerefs (no subshell)
    #
    # Usage: _parse_pe raw out_prefix out_name out_op out_operand
    # Writes directly into the four caller-supplied variable names.
    # --------------------------------------------------------------------------
    _parse_pe() {
        local raw="$1"
        local -n _ppe_prefix="$2" _ppe_name="$3" _ppe_op="$4" _ppe_operand="$5"
        _ppe_prefix='' _ppe_name='' _ppe_op='' _ppe_operand=''
        local pos=0 len=${#raw}

        # ---- Extract prefix (# or !) ----
        local first="${raw:0:1}"
        if [[ "$first" == '!' ]]; then
            _ppe_prefix='!'
            (( pos++ ))
        elif [[ "$first" == '#' ]]; then
            local second="${raw:1:1}"
            case "$second" in
                [a-zA-Z_'['@'*']|'#')
                    _ppe_prefix='#'; (( pos++ )) ;;
            esac
        fi

        # ---- Extract name ----
        local name_start=$pos
        local in_subscript=0
        while (( pos < len )); do
            local c="${raw:pos:1}"
            if [[ "$c" == '[' ]]; then
                in_subscript=1; (( pos++ ))
            elif [[ "$c" == ']' ]]; then
                in_subscript=0; (( pos++ ))
            elif (( in_subscript )); then
                (( pos++ ))
            else
                case "$c" in
                    [a-zA-Z0-9_]) (( pos++ )) ;;
                    *) break ;;
                esac
            fi
        done
        _ppe_name="${raw:name_start:pos-name_start}"

        # ---- Extract operator ----
        (( pos >= len )) && return

        local c1="${raw:pos:1}"
        local c2="${raw:pos:2}"

        case "$c2" in
            ':-'|':='|':+'|':?')   _ppe_op="$c2"; (( pos += 2 )) ;;
            '//'|'/#'|'/%')        _ppe_op="$c2"; (( pos += 2 )) ;;
            '##'|'%%'|'^^'|',,')   _ppe_op="$c2"; (( pos += 2 )) ;;
            *)
                case "$c1" in
                    ':')  _ppe_op=':'; (( pos++ )) ;;
                    '#')  _ppe_op='#'; (( pos++ )) ;;
                    '%')  _ppe_op='%'; (( pos++ )) ;;
                    '/')  _ppe_op='/'; (( pos++ )) ;;
                    '^')  _ppe_op='^'; (( pos++ )) ;;
                    ',')  _ppe_op=','; (( pos++ )) ;;
                    '@')  _ppe_op='@'; (( pos++ )) ;;
                esac ;;
        esac

        # ---- Remainder is operand ----
        _ppe_operand="${raw:pos}"
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
                return ;;
            [a-zA-Z_])
                (( _pos++ ))
                while (( _pos < ${#_src} )); do
                    local c="${_src:_pos:1}"
                    case "$c" in
                        [a-zA-Z0-9_]) (( _pos++ )) ;;
                        *) break ;;
                    esac
                done ;;
            [1-9])
                (( _pos++ )) ;;
        esac
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
            ';;&') _emit OP  ';;&'; (( _pos += 3 )); (( ${#_case_stack[@]} )) && _case_stack[-1]="PAT"; return ;;
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
            ';;')  _emit OP  ';;'; (( _pos += 2 )); (( ${#_case_stack[@]} )) && _case_stack[-1]="PAT"; return ;;
            ';&')  _emit OP  ';&'; (( _pos += 2 )); (( ${#_case_stack[@]} )) && _case_stack[-1]="PAT"; return ;;
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
            case "$c" in
                ' '|$'\t'|$'\r'|$'\n'|';'|'|'|'&'|'<'|'>'|'('|')'|"'"|\"|'`'|'$'|'#'|'{'|'}'|'\')
                    break ;;
            esac
            (( _pos++ ))
        done
        local word="${_src:start:_pos-start}"
        [[ -z "$word" ]] && { (( _pos++ )); return; }

        if [[ "$word" =~ ^[0-9]+$ ]]; then
            local next_one="${_src:_pos:1}"
            case "$next_one" in
            '>'|'<')
                local _before=$_tc
                _op
                if (( _tc > _before )); then
                    local _rval="${word}${_tk_val[$(( _tc - 1 ))]}"
                    case "${_rval: -1}" in
                    '&')
                        local _rn="${_src:_pos:1}"
                        case "$_rn" in [0-9])
                            (( _pos++ ))
                            _rval+="${_src:_pos-1:1}"
                        esac ;;
                    esac
                    _tk_val[$(( _tc - 1 ))]="$_rval"
                fi
                return ;;
            esac
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
            while [[ "${_rx: -1}" == ' ' || "${_rx: -1}" == $'\t' ]]; do _rx="${_rx%?}"; done
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
            case)   _case_stack+=("WORD") ;;
            in)     (( ${#_case_stack[@]} )) && [[ "${_case_stack[-1]}" == "WORD" ]] && _case_stack[-1]="PAT" ;;
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
        # esac closes the case statement — pop the stack
        if [[ "${_src:_pos:4}" == "esac" && ( ${#_src} -eq _pos+4 || "${_src:_pos+4:1}" =~ [[:space:]\;] ) ]]; then
            (( ${#_case_stack[@]} )) && unset '_case_stack[-1]'
            return
        fi
        # comment — consume it directly (returning to _scan_line would re-enter _case_pat)
        if [[ "${_src:_pos:1}" == '#' ]]; then
            _comment
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
                if (( depth == 0 )); then
                    # This ) closes the arm pattern
                    buf="${_src:start:_pos-start}"
                    _emit REGEX_PATTERN "$buf"
                    _emit OP "CASE)"
                    (( _pos++ ))
                    _case_stack[-1]="BODY"
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
            if (( ${#_case_stack[@]} )) && [[ "${_case_stack[-1]}" == PAT ]]; then
                _case_pat; continue
            fi

            case "$c" in
            # Whitespace — skip (exclude \n which is an OP)
            ' '|$'\t'|$'\r')
                (( _pos++ )); continue ;;

            # Comment — only if not $#
            '#')
                local prev=""
                (( _pos > 0 )) && prev="${_src:_pos-1:1}"
                if [[ "$prev" != '$' ]]; then _comment; continue; fi ;;

            '$')
                # Expansions and variable refs — longest match first
                local three_c="${_src:_pos:3}"
                case "$three_c" in
                    '$((') _arith;    continue ;;
                esac
                case "$two" in
                    '$(') _cmdsub;   continue ;;
                    '${') _paramexp; continue ;;
                    "$'")
                        # $'...' ANSI-C quoted string
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
                        # EOL without closing ' — emit partial and consume rest of line
                        if (( _qs >= ${#_src} && _pos < ${#_src} )); then
                            _emit RICH_STRING "${_src:_pos}"
                            _pos=${#_src}
                        fi
                        continue ;;
                esac
                # Unbraced variable expansion
                local next="${_src:$(( _pos + 1 )):1}"
                case "$next" in
                    [a-zA-Z_]|'#'|'@'|'*'|'?'|'$'|'!'|'-'|'0'|[1-9])
                        _var_literal; continue ;;
                    *)
                        _emit WORD '$'; (( _pos++ )); continue ;;
                esac ;;

            # Quoted strings and backtick
            "'") _sq; [[ $? -eq 94 ]] && _sq_open=1; continue ;;
            '"') _dq_stack=(); _dq_cmd_depth=0; _dq
                 [[ $? -eq 94 ]] && _dq_open=1; continue ;;
            '`') _backtick; continue ;;

            # Operators
            ';'|'|'|'&'|'<'|'>'|'('|')'|'{'|'}'|'\'|$'\n')
                _op; continue ;;
            esac

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
        # Multi-line single-quoted string continuation
        if (( _sq_open )); then
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
                # Found closing ' — append prefix (with \n separator) and close
                _tk_val[_last]+=$'\n'"${_sq_line:0:_sq_close}"
                _sq_open=0
                # Remainder of the line needs normal tokenisation
                _src="${_sq_line:$(( _sq_close + 1 ))}"
                _pos=0
                _scan_line
            else
                # Still no closing ' — append whole line and keep waiting
                _tk_val[_last]+=$'\n'"$_sq_line"
            fi
            continue
        fi

        # Multi-line double-quoted string continuation
        if (( _dq_open )); then
            local _dq_line="${_lines[_li]}"
            (( _li++ ))
            local _last=$(( _tc - 1 ))
            # _pos=-1 so that _dq's (_pos+1) offset starts at char 0 of the continuation line,
            # and the interior slice (_src:_pos+1:i-_pos-1) correctly covers the whole line.
            # The \n separator is prepended to whatever _dq emits, then merged in.
            _src="$_dq_line"
            _pos=-1
            _dq
            if (( $? == 94 )); then
                # Still unclosed — prepend \n separator and merge partial into original token
                _tk_val[_last]+="\n${_tk_val[$(( _tc - 1 ))]}"
                (( _tc-- ))
            else
                # Closed — prepend \n separator and merge into original token
                _tk_val[_last]+="\n${_tk_val[$(( _tc - 1 ))]}"
                (( _tc-- ))
                _dq_open=0
            fi
            continue
        fi

        if $_pending_heredoc; then
            _heredoc_body "$_pending_marker" "$_pending_has_dash"
            _pending_heredoc=false
            _pending_marker=""
            _pending_has_dash=false
            continue
        fi

        _src="${_lines[_li]}"
        (( _li++ ))

        _progress_render "Tokenising..." "$_li" "${#_lines[@]}" "lines"
        (( _tc > 0 )) && _emit OP $'\n'
        _scan_line

        # Look back for HEREDOC_HEAD + TAG
        local _i=$(( _tc - 1 ))
        while (( _i >= 0 )); do
            local _t="${_tk_type[_i]}"
            [[ "$_t" == "OP" && "${_tk_val[_i]}" == $'\n' ]] && break
            if [[ "$_t" == "HEREDOC_HEAD" ]]; then
                # <<< is a herestring — no body/marker follows, skip pending
                [[ "${_tk_val[_i]}" == '<<<' ]] && break
                local _j=$(( _i + 1 ))
                while (( _j < _tc )); do
                    local _tj="${_tk_type[_j]}"
                    if [[ "$_tj" == "WORD" || "$_tj" == "STRING_SQ" || "$_tj" == "STRING_DQ" ]]; then
                        _tk_type[_j]="HEREDOC_TAG"
                        _pending_marker="${_tk_val[_j]}"
                        _pending_has_dash=false
                        [[ "${_tk_val[_i]}" == '<<-' ]] && _pending_has_dash=true
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

    # Post-processing: collapse consecutive newline tokens in-place
    # COMMENT tokens are preserved — callers decide whether to skip them
    local _raw_count=$_tc
    local _wi=0 _ri=0 _prev_nl=0
    for (( _ri=0; _ri<_raw_count; _ri++ )); do
        local _rtype="${_tk_type[_ri]}" _rval="${_tk_val[_ri]}"
        if [[ "$_rtype" == "OP" && "$_rval" == $'\n' ]]; then
            (( _prev_nl )) && continue
            _prev_nl=1
        else
            _prev_nl=0
        fi
        if (( _wi != _ri )); then
            _tk_type[_wi]="$_rtype"
            _tk_val[_wi]="$_rval"
        fi
        (( _wi++ ))
    done
    for (( _ri=_wi; _ri<_raw_count; _ri++ )); do
        unset "_tk_type[_ri]" "_tk_val[_ri]"
    done
    _tc=$_wi
    # Expose pe_counter via reserved key so callers do not need a 5th nameref
    [[ "$_pe_enabled" == "1" ]] && _pe_tbl[_count]="$_pe_counter"
}

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
    # Optional pre-built token arrays: minify "src" tokens token_count
    # If provided, skip internal tokenisation (shared pipeline path).
    local token_count=0
    if [[ -n "${2:-}" ]]; then
        local -n tokens_type="${2}_type" tokens_val="${2}_val" _mf_tc="$3"
        token_count=$_mf_tc
        _log_verbose "[Minifier] Using pre-built token arrays (${token_count} tokens)"
    else
        local -a tokens_type=() tokens_val=()
        _log_verbose "[Minifier] Starting tokenisation..."
        tokenise "$input" tokens token_count
        _log_verbose "[Minifier] Tokenisation complete: ${token_count} tokens"
    fi

    # COMMENT tokens are skipped during emit — newline collapse handled by tokenise

    # Build minified output from tokens
    local -a parts=()          # accumulator — O(1) append, joined once at end
    local _last_was_space=0    # true when last appended element was whitespace
    local prev_type="" prev_val=""
    local i=0
    local _paren_stack=()    # Stack of paren contexts: 'subshell' | 'array' | 'funcdef'
    local array_depth=0      # Track depth inside [[]] for conditionals
    local bracket_depth=0    # Track depth inside [] for array subscripts
    local brace_expand=0     # Set when { follows a word/string (brace expansion, not command group)

    # --------------------------------------------------------------------------
    # _update_depth — track bracket/paren depth for array/subshell handling
    # --------------------------------------------------------------------------
    _update_depth() {
        local type="$1" val="$2"
        if [[ "$type" == "OP" ]]; then
            case "$val" in
                '(')
                    # Classify paren context from prev token:
                    # - assign LHS (ends with =) → array literal
                    # - immediately closed ()   → funcdef (handled at ) time)
                    # - otherwise               → subshell
                    if [[ "$prev_type" == WORD && "$prev_val" =~ ([a-zA-Z0-9_]|\]|\+)=$ ]]; then
                        _paren_stack+=('array')
                    else
                        _paren_stack+=('subshell')
                    fi
                    ;;
                ')')
                    # Collapse funcdef: if stack top is 'subshell' but prev_val was '('
                    # (empty parens f()) reclassify as funcdef
                    if (( ${#_paren_stack[@]} )); then
                        if [[ "${_paren_stack[-1]}" == subshell && "$prev_val" == '(' ]]; then
                            _paren_stack[-1]='funcdef'
                        fi
                        unset '_paren_stack[-1]'
                    fi
                    ;;
                '[')  (( bracket_depth++ )) ;;
                ']')  (( bracket_depth > 0 )) && (( bracket_depth-- )) ;;
            esac
        elif [[ "$type" == "WORD" ]]; then
            case "$val" in
                '[[') (( array_depth++ )) ;;
                ']]') (( array_depth > 0 )) && (( array_depth-- )) ;;
            esac
        fi
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
                    # Multi-line — convert to $'...' so output stays on one line
                    local _sq="$val"
                    _sq="${_sq//\\/\\\\}"  # \ → \\
                    _sq="${_sq//'/\\'}"        # ' → \'
                    _sq="${_sq//$'\n'/\\n}"    # real newline → \n
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
                elif [[ "$prev_type" == "OP" && ( "$prev_val" == ';' || "$prev_val" == $'\n' || "$prev_val" == '{' || "$prev_val" == '(' || "$prev_val" == ';;' || "$prev_val" == ';;&' || "$prev_val" == ';&' || "$prev_val" == 'CASE)' || "$prev_val" == '&&' || "$prev_val" == '||' || "$prev_val" == '|' ) ]]; then
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

        # Never insert semi when prev is already a statement separator
        [[ "$prev_type" == "OP" && "$prev_val" == ';' ]] && return 0

        # Never insert semi around REGEX_PATTERN
        [[ "$curr_type" == "REGEX_PATTERN" ]] && return 0
        [[ "$prev_type" == "REGEX_PATTERN" ]] && return 0

        # Never insert semi around heredoc tokens
        [[ "$curr_type" =~ ^HEREDOC ]] && return 0
        [[ "$prev_type" =~ ^(HEREDOC_TAG|HEREDOC_HEAD)$ ]] && return 0

        # No semi after background operator
        [[ "$prev_type" == "OP" && "$prev_val" == "&" ]] && return 0

        # No semi before closing parens
        [[ "$curr_type" == "OP" && "$curr_val" == ")" ]] && return 0
        # Allow semicolons before } - Bash requires semicolon or newline before } in function bodies

        # No semi before block STARTERS (then/do/in) - they follow conditionals
        [[ "$curr_type" == "WORD" && "$curr_val" =~ ^(then|do|in)$ ]] && return 0

        # No semi after opening braces/parens
        [[ "$prev_type" == "OP" && "$prev_val" == "(" ]] && return 0
        [[ "$prev_type" == "OP" && "$prev_val" == "{" ]] && return 0

        # No semi after block keywords (then/do/in/else/elif)
        [[ "$prev_type" == "WORD" && "$prev_val" =~ ^(then|do|in|else|elif)$ ]] && return 0

        # No semi after case operators or case arm terminator
        [[ "$prev_type" == "OP" && "$prev_val" =~ ^(;;|;;&|;&|CASE\))$ ]] && return 0

        # No semi before case operators or case arm terminator
        [[ "$curr_type" == "OP" && "$curr_val" =~ ^(;;|;;&|;&|CASE\))$ ]] && return 0

        # No semi after heredoc
        [[ "$prev_type" == "HEREDOC_TAIL" ]] && return 0

        # No semi after && or || or | (they continue the expression)
        [[ "$prev_type" == "OP" && "$prev_val" == "&&" ]] && return 0
        [[ "$prev_type" == "OP" && "$prev_val" == "||" ]] && return 0
        [[ "$prev_type" == "OP" && "$prev_val" == "|"  ]] && return 0

        return 1  # Default: add semi (including before fi/done/esac)
    }

    # --------------------------------------------------------------------------
    # _needs_space — should a space be emitted between prev and curr token?
    # Returns 0 (true) = emit space, 1 (false) = no space.
    #
    # Organised in four sections:
    #   1. Context overrides  — in_cond / brace_expand take priority
    #   2. Assignment RHS     — unified check for var=RHS, no-space attachment
    #   3. Prev-token rules   — space required AFTER a given prev token type/val
    #   4. Curr-token rules   — space required BEFORE a given curr token type/val
    # Default: no space.
    # --------------------------------------------------------------------------
    _needs_space() {
        local prev_type="$1" prev_val="$2" curr_type="$3" curr_val="$4" \
              in_cond="${5:-0}" brace_expand="${6:-0}" pre_paren_top="${7:-}" post_paren_top="${8:-}"

        # ---- 1. Context overrides --------------------------------------------

        # Inside a brace expansion — no space after the opening {
        (( brace_expand )) && return 1

        # Array subscript context — prev WORD ends with single [ (e.g. arr[) but not [[
        # No space between the [ and its content, or between content and ]=
        [[ "$prev_type" == WORD && "$prev_val" == *'[' && "$prev_val" != *'[['  ]] && return 1
        [[ "$curr_type" == WORD && "$curr_val" =~ ^\](\+?=) && "$prev_type" != OP ]] && return 1

        # Inside [[ ]] — < and > are string comparisons, not redirects
        if (( in_cond )); then
            [[ "$curr_type" == REDIRECT && ( "$curr_val" == '<' || "$curr_val" == '>' ) ]] && return 0
            [[ "$prev_type" == REDIRECT && ( "$prev_val" == '<' || "$prev_val" == '>' ) ]] && return 0
        fi

        # ---- 2. Assignment RHS — no space between var= and its value --------
        # Applies outside [[ ]] only (inside, = is a comparison operator).
        # Pattern: WORD ending with [ident]= or ]+= or ]= (covers var= arr+= arr[i]=)
        local _assign_lhs=''
        (( in_cond == 0 )) && [[ "$prev_type" == WORD ]] && \
            [[ "$prev_val" =~ ([a-zA-Z0-9_]|\]|\+)=$ ]] && \
            _assign_lhs=1

        if [[ -n "$_assign_lhs" ]]; then
            # RHS token types that attach directly
            [[ "$curr_type" =~ ^(PARAM_EXP|VAR_LITERAL|ARITH|CMD_SUB|RICH_STRING)$ ]] && return 1
            [[ "$curr_type" =~ ^STRING                                              ]] && return 1
            [[ "$curr_type" == OP && "$curr_val" == '('                             ]] && return 1
            # WORD after = still needs space (e.g. IFS= read, var= word)
        fi

        # ---- 3. Prev-token rules — space after prev --------------------------

        # After any WORD that is a block keyword or conditional bracket
        [[ "$prev_type" == WORD ]] && case "$prev_val" in
            then|do|in|else|elif|\[\[|\]\]|=~) return 0 ;;
        esac

        # After OP tokens that open or separate
        [[ "$prev_type" == OP ]] && case "$prev_val" in
            '{')        return 0 ;;   # { cmd  — command group body
            '(')        # Space after ( for subshell only; not funcdef f() or array arr=(
                        [[ "$post_paren_top" == subshell ]] && return 0
                        return 1 ;;
            '&')        return 0 ;;   # cmd& next  — background then next cmd
            ';')        return 0 ;;   # ; next  — statement separator
            '&&'|'||')  return 0 ;;   # boolean operators
            ';;'|';;&'|';&') return 0 ;; # case arm terminators
            'CASE)')    return 0 ;;   # case pattern ) body
        esac

        # After expansion/substitution tokens
        [[ "$prev_type" == ARITH    && "$curr_type" != OP ]] && return 0
        [[ "$prev_type" == CMD_SUB  && "$curr_type" != OP ]] && return 0
        [[ "$prev_type" == PROC_SUB && "$curr_type" != OP ]] && return 0
        [[ "$prev_type" == PARAM_EXP && "$curr_type" == WORD ]] && return 0
        [[ "$prev_type" == VAR_LITERAL && "$curr_type" == WORD ]] && return 0

        # After ) — function def ) { or ) word
        [[ "$prev_type" == OP && "$prev_val" == ')' ]] && {
            [[ "$curr_type" == OP   && "$curr_val" == '{' ]] && return 0
            [[ "$curr_type" == WORD                       ]] && return 0
        }

        # After REGEX_PATTERN — space before ]] or next token; CASE) attaches directly
        [[ "$prev_type" == REGEX_PATTERN ]] && {
            [[ "$curr_type" == OP && "$curr_val" == 'CASE)' ]] && return 1
            return 0
        }

        # After string-like tokens before words/strings that need separation
        [[ "$prev_type" =~ ^(STRING_SQ|STRING_DQ|RICH_STRING)$ ]] && {
            [[ "$curr_type" == WORD && "$curr_val" != '*' ]] && return 0
            [[ "$curr_type" =~ ^(STRING_SQ|STRING_DQ|RICH_STRING)$ ]] && return 0
        }

        # REDIRECT target attaches directly (2>/dev/null, >>file) — explicit no-space
        [[ "$prev_type" == REDIRECT && "$curr_type" == WORD ]] && return 1

        # ---- 4. Curr-token rules — space before curr ------------------------

        # Before block keywords
        [[ "$curr_type" == WORD ]] && case "$curr_val" in
            then|do|in) return 0 ;;
            ']]') return 0 ;;   # space before ]] closing conditional
        esac

        # Before OP tokens that need breathing room
        [[ "$curr_type" == OP ]] && case "$curr_val" in
            '&&'|'||')           return 0 ;;
            ';;'|';;&'|';&')     return 0 ;;
            '(')  # Space before ( for subshell openers — not for func def or array assign
                  # Subshell ( follows: keyword, OP, or start-of-input
                  [[ -n "$_assign_lhs" ]] && return 1   # arr=( — no space
                  [[ "$prev_type" == WORD ]] && case "$prev_val" in
                      if|while|until|for|then|do|else|elif|'!') return 0 ;;
                  esac
                  [[ "$prev_type" == OP ]] && return 0
                  [[ -z "$prev_type"   ]] && return 0
                  return 1 ;;
            ')')  # Space before ) for subshell close only
                  # paren_top is the pre-update stack top (before _update_depth popped it)
                  [[ "$pre_paren_top" == subshell ]] && return 0
                  return 1 ;;
            '{')  # Space before { — command group (after keyword/OP) but not brace expansion
                  # Brace expansion: prev is string/var (already handled by brace_expand flag)
                  # Bare word before {: e.g. echo {A,B} — needs space
                  [[ "$prev_type" == WORD && -z "$_assign_lhs" ]] && return 0 ;;
            '}')  [[ "$prev_type" == OP && "$prev_val" == ';' ]] && return 0
                  [[ "$prev_type" != OP ]] && return 0 ;;
        esac

        # Before expansion tokens (when not following an OP)
        [[ "$curr_type" == ARITH    && "$prev_type" != OP ]] && return 0
        [[ "$curr_type" == PROC_SUB                       ]] && return 0
        [[ "$curr_type" == REGEX_PATTERN                  ]] && return 0

        # Before strings/expansions following a plain WORD (not assign, not glob)
        [[ "$prev_type" == WORD && -z "$_assign_lhs" && "$prev_val" != '*' ]] && {
            [[ "$curr_type" =~ ^(STRING_SQ|STRING_DQ|RICH_STRING)$ ]] && return 0
            [[ "$curr_type" =~ ^(PARAM_EXP|VAR_LITERAL|CMD_SUB)$  ]] && return 0
            [[ "$curr_type" == REDIRECT                            ]] && return 0
            [[ "$curr_type" == HEREDOC_HEAD                        ]] && return 0
        }

        # WORD WORD always needs space
        [[ "$prev_type" == WORD && "$curr_type" == WORD ]] && return 0

        return 1  # Default: no space
    }

    # --------------------------------------------------------------------------
    # Main token processing loop
    # --------------------------------------------------------------------------
    _log_verbose "[Minifier] Starting token processing loop (${token_count} tokens)..."
    while (( i < token_count )); do
        local type="${tokens_type[i]}"
        local val="${tokens_val[i]}"
        (( i++ ))

        # Skip comments — preserved in token stream for other consumers
        [[ "$type" == "COMMENT" ]] && { _log_verbose "[Minifier] Skipping COMMENT token '${val:0:50}...'"; continue; }

        # Handle newlines: convert to semicolons (conservative default)
        if [[ "$type" == "OP" && "$val" == $'\n' ]]; then
            # Backslash continuation — strip the \ already in parts and join with space
            if [[ "$prev_type" == "OP" && "$prev_val" == '\' ]]; then
                parts[-1]="${parts[-1]%\\}"
                parts+=(" "); _last_was_space=1
                prev_type=""
                prev_val=""
                _update_depth "$type" "$val"
                continue
            fi

            # Preserve newline after HEREDOC_TAIL
            if [[ "$prev_type" == "HEREDOC_TAIL" ]]; then
                parts+=($'\n'); _last_was_space=1
                prev_type=""
                prev_val=""
                _update_depth "$type" "$val"
                continue
            fi

            # Skip consecutive newlines
            while (( i < token_count )); do
                local next_type="${tokens_type[i]}"
                local next_val="${tokens_val[i]}"
                [[ "$next_type" == "OP" && "$next_val" == $'\n' ]] && { (( i++ )); continue; }
                break
            done

            # Inside brackets/parens (arrays), use space instead of semicolon
            if (( ${#_paren_stack[@]} > 0 || array_depth > 0 || bracket_depth > 0 )); then
                parts+=(" "); _last_was_space=1
                prev_type="OP"; prev_val=" "
            elif [[ -n "$prev_type" ]] && (( !_last_was_space )); then
                if (( i < token_count )); then
                    local next_type="${tokens_type[i]}"
                    local next_val="${tokens_val[i]}"
                    # else\nif is genuinely nested (not elif) — keep newline so shellcheck
                    # doesn't flag SC1075 "use elif instead of else if"
                    if [[ "$prev_val" == "else" && "$next_type" == "WORD" && "$next_val" == "if" ]]; then
                        parts+=($'\n'); _last_was_space=1
                        _log_verbose "[Minifier] Preserving newline for else-if pattern"
                        prev_type="OP"; prev_val=$'\n'
                    elif ! _skip_semi "$prev_type" "$prev_val" "$next_type" "$next_val"; then
                        parts+=("; "); _last_was_space=1
                        _log_verbose "[Minifier] Inserting semicolon between ${prev_type}(${prev_val}) and ${next_type}(${next_val})"
                        prev_type="OP"; prev_val=";"
                    else
                        _log_verbose "[Minifier] Skipping semicolon between ${prev_type}(${prev_val}) and ${next_type}(${next_val})"
                    fi
                fi
            fi
            _update_depth "$type" "$val"
            continue
        fi

        # Update depth tracking before processing token
        local pre_paren_depth=${#_paren_stack[@]}
        local pre_paren_top="${_paren_stack[$((pre_paren_depth > 0 ? pre_paren_depth-1 : 0))]:-}"
        _update_depth "$type" "$val"
        local post_paren_depth=${#_paren_stack[@]}
        local post_paren_top="${_paren_stack[$((post_paren_depth > 0 ? post_paren_depth-1 : 0))]:-}"

        # Add space if needed
        if [[ -n "$prev_type" ]] && (( !_last_was_space )); then
            if _needs_space "$prev_type" "$prev_val" "$type" "$val" "$array_depth" "$brace_expand" "$pre_paren_top" "$post_paren_top"; then
                _log_verbose "[Minifier] Adding space for ${prev_type}(${prev_val})-${type}(${val}) pattern"
                parts+=(" "); _last_was_space=1
            else
                _log_verbose "[Minifier] No space for ${prev_type}(${prev_val})-${type}(${val}) pattern"
            fi
        fi

        # Append token
        local _tok_str
        _tok_str="$(_token_to_string "$type" "$val")"
        parts+=("$_tok_str"); _last_was_space=0
        _log_verbose "[Minifier] Appended '${val}' (${type}), parts: ${#parts[@]}"
        _progress_render "Minifying..." "$i" "$token_count"

        # Track brace expansion: { directly after an expansion/string token = brace expansion.
        # Bare WORD before { is always a command group in minified output — never set brace_expand.
        if [[ "$type" == "OP" && "$val" == "{" ]]; then
            if [[ "$prev_type" =~ ^(STRING_DQ|STRING_SQ|VAR_LITERAL|PARAM_EXP|RICH_STRING)$ ]]; then
                brace_expand=1
            else
                brace_expand=0
            fi
        else
            brace_expand=0
        fi
        prev_type="$type"
        prev_val="$val"
    done

    # One-time join — O(N) single pass, happens exactly once.
    # printf '%s' "${parts[@]}" concatenates all elements with no separator.
    local buffer
    buffer="$(printf '%s' "${parts[@]}")"

    # Trim leading/trailing space and any trailing semicolon from a real ; token at end of source
    buffer="${buffer# }"
    buffer="${buffer% }"
    buffer="${buffer%;}"

    printf '%s\n' "$buffer"
}





# obfuscate — main entry point
# Usage: obfuscate "content" passes_nameref
#   passes_nameref: associative array with keys: private_functions functions
#                   local_variables variables strings
#                   values: 1 = enabled, 0 = disabled
obfuscate() {
    # ---- Subfunctions ----
    # ==============================================================================
    # ==============================================================================
    # OBFUSCATOR
    # ==============================================================================
    #
    # Renames symbols and encodes strings to make output harder to reverse-engineer.
    #
    # Passes (controlled via --obfuscate flag):
    #   private_functions  — rename _name style functions → _f0, _f1, ...  (default)
    #   functions          — rename ALL functions regardless of naming
    #   local_variables    — rename all local vars → _v0, _v1, ...         (default)
    #   variables          — rename globals (bare VAR=, VAR+=, excl. export)
    #   strings            — encode STRING_SQ/STRING_DQ via base32 + baked _b32d helper
    #   all                — enable all passes
    #
    # Pipeline: [minify →] obfuscate
    # --skip-minifier runs obfuscation on raw/formatted source directly.
    #
    # Usage: obfuscate "content" passes_array_nameref
    # ==============================================================================

    # _ob_encode_string — base32-encode a string value for the strings pass
    # Usage: _ob_encode_string "raw string value"
    # Output: printf '%s' "$(_b32d "BASE32==")"
    _ob_encode_string() {
        local val="$1"
        local encoded
        encoded=$(printf '%s' "$val" | base32)
        # Produces: "$(_b32d "BASE32==")"
        # The result is used as a drop-in replacement for a quoted string literal
        printf '"$(_b32d "%s")"' "$encoded"
    }

    local src="$1"
    local -n _passes="$2"
    # Optional pre-built token arrays: obfuscate "src" passes tokens token_count pe_table
    # If provided, skip internal tokenisation (shared pipeline path).
    # Arrays declared in exactly one branch to avoid -a/-n redeclaration conflict.
    local token_count=0
    if [[ -n "${3:-}" ]]; then
        local -n tokens_type="${3}_type" tokens_val="${3}_val" _pe_table="$5" _ob_tc="$4"
        token_count=$_ob_tc
        _log_verbose "[Obfuscator] Using pre-built token arrays (${token_count} tokens)"
    else
        local -a tokens_type=() tokens_val=()
        local -A _pe_table=()
        _log_verbose "[Obfuscator] Starting tokenisation with PARSE_PE=1..."
        PARSE_PE=1 tokenise "$src" tokens token_count _pe_table
        _log_verbose "[Obfuscator] Tokenisation complete: ${token_count} tokens"
    fi

    local _do_privfn=0  _do_fns=0  _do_lvar=0  _do_vars=0  _do_strings=0
    [[ "${_passes[private_functions]:-0}" == 1 ]] && _do_privfn=1
    [[ "${_passes[functions]:-0}"         == 1 ]] && _do_fns=1
    [[ "${_passes[local_variables]:-0}"   == 1 ]] && _do_lvar=1
    [[ "${_passes[variables]:-0}"         == 1 ]] && _do_vars=1
    [[ "${_passes[strings]:-0}"           == 1 ]] && _do_strings=1
    # Optional 6th arg: skip_minifier flag — controls comment strip pass
    local skip_minifier="${6:-0}"

    # ------------------------------------------------------------------
    # Name generators
    # ------------------------------------------------------------------
    _fn_name() { printf '_f%d' "$1"; }
    _vn_name() { printf '_v%d' "$1"; }
    _gn_name() { printf '_g%d' "$1"; }

    # ------------------------------------------------------------------
    # Pass 1 — build rename maps
    # ------------------------------------------------------------------
    local -A _fn_map=()       # original fn name → _fN
    local -A _var_map=()      # funcidx:varname  → _vN
    local -A _gvar_map=()     # global varname   → _gN
    local _fn_counter=0
    local _cur_fn_idx=-1
    local -a _fn_idx_map=()
    local _fn_def_count=0
    local _local_counter=0
    local _gvar_counter=0
    local -a _fn_order=()

    # ------------------------------------------------------------------
    # Reserved keywords — words that are control-flow keywords in normal
    # usage but *can* be shadowed by actual function definitions.
    # When a function "keyword()" is detected, we remove the keyword from
    # this set so subsequent bare uses get renamed too.
    # ------------------------------------------------------------------
    local -A _reserved_kw=(
        [if]=1 [then]=1 [else]=1 [elif]=1 [fi]=1
        [for]=1 [while]=1 [until]=1 [do]=1 [done]=1
        [case]=1 [esac]=1 [in]=1
        [function]=1 [select]=1 [coproc]=1 [time]=1
        [[=1 ]]=1
    )

    local i type val prev_type='' prev_val=''
    local _in_local=0
    local _in_fn=0            # 1 when inside a function body (brace depth tracking)
    local _brace_depth=0

    _log_verbose "[Obfuscator] Pass 1: Building rename maps (private_functions=${_do_privfn}, functions=${_do_fns}, local_variables=${_do_lvar}, variables=${_do_vars}, strings=${_do_strings})..."

    for (( i=0; i<token_count; i++ )); do
        type="${tokens_type[i]}"
        val="${tokens_val[i]}"

        # Track brace depth to distinguish global vs function scope
        if [[ "$type" == OP ]]; then
            case "$val" in
                '{') (( _brace_depth++ )); (( _brace_depth == 1 && _cur_fn_idx >= 0 )) && _in_fn=1 ;;
                '}') (( _brace_depth > 0 )) && (( _brace_depth-- ))
                     (( _brace_depth == 0 )) && { _in_fn=0; _cur_fn_idx=-1; } ;;
            esac
        fi

        # ---- Detect function definition ----
        local _is_fn_def=0
        if [[ "$type" == WORD ]]; then
            local _is_priv=0
            [[ "$val" =~ ^_ ]] && _is_priv=1

            # Assignment tokens (var=, var+=) are NOT function names — but they
            # still need local/global var detection, so only skip fn detection.
            if [[ "$val" != *=* ]]; then
                # Reserved keywords are never functions — but if the source actually
                # defines "then()" or "function do { ... }", detect that first,
                # then whitelist the keyword so subsequent bare uses get renamed.
                if [[ -n "${_reserved_kw[$val]+x}" ]]; then
                    # Check if this LOOKS like a fn def before skipping
                    local _looks_like_fn=0
                    if [[ "$prev_type" == WORD && "$prev_val" == function ]]; then
                        _looks_like_fn=1
                    elif (( i+2 < token_count )); then
                        # fname() — must have ( immediately followed by )
                        [[ "${tokens_type[$((i+1))]}" == OP && "${tokens_val[$((i+1))]}" == '(' && \
                           "${tokens_type[$((i+2))]}" == OP && "${tokens_val[$((i+2))]}" == ')' ]] && \
                            _looks_like_fn=1
                    fi
                    if (( _looks_like_fn && (_do_fns || (_do_privfn && _is_priv)) )); then
                        # Shadowing a keyword — whitelist it for subsequent occurrences
                        unset '_reserved_kw[$val]'
                        _is_fn_def=1
                        _log_verbose "[Obfuscator] Keyword '${val}' shadowed by function definition — whitelisted for renaming"
                    fi
                elif [[ "$prev_type" == WORD && "$prev_val" == function ]]; then
                    # function fname style
                    (( _do_fns || (_do_privfn && _is_priv) )) && _is_fn_def=1
                elif (( i+2 < token_count )); then
                    local _peek_type="${tokens_type[$((i+1))]}"
                    local _peek_val="${tokens_val[$((i+1))]}"
                    # fname() — require ( immediately followed by ) (not a subshell)
                    if [[ "$_peek_type" == OP && "$_peek_val" == '(' && \
                          "${tokens_type[$((i+2))]}" == OP && "${tokens_val[$((i+2))]}" == ')' ]]; then
                        (( _do_fns || (_do_privfn && _is_priv) )) && _is_fn_def=1
                    fi
                fi
            fi
        fi

        if (( _is_fn_def )); then
            if [[ -z "${_fn_map[$val]+x}" ]]; then
                _fn_map[$val]="$(_fn_name $_fn_counter)"
                _fn_order+=("$val")
                (( _fn_counter++ ))
                _log_verbose "[Obfuscator] Mapping function: ${val} → ${_fn_map[$val]}"
            fi
            _cur_fn_idx=$_fn_def_count
            _fn_idx_map[$_cur_fn_idx]="$val"
            (( _fn_def_count++ ))
            _local_counter=0
            _in_local=0
        fi

        # ---- Detect local declarations ----
        if [[ "$type" == WORD && "$val" == local ]]; then
            _in_local=1
            prev_type="$type"; prev_val="$val"
            continue
        fi

        if (( _in_local && _do_lvar )); then
            if [[ "$type" == WORD ]]; then
                [[ "$val" =~ ^-[a-zA-Z]+$ ]] && { prev_type="$type"; prev_val="$val"; continue; }
                local _vname="${val%%=*}"
                if [[ -z "${_var_map[${_cur_fn_idx}:${_vname}]+x}" && "$_cur_fn_idx" -ge 0 ]]; then
                    _var_map[${_cur_fn_idx}:${_vname}]="$(_vn_name $_local_counter)"
                    _log_verbose "[Obfuscator] Mapping local: ${_vname} → ${_var_map[${_cur_fn_idx}:${_vname}]}"
                    (( _local_counter++ ))
                fi
            elif [[ "$type" == OP && ( "$val" == ';' || "$val" == $'\n' ) ]]; then
                _in_local=0
            fi
        elif (( _in_local )); then
            # _do_lvar off — still need to close _in_local state
            [[ "$type" == OP && ( "$val" == ';' || "$val" == $'\n' ) ]] && _in_local=0
        fi

        # ---- Detect global variable assignments ----
        # Pattern: WORD ending in = or += at global scope (not inside function, not export)
        if (( _do_vars && !_in_fn && _brace_depth == 0 )); then
            if [[ "$type" == WORD && "$val" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)(\+?=) ]]; then
                local _gvname="${BASH_REMATCH[1]}"
                # Skip if previous token was 'export'
                if [[ "$prev_val" != export && -z "${_gvar_map[$_gvname]+x}" ]]; then
                    _gvar_map[$_gvname]="$(_gn_name $_gvar_counter)"
                    _log_verbose "[Obfuscator] Mapping global: ${_gvname} → ${_gvar_map[$_gvname]}"
                    (( _gvar_counter++ ))
                fi
            fi
        fi

        prev_type="$type"; prev_val="$val"
        _progress_render "Obfuscating (pass 1)..." "$i" "$token_count"
    done

    _log_verbose "[Obfuscator] Pass 1 complete: ${_fn_counter} functions, ${#_var_map[@]} locals, ${_gvar_counter} globals"

    # ------------------------------------------------------------------
    # Pass 2 — token-walk rename
    # Build _replacements[old]=new from token stream (token-guided, no
    # false matches in comments/strings since those types are skipped).
    # Then apply as targeted string substitutions to result.
    # ------------------------------------------------------------------
    local result="$src"
    _log_verbose "[Obfuscator] Pass 2: Building token-guided replacement map..."

    # _replacements: old_text → new_text (applied to result string)
    # _repl_order: insertion-ordered keys for longest-first application
    local -A _replacements=()
    local -a _repl_order=()

    local _p2i _p2t _p2v _p2pt='' _p2pv=''
    for (( _p2i=0; _p2i<token_count; _p2i++ )); do
        _p2t="${tokens_type[_p2i]}"
        _p2v="${tokens_val[_p2i]}"

        # Skip token types whose content must never be renamed
        case "$_p2t" in
            COMMENT|STRING_SQ|RICH_STRING|HEREDOC_BODY|HEREDOC_TAG|HEREDOC_TAIL)
                _p2pt="$_p2t"; _p2pv="$_p2v"; continue ;;
        esac

        case "$_p2t" in
        STRING_DQ)
            # Scan DQ val for $varname patterns — rename any that are in the maps.
            # Replacement key is the full quoted string so it matches precisely in result.
            if (( _do_lvar || _do_vars )); then
                local _dq_new="$_p2v" _dq_changed=0
                local _dq_rest="$_p2v" _dq_vname _dq_repl _dq_vk
                while [[ "$_dq_rest" =~ \$([a-zA-Z_][a-zA-Z0-9_]*) ]]; do
                    _dq_vname="${BASH_REMATCH[1]}"
                    _dq_repl=""
                    # Check local var map
                    for _dq_vk in "${!_var_map[@]}"; do
                        if [[ "${_dq_vk#*:}" == "$_dq_vname" ]]; then
                            _dq_repl="${_var_map[$_dq_vk]}"; break
                        fi
                    done
                    # Check gvar map
                    [[ -z "$_dq_repl" && -n "${_gvar_map[$_dq_vname]+x}" ]] && \
                        _dq_repl="${_gvar_map[$_dq_vname]}"
                    if [[ -n "$_dq_repl" ]]; then
                        _dq_new="${_dq_new//"\$${_dq_vname}"/"\$${_dq_repl}"}"
                        _dq_changed=1
                    fi
                    # Advance past match to avoid infinite loop on unchanged names
                    _dq_rest="${_dq_rest#*"${BASH_REMATCH[0]}"}"
                done
                if (( _dq_changed )); then
                    local _dq_key="\"${_p2v}\""
                    if [[ -z "${_replacements[$_dq_key]+x}" ]]; then
                        _replacements[$_dq_key]="\"${_dq_new}\""
                        _repl_order+=("$_dq_key")
                    fi
                fi
            fi
            ;;
        WORD)
            # Function rename
            if [[ -n "${_fn_map[$_p2v]+x}" ]]; then
                local _new="${_fn_map[$_p2v]}"
                if [[ -z "${_replacements[$_p2v]+x}" ]]; then
                    _replacements[$_p2v]="$_new"
                    _repl_order+=("$_p2v")
                fi
            fi
            # local var: WORD following 'local' keyword
            if (( _do_lvar )) && [[ "$_p2pt" == WORD && "$_p2pv" == local ]]; then
                local _vbase="${_p2v%%=*}"
                # Find in any function scope
                local _vk
                for _vk in "${!_var_map[@]}"; do
                    if [[ "${_vk#*:}" == "$_vbase" ]]; then
                        local _vnew="${_var_map[$_vk]}"
                        # local decl replacement: whole "local varname" pair
                        local _old_decl="local ${_vbase}"
                        local _new_decl="local ${_vnew}"
                        if [[ -z "${_replacements[$_old_decl]+x}" ]]; then
                            _replacements[$_old_decl]="$_new_decl"
                            _repl_order+=("$_old_decl")
                        fi
                        break
                    fi
                done
            fi
            # Global var assignment
            if (( _do_vars )) && [[ "$_p2v" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)(\+?=) ]]; then
                local _gbase="${BASH_REMATCH[1]}"
                if [[ -n "${_gvar_map[$_gbase]+x}" ]]; then
                    local _gnew="${_gvar_map[$_gbase]}"
                    if [[ -z "${_replacements[$_gbase]+x}" ]]; then
                        _replacements[$_gbase]="$_gnew"
                        _repl_order+=("$_gbase")
                    fi
                fi
            fi
            ;;
        VAR_LITERAL)
            # $var → $newvar
            local _vlit="${_p2v#\$}"   # strip leading $
            local _vk
            for _vk in "${!_var_map[@]}"; do
                if [[ "${_vk#*:}" == "$_vlit" ]]; then
                    local _vlit_new="\$${_var_map[$_vk]}"
                    if [[ -z "${_replacements[$_p2v]+x}" ]]; then
                        _replacements[$_p2v]="$_vlit_new"
                        _repl_order+=("$_p2v")
                    fi
                    break
                fi
            done
            # Also check gvar map
            if [[ -n "${_gvar_map[$_vlit]+x}" ]]; then
                local _vlit_new="\$${_gvar_map[$_vlit]}"
                if [[ -z "${_replacements[$_p2v]+x}" ]]; then
                    _replacements[$_p2v]="$_vlit_new"
                    _repl_order+=("$_p2v")
                fi
            fi
            ;;
        ARITH)
            # Bare var names inside (( )) — rename in token val directly
            if (( _do_lvar && ${#_var_map[@]} > 0 )); then
                local _av="$_p2v" _ak _aon _arn
                for _ak in "${!_var_map[@]}"; do
                    _aon="${_ak#*:}"
                    _arn="${_var_map[$_ak]}"
                    _av="${_av//${_aon}/${_arn}}"
                done
                if [[ "$_av" != "$_p2v" ]]; then
                    if [[ -z "${_replacements[$_p2v]+x}" ]]; then
                        _replacements[$_p2v]="$_av"
                        _repl_order+=("$_p2v")
                    fi
                fi
            fi
            ;;
        esac

        _p2pt="$_p2t"; _p2pv="$_p2v"
        _progress_render "Obfuscating (pass 2/map)..." "$_p2i" "$token_count"
    done

    _log_verbose "[Obfuscator] Pass 2: Applying ${#_replacements[@]} replacements to source..."

    # Apply replacements — longest key first to avoid partial-name clobbering
    local _rk _rv _ri=0 _rtotal=${#_repl_order[@]}
    # Sort by length descending
    local -a _sorted_keys=()
    while IFS= read -r _rk; do
        _sorted_keys+=("$_rk")
    done < <(printf '%s
' "${_repl_order[@]}" |         awk '{ print length, $0 }' | sort -rn | cut -d' ' -f2-)

    for _rk in "${_sorted_keys[@]}"; do
        _rv="${_replacements[$_rk]}"
        result="${result//"${_rk}"/"${_rv}"}"
        (( _ri++ ))
        _progress_render "Obfuscating (pass 2/apply)..." "$_ri" "$_rtotal"
        _log_verbose "[Obfuscator] Applied: ${_rk} → ${_rv}"
    done

    # If --skip-minifier: strip comments using token stream (no regex headaches)
    if (( skip_minifier )); then
        local _ci
        for (( _ci=0; _ci<token_count; _ci++ )); do
            [[ "${tokens_type[_ci]}" == COMMENT ]] || continue
            result="${result//"${tokens_val[_ci]}"}"
        done
        _log_verbose "[Obfuscator] Comment strip pass complete"
    fi

    # ---- 2pevar. PARAM_EXP rename via pe_table ----
    # ---- 2pevar. PARAM_EXP rename via pe_table ----
    if (( _do_lvar && ${#_var_map[@]} > 0 )); then
        local -A _pe_seen_vars=()
        local _pe_idx _pe_orig_name _pe_new_name _pe_prefix _pe_op _pe_operand
        local _pe_orig_text _pe_new_text
        local _pe_total="${_pe_table[_count]:-0}"
        for (( _pe_idx=0; _pe_idx<_pe_total; _pe_idx++ )); do
            _pe_prefix="${_pe_table[${_pe_idx}_prefix]}"
            _pe_orig_name="${_pe_table[${_pe_idx}_name]}"
            _pe_op="${_pe_table[${_pe_idx}_op]}"
            _pe_operand="${_pe_table[${_pe_idx}_operand]}"
            # Skip empty names (e.g. ${#}, ${@}, ${!} — not simple var refs)
            [[ -z "$_pe_orig_name" ]] && continue
            _pe_new_name="$_pe_orig_name"
            if [[ -n "${_pe_seen_vars[$_pe_orig_name]+x}" ]]; then
                _pe_new_name="${_pe_seen_vars[$_pe_orig_name]}"
            else
                local _pe_base="${_pe_orig_name%%[*}"
                local _vk
                for _vk in "${!_var_map[@]}"; do
                    if [[ "${_vk#*:}" == "$_pe_base" ]]; then
                        local _pe_mapped="${_var_map[$_vk]}"
                        _pe_new_name="${_pe_orig_name/$_pe_base/$_pe_mapped}"
                        break
                    fi
                done
                _pe_seen_vars[$_pe_orig_name]="$_pe_new_name"
            fi
            _pe_table[${_pe_idx}_name]="$_pe_new_name"
            [[ "$_pe_new_name" == "$_pe_orig_name" ]] && continue
            _pe_orig_text="\${${_pe_prefix}${_pe_orig_name}${_pe_op}${_pe_operand}}"
            _pe_new_text="\${${_pe_prefix}${_pe_new_name}${_pe_op}${_pe_operand}}"
            result="${result//${_pe_orig_text}/${_pe_new_text}}"
            _progress_render "Obfuscating (pass 2/pe)..." "$_pe_idx" "$_pe_total"
        done
    fi

    # ---- 2strings. String encoding via base32 + _b32d helper ----
    if (( _do_strings )); then
        _log_verbose "[Obfuscator] Pass 2strings: Encoding string literals with base32..."
        local _si _st _sv _encoded_expr
        local _strings_found=0
        for (( _si=0; _si<token_count; _si++ )); do
            _st="${tokens_type[_si]}"
            _sv="${tokens_val[_si]}"
            case "$_st" in
                STRING_SQ)
                    _encoded_expr="$(_ob_encode_string "$_sv")"
                    result="${result//"'${_sv}'"/"${_encoded_expr}"}"
                    (( _strings_found++ ))
                    _log_verbose "[Obfuscator] Encoded STRING_SQ: '${_sv:0:20}...'"
                    ;;
                STRING_DQ)
                    # Only encode strings with no expansions (pure literal content)
                    if [[ "$_sv" != *'$'* && "$_sv" != *'\\'* ]]; then
                        _encoded_expr="$(_ob_encode_string "$_sv")"
                        result="${result//"\"${_sv}\""/"${_encoded_expr}"}"
                        (( _strings_found++ ))
                        _log_verbose "[Obfuscator] Encoded STRING_DQ: \"${_sv:0:20}...\""
                    fi
                    ;;
            esac
            _progress_render "Obfuscating (pass 2/strings)..." "$_si" "$token_count"
        done
        # Prepend _b32d helper to result if any strings were encoded.
        # If result starts with a shebang, lift it above the helper.
        if (( _strings_found > 0 )); then
            local _ob_tmp _shebang=""
            if [[ "$result" == '#!'* ]]; then
                _shebang="${result%%$'\n'*}"$'\n'
                result="${result#*$'\n'}"
            fi
            _ob_tmp=$(mktemp)
            printf '%s' "$_shebang" > "$_ob_tmp"
            printf '%s\n' "$_B32D_HELPER" >> "$_ob_tmp"
            printf '\n%s\n' "$result" >> "$_ob_tmp"
            result=$(cat "$_ob_tmp")
            rm -f "$_ob_tmp"
            _log_verbose "[Obfuscator] Prepended _b32d helper (${_strings_found} strings encoded)"
        fi
    fi

    _log_verbose "[Obfuscator] Obfuscation complete. Output size: ${#result} bytes"
    printf '%s\n' "$result"
}


_cli() {
    # ---- Subfunctions ----
    # ==============================================================================
    # CLI
    # ==============================================================================

    # _syntax_check — validate bash syntax, with shellcheck fallback for diagnostics
    #
    # Usage: _syntax_check "content" "label"
    #   label  — description shown in error messages (e.g. "input", "minified output")
    # Returns 0 if valid, 1 if not.
    # shellcheck is optional — if absent, bash -n errors are shown directly.
    _syntax_check() {
        local content="$1" label="$2"
        local _sc_tmp
        _sc_tmp=$(mktemp /tmp/obfuscate_sc.XXXXXX.sh)
        printf '%s\n' "$content" > "$_sc_tmp"
        _log_progress "Verifying ${label} syntax..."
        if bash -n "$_sc_tmp" 2>/dev/null; then
            rm -f "$_sc_tmp"
            _log "Verifying ${label} syntax... ok"
            return 0
        fi
        _log "Verifying ${label} syntax... FAILED"
        if command -v shellcheck >/dev/null 2>&1; then
            shellcheck --format=gcc --severity=error --shell=bash "$_sc_tmp" >&2
        else
            bash -n "$_sc_tmp" 2>&1 | head -10 >&2
        fi
        rm -f "$_sc_tmp"
        return 1
    }

    local check=0 skip_minifier=0 skip_obfuscator=0
    local input_file="" output_file=""
    local -A passes=([private_functions]=1 [local_variables]=1
                     [functions]=0 [variables]=0 [strings]=0)

    while (( $# )); do
        case "$1" in
            --check)          check=1 ;;
            --verbose)        [[ -z "$_minify_log_mode" ]] && _minify_log_mode=verbose ;;
            --quiet)          [[ -z "$_minify_log_mode" ]] && _minify_log_mode=quiet ;;
            --skip-minifier)  skip_minifier=1 ;;
            --skip-obfuscator) skip_obfuscator=1 ;;
            --obfuscate=*)
                local _ob_val="${1#--obfuscate=}"
                # Reset to all-off first, then apply requested passes
                for k in "${!passes[@]}"; do passes[$k]=0; done
                local _ob_pass
                IFS=',' read -ra _ob_passes <<< "$_ob_val"
                for _ob_pass in "${_ob_passes[@]}"; do
                    _ob_pass="${_ob_pass// /}"  # trim spaces
                    case "$_ob_pass" in
                        all)
                            for k in "${!passes[@]}"; do passes[$k]=1; done
                            ;;
                        private_functions|functions|local_variables|variables|strings)
                            passes[$_ob_pass]=1
                            ;;
                        *)
                            echo "obfuscate.sh: unknown pass: ${_ob_pass}" >&2
                            echo "  valid passes: all, private_functions, functions, local_variables, variables, strings" >&2
                            return 1
                            ;;
                    esac
                done
                ;;
            --)               shift; break ;;
            -)
                if [[ -z "$input_file" ]]; then input_file="-"
                elif [[ -z "$output_file" ]]; then output_file="-"
                else echo "obfuscate.sh: unexpected argument: $1" >&2; return 1
                fi ;;
            -*)               echo "obfuscate.sh: unknown option: $1" >&2; return 1 ;;
            *)
                if [[ -z "$input_file" ]]; then input_file="$1"
                elif [[ -z "$output_file" ]]; then output_file="$1"
                else echo "obfuscate.sh: unexpected argument: $1" >&2; return 1
                fi ;;
        esac
        shift
    done

    if [[ -z "$input_file" ]]; then
        echo "Usage: obfuscate.sh [options] input.sh [output.sh]" >&2
        echo "       obfuscate.sh [options] -" >&2
        echo "" >&2
        echo "Options:" >&2
        echo "  --obfuscate=PASSES  Comma-separated: all,private_functions,functions," >&2
        echo "                      local_variables,variables,strings" >&2
        echo "                      (default: private_functions,local_variables)" >&2
        echo "  --skip-minifier     Obfuscate raw source without minifying first" >&2
        echo "  --skip-obfuscator   Minify only, skip the obfuscation pass" >&2
        echo "  --check             Validate output syntax only, do not write" >&2
        echo "  --verbose           Log every decision to stderr" >&2
        echo "  --quiet             Suppress all progress output" >&2
        return 1
    fi

    # Read input
    local content
    if [[ "$input_file" == "-" ]]; then
        content=$(cat)
    else
        [[ ! -f "$input_file" ]] && { echo "obfuscate.sh: file not found: $input_file" >&2; return 1; }
        content=$(cat "$input_file")
    fi

    local input_bytes=${#content}
    local label="${input_file}" target="${output_file:-stdout}"

    # Validate input syntax before doing any work
    _syntax_check "$content" "input" || return 1

    # Tokenise once — shared token arrays live here, passed by base name to stages.
    # Base name "_sh" avoids circular nameref collision with internal locals
    # named tokens_type/tokens_val/token_count inside minify() and obfuscate().
    local -a _sh_type=() _sh_val=()
    local -A _sh_pe=()
    local _sh_tc=0
    _log_verbose "[Pipeline] Tokenising input..."
    PARSE_PE=1 tokenise "$content" _sh _sh_tc _sh_pe
    _progress_done
    _log_verbose "[Pipeline] Tokenisation complete: ${_sh_tc} tokens"

    # Step 1: minify (unless skipped) — reuses shared token arrays
    local to_obfuscate="$content"
    if (( !skip_minifier )); then
        _log_verbose "[Pipeline] Minifying..."
        to_obfuscate=$(minify "$content" _sh _sh_tc)
        _progress_done
        _syntax_check "$to_obfuscate" "minified output" || return 1
        _log_verbose "[Pipeline] Minification done (${#to_obfuscate} bytes)"
    fi

    # Step 2: obfuscate (unless skipped) — reuses shared token arrays
    # obfuscate src is raw content (--skip-minifier) or minified string;
    # token array is always from raw content — used as correctness oracle only
    local obfuscated
    if (( skip_obfuscator )); then
        obfuscated="$to_obfuscate"
        _log_verbose "[Pipeline] Skipping obfuscation pass."
    else
        obfuscated=$(obfuscate "$to_obfuscate" passes _sh _sh_tc _sh_pe "$skip_minifier")
        _progress_done
    fi

    # Validate syntax
    if ! _syntax_check "$obfuscated" "obfuscated output"; then
        if [[ -n "$output_file" && "$output_file" != "-" ]]; then
            printf '%s\n' "$obfuscated" > "${output_file}.broken"
            echo "obfuscate.sh: broken output written to ${output_file}.broken" >&2
        fi
        return 1
    fi

    local output_bytes=${#obfuscated}
    local reduction=$(( (input_bytes - output_bytes) * 100 / (input_bytes > 0 ? input_bytes : 1) ))
    _log_verbose "[Obfuscator] Output: ${output_bytes} bytes (${reduction}% vs original input)"

    (( check )) && { echo "obfuscate.sh: syntax OK (${output_bytes} bytes)" >&2; return 0; }

    if [[ -z "$output_file" || "$output_file" == "-" ]]; then
        printf '%s\n' "$obfuscated"
    else
        printf '%s\n' "$obfuscated" > "$output_file"
        chmod +x "$output_file"
        [[ "$_minify_log_mode" != quiet ]] && {
            local _op_label="Obfuscated"
            (( skip_obfuscator )) && _op_label="Minified"
            echo "${_op_label} ${input_file} -> ${output_file} (${input_bytes} -> ${output_bytes} bytes, ${reduction}%)" >&2
        }
    fi
}

# Run CLI if executed directly, otherwise just define functions for sourcing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _cli "$@"
fi
