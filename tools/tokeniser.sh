#!/usr/bin/env bash
# tokeniser.sh — shared Bash tokeniser for the framehead tool suite
#
# Sourceable library. Provides:
#   tokenise input tk_base tc [pe_table]
#
# Token storage — parallel indexed arrays, two per token N:
#   <tk_base>_type[N]   <tk_base>_val[N]
# A separate integer nameref holds the count.
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
# Logging — respects _minify_log_mode (set by caller or inheriting tool):
#   unset / ""  → no output
#   "progress"  → TTY progress bar via _progress_render
#   "verbose"   → per-token log lines to stderr
#   "quiet"     → suppress all output
#
# Requires: bash 4.3+ (namerefs)

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
