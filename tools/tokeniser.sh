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
#   ARITH         $(( )) or (( )) val is the FULL construct incl. delimiters, literalised
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
    # Byte-oriented (C) locale: this tokeniser indexes the source with
    # ${var:off:len} and ${#var}. Under a UTF-8 locale those are character
    # operations that rescan from the start, making tokenisation O(n^2) on
    # large inputs. The framework source is ASCII, so C collation is correct.
    local LC_ALL=C
    # Parallel indexed arrays: caller passes a base name; we bind _tk_type and _tk_val
    # to <base>_type[] and <base>_val[] respectively.
    local -n _tk_type="${2}_type"
    local -n _tk_val="${2}_val"
    local -n _tk_pos_arr="${2}_pos"
    local -n _tk_end_arr="${2}_end"
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
    # Pending-heredoc queue: delimiters awaiting bodies, drained at line
    # boundaries. Shared by the main loop (drains by emitting tokens) and
    # _subshell_scan (drains by inlining into the CMD_SUB/PROC_SUB value).
    local -a _pending_hd_marker=() _pending_hd_dash=() _pending_hd_lit=()
    # Outputs of _collect_heredoc (the shared body matcher).
    local _hd_collected="" _hd_tail="" _hd_found=false _hd_had_line=false
    local _hd_literal=false  # \<NL> body joining active (unquoted delimiter)
    # Remainder after a delimiter that shares its line with a subshell-closing )
    # (e.g. "$(<<E)" with the ) on the delimiter line). Opt-in via the matcher's
    # third arg; consumed by _subshell_scan to resume scanning the close.
    local _hd_remainder="" _hd_has_remainder=false
    local _hd_drain_remainder="" _hd_drain_has_remainder=false
    local _sq_open=0  # set when _sq returned 94 (multi-line string in progress)
    local _dq_open=0  # set when _dq returned 94 (multi-line double-quoted string in progress)
    local -a _dq_stack=()  # quote stack, preserved across _dq line continuations
    local _dq_cmd_depth=0  # $( nesting depth inside _dq — suppresses quote stack while > 0
    local -a _case_stack=()  # case nesting stack; each entry is STATE (WORD/PAT/BODY); depth = stack length
    local -a _lines=()
    local _src_offset=0  # cumulative offset across lines for position tracking
    local _full_src=""   # full source for adjacency computation
    local _cmd_pos=1    # 1=command position ({ is block delimiter); 0=word position ({ may be brace expansion)
    local _brace_depth=0  # depth of brace blocks ({ cmd; }); 0 means } is a word char
    local _array_depth=0 _array_start_off=0 _array_saved_tc=0 _array_name=""  # array-assignment name=(...) folding

    # --------------------------------------------------------------------------
    # _emit — append one token
    # --------------------------------------------------------------------------
    _emit() {
        _tk_type[_tc]="$1"
        _tk_val[_tc]="$2"
        _tk_pos_arr[$_tc]=$(( _src_offset + _token_start ))
        # Use explicit end pos if caller passed it as $3, else use current _pos
        _tk_end_arr[$_tc]=$(( _src_offset + ${3:-$_pos} ))
        _log_verbose "[Tokeniser] Tokenised '${2}' as ${1}"
        (( _tc++ ))
    }

    # --------------------------------------------------------------------------
    # _pull_line — pull the next line into _src, appending to _full_src and
    # advancing _src_offset. Use in contexts where each pulled line corresponds
    # to a logical line boundary (main loop, DQ continuation).
    # Returns 1 if no more lines available.
    # --------------------------------------------------------------------------
    _pull_line() {
        if (( _li >= ${#_lines[@]} )); then _src=""; return 1; fi
        _src="${_lines[_li]}"
        (( _li++ ))
        _full_src+="${_src}"$'\n'
        (( _src_offset += ${#_src} + 1 ))
        return 0
    }

    # --------------------------------------------------------------------------
    # _pull_line_body — pull the next line into _src for body-accumulation
    # contexts (_subshell_scan, _paramexp, _arith internals). Appends to
    # _full_src so the word-accumulator has the full source, but does NOT
    # advance _src_offset — the caller is responsible for offset accounting
    # once the closing delimiter is found.
    # Returns 1 if no more lines available.
    # --------------------------------------------------------------------------
    _pull_line_body() {
        if (( _li >= ${#_lines[@]} )); then _src=""; return 1; fi
        _src="${_lines[_li]}"
        (( _li++ ))
        _full_src+="${_src}"$'\n'
        return 0
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
    # _unlit — exact inverse of _lit: \\ -> \, \n -> NL, \t -> TAB. Writes to the
    # nameref in $2 (NOT stdout) so callers avoid $()'s trailing-newline strip —
    # critical since decoded heredoc bodies can legitimately end in a newline.
    # Used by the word-accumulator merge pass to reconstruct raw source from
    # _lit-encoded sub-token values when fusing a run into a single WORD.
    # --------------------------------------------------------------------------
    _unlit() {
        local s="$1"
        s="${s//\\\\/$'\x01'}"   # protect escaped backslashes
        s="${s//\\n/$'\n'}"
        s="${s//\\t/$'\t'}"
        s="${s//$'\x01'/\\}"
        printf -v "$2" '%s' "$s"
    }

    # --------------------------------------------------------------------------
    # _sq — consume '...' starting at _pos; emits STRING_SQ
    # Returns 94 when EOL is reached without finding closing ' (multi-line string).
    # Caller must append subsequent lines to the last token val until closed.
    # --------------------------------------------------------------------------
    _sq() {
        local _sq_s=$_pos
        local i=$(( _pos + 1 ))
        while (( i < ${#_src} )); do
            [[ "${_src:i:1}" == "'" ]] && {
                _pos=$(( i + 1 ))
                _emit STRING_SQ "${_src:$((_sq_s+1)):$(( i - _sq_s - 1 ))}"
                return 0
            }
            (( i++ ))
        done
        # EOL without closing ' — emit partial, signal continuation
        _pos=${#_src}
        _emit STRING_SQ "${_src:$((_sq_s+1))}"
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
        local _dq_s=$_pos
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
            # Track $( subshell depth — suppresses quote stack while inside.
            # Skip $ when it is the second $ of $$, since $$( is PID + literal (.
            if [[ "$c" == '$' && "${_src:i+1:1}" == '(' && ( i == 0 || "${_src:i-1:1}" != '$' ) ]]; then
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
                    _pos=$(( i + 1 ))
                    _emit STRING_DQ "$(_lit "${_src:$((_dq_s+1)):$(( i - _dq_s - 1 ))}")"
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
        _pos=${#_src}
        _emit STRING_DQ "$(_lit "${_src:$((_dq_s+1))}")"
        return 94
    }

    # --------------------------------------------------------------------------
    # _arith — consume $(( )) starting at _pos; emits ARITH (interior lit'd)
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # _arith_scan — shared state-aware scanner for arithmetic (( )) / $(( )).
    #   $1 = opening delimiter width: 2 for '((', 3 for '$(('
    #   $2 = emit token type: ARITH_STMT or ARITH
    # Walks the body tracking lexical state (single-quote, double-quote with
    # backslash escapes, ANSI-C $'...', and backslash escapes outside quotes) so
    # parens inside quotes or after a backslash do NOT drive paren depth. depth
    # starts at 2 because BOTH opening parens of '((' / '$((' must be closed.
    # On success the FULL construct is emitted verbatim (delimiters included),
    # _lit-encoded — the re-emitter outputs it byte-for-byte. Verbatim is the
    # only faithful reconstruction when the closing parens are non-adjacent
    # (e.g. $(($())#)) or the body holds quotes/escapes/embedded newlines.
    # --------------------------------------------------------------------------
    _arith_scan() {
        local _open_w="$1" _as_type="$2"
        # Absolute start of the construct in _full_src (current-line base + _pos),
        # captured before any line pulls. Base = full length minus the current
        # line and its trailing newline.
        local _as_abs_start=$(( ${#_full_src} - ${#_src} - 1 + _pos ))
        local i=$(( _pos + _open_w )) depth=2
        local _close_pos=-1
        local _sq=0           # inside single-quote (persists across line pulls)
        local -a _dq=()       # double-quote stack (persists across line pulls)
        while true; do
            while (( i < ${#_src} )); do
                local c="${_src:i:1}"
                # Inside single-quote — only ' closes; no escapes.
                if (( _sq )); then
                    [[ "$c" == "'" ]] && _sq=0
                    (( i++ )); continue
                fi
                # Inside double-quote — \ escapes, " closes; parens are literal.
                if (( ${#_dq[@]} > 0 )); then
                    if [[ "$c" == '\' ]]; then (( i += 2 )); continue; fi
                    [[ "$c" == '"' ]] && unset '_dq[-1]'
                    (( i++ )); continue
                fi
                # Backslash outside quotes — escaped char is literal.
                if [[ "$c" == '\' ]]; then (( i += 2 )); continue; fi
                # ANSI-C $'...' — skip until unescaped closing '.
                if [[ "$c" == '$' && "${_src:i+1:1}" == "'" ]]; then
                    (( i += 2 ))
                    while (( i < ${#_src} )); do
                        local _ac="${_src:i:1}"
                        if [[ "$_ac" == '\' ]]; then (( i += 2 )); continue; fi
                        if [[ "$_ac" == "'" ]]; then (( i++ )); break; fi
                        (( i++ ))
                    done
                    continue
                fi
                # Quote opens.
                if [[ "$c" == "'" ]]; then _sq=1; (( i++ )); continue; fi
                if [[ "$c" == '"' ]]; then _dq+=('"'); (( i++ )); continue; fi
                # Bare parens drive depth.
                if [[ "$c" == '(' ]]; then
                    (( depth++ ))
                elif [[ "$c" == ')' ]]; then
                    (( depth-- ))
                    if (( depth == 0 )); then _close_pos=$i; break; fi
                fi
                (( i++ ))
            done
            (( _close_pos >= 0 )) && break
            # EOL without close — pull next line; lexical state persists.
            if (( _li >= ${#_lines[@]} )); then break; fi
            _pull_line_body
            i=0
        done
        # Resync _src_offset to the current (last-pulled) line base so _emit's
        # position accounting matches the surrounding single-line convention.
        _src_offset=$(( ${#_full_src} - ${#_src} - 1 ))
        local _as_abs_end
        if (( _close_pos < 0 )); then
            # No closing )) — consume to EOF, dropping the synthetic trailing NL.
            _as_abs_end=$(( ${#_full_src} - 1 ))
            _pos=${#_src}
        else
            _as_abs_end=$(( _src_offset + _close_pos + 1 ))
            _pos=$(( _close_pos + 1 ))
        fi
        _emit "$_as_type" \
            "$(_lit "${_full_src:_as_abs_start:_as_abs_end - _as_abs_start}")"
    }

    _arith() { _arith_scan 3 ARITH; }

    # --------------------------------------------------------------------------
    # _arith_deprecated — consume $[expr] starting at _pos; emits ARITH_DEPRECATED
    # --------------------------------------------------------------------------
    _arith_deprecated() {
        local _ard_s=$_pos
        local i=$(( _pos + 2 )) depth=1
        while (( i < ${#_src} )); do
            local c="${_src:i:1}"
            if [[ "$c" == '[' ]]; then
                (( depth++ ))
            elif [[ "$c" == ']' ]]; then
                (( depth-- ))
                (( depth == 0 )) && break
            fi
            (( i++ ))
        done
        _pos=$(( i + 1 ))
        _emit ARITH_DEPRECATED "${_src:_ard_s:$(( _pos - _ard_s ))}"
    }

    # --------------------------------------------------------------------------
    # _arith_stmt — arithmetic (( )) at statement level; emits ARITH
    # --------------------------------------------------------------------------
    _arith_stmt() { _arith_scan 2 ARITH_STMT; }

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
    _subshell_scan() {
        local _emit_type="${1:-CMD_SUB}" _val_prefix="${2:-}"
        local _FSEP=$'\x01'  # frame serialisation delimiter — can't appear in quote chars

        # Frame stack: each entry is a serialised dq_stack for that subshell level
        # Index 0 = outermost $( ... ) frame
        local -a _fs=()       # frame stack (serialised dq_stacks)
        local -a _cur_dq=()   # current frame's dq_stack
        local _cur_sq=0       # single-quote open flag for current frame

        # case/esac depth: ) inside a case pattern is NOT a subshell close.
        # We track nesting at each frame level via a parallel stack.
        # _case_depth[i] is the case nesting depth for frame i.
        local -a _case_depth=()
        local _cur_case=0     # case depth for the current frame

        # Push the initial frame for the opening $(
        _fs+=("")             # empty dq_stack — fresh subshell context
        _case_depth+=(0)

        local body="" start_pos=$(( _pos + 2 ))
        local ci=$start_pos

        # Helper: check if position ci is at a word boundary (preceded by
        # whitespace, newline, ;, |, &, (, or start of body).
        # Used to detect 'case' and 'esac' keywords reliably.
        _cs_at_word_boundary() {
            (( ci == start_pos )) && return 0
            local prev="${_src:ci-1:1}"
            [[ "$prev" == ' ' || "$prev" == $'\t' || "$prev" == ';' ||
               "$prev" == '|' || "$prev" == '&' || "$prev" == '(' ]] && return 0
            return 1
        }

        # Flush the pending-heredoc queue into `body` (FIFO). Called at line
        # boundaries and the closing ) so deferred bodies land inside the
        # interior. Mirrors bash's deferred-heredoc emission; whitespace is
        # normalised downstream so exact spacing need not match bash's printer.
        _drain_subshell_hd() {
            local _dk
            _hd_drain_remainder=""; _hd_drain_has_remainder=false
            for (( _dk=0; _dk < ${#_pending_hd_marker[@]}; _dk++ )); do
                _hd_literal="${_pending_hd_lit[_dk]:-false}"
                _collect_heredoc "${_pending_hd_marker[_dk]}" "${_pending_hd_dash[_dk]}" true
                # Newline separates the redirect line from the body; emit body
                # lines (if any) then the delimiter. Skipping the empty-body
                # case keeps a zero-line heredoc as <<E\nE rather than <<E\n\nE.
                body+=$'\n'
                [[ -n "$_hd_collected" ]] && body+="$_hd_collected"$'\n'
                $_hd_found && body+="$_hd_tail"$'\n'
                # EOF-synthesis: an unterminated deferred heredoc still renders
                # its (synthesized) delimiter line in bash's canonical AST, so
                # emit the marker even when no closing line was found in source.
                # EXCEPTION: a \<NL>-join re-scan that handed back the closing )
                # as a remainder must NOT synthesize the delimiter — bash renders
                # an empty synth line and resumes the procsub at the ), without
                # re-stating the delimiter word.
                if ! $_hd_found && ! $_hd_has_remainder; then
                    body+="${_pending_hd_marker[_dk]}"$'\n'
                fi
                if $_hd_has_remainder; then
                    _hd_drain_remainder="$_hd_remainder"
                    _hd_drain_has_remainder=true
                    break
                fi
            done
            _pending_hd_marker=()
            _pending_hd_dash=()
            _pending_hd_lit=()
        }

        while true; do
            while (( ci < ${#_src} )); do
                local c="${_src:ci:1}"

                # Inside single-quoted string — only ' closes it
                if (( _cur_sq )); then
                    [[ "$c" == "'" ]] && _cur_sq=0
                    (( ci++ )); continue
                fi

                # Inside double-quoted string (cur_dq non-empty, top is ")
                if (( ${#_cur_dq[@]} > 0 )) && [[ "${_cur_dq[-1]}" == '"' ]]; then
                    if [[ "$c" == '\' ]]; then
                        (( ci += 2 )); continue
                    fi
                    if [[ "$c" == '$' && "${_src:ci+1:1}" == '(' ]]; then
                        local _s="" _j
                        for _j in "${_cur_dq[@]}"; do _s+="${_FSEP}${_j}"; done
                        _fs+=("${_s:${#_FSEP}}")
                        _case_depth+=($_cur_case)
                        _cur_dq=()
                        _cur_sq=0
                        _cur_case=0
                        (( ci += 2 )); continue
                    fi
                    [[ "$c" == '"' ]] && unset '_cur_dq[-1]'
                    (( ci++ )); continue
                fi

                # Backslash outside quotes — skip next char
                if [[ "$c" == '\' ]]; then
                    (( ci += 2 )); continue
                fi

                # Comment — # at a word boundary runs to end of line; bash skips
                # it wholesale, so no quote/paren/backslash interpretation inside.
                if [[ "$c" == '#' ]] && _cs_at_word_boundary; then
                    ci=${#_src}; continue
                fi

                # Single-quote open
                if [[ "$c" == "'" ]]; then
                    _cur_sq=1; (( ci++ )); continue
                fi

                # ANSI-C string $'...' — skip until unescaped closing '
                if [[ "$c" == '$' && "${_src:ci+1:1}" == "'" ]]; then
                    (( ci += 2 ))
                    while (( ci < ${#_src} )); do
                        local _ac="${_src:ci:1}"
                        if [[ "$_ac" == '\' ]]; then (( ci += 2 )); continue; fi
                        if [[ "$_ac" == "'" ]]; then (( ci++ )); break; fi
                        (( ci++ ))
                    done
                    continue
                fi

                # Double-quote open
                if [[ "$c" == '"' ]]; then
                    _cur_dq+=('"'); (( ci++ )); continue
                fi

                # Heredoc << or <<- inside the subshell. Defer the body: push the
                # delimiter onto the shared pending queue and keep scanning this
                # line. The body is drained at the next boundary (newline or the
                # closing ) ) by _drain_subshell_hd, so it lands inside the cmdsub
                # interior as valid bash — bash itself defers heredoc bodies to
                # the next command boundary. NOT <<< (here-string).
                if [[ "$c" == '<' && "${_src:ci+1:1}" == '<'
                      && "${_src:ci+2:1}" != '<'
                      && (( ci == 0 || "${_src:ci-1:1}" != '<' )) ]]; then
                    local _hd_strip=false _hd_skip=2
                    [[ "${_src:ci+2:1}" == '-' ]] && { _hd_strip=true; _hd_skip=3; }
                    (( ci += _hd_skip ))
                    # Skip whitespace after <<
                    while [[ "${_src:ci:1}" == ' ' || "${_src:ci:1}" == $'\t' ]]; do
                        (( ci++ ))
                    done
                    # Read the (possibly quoted) delimiter word; the queued marker
                    # is the quote-removed form _collect_heredoc matches against.
                    local _hd_tag="" _hd_quote="" _hd_c="${_src:ci:1}"
                    if [[ "$_hd_c" == '"' || "$_hd_c" == "'" || "$_hd_c" == '`' ]]; then
                        _hd_quote="$_hd_c"; (( ci++ ))
                    fi
                    while (( ci < ${#_src} )); do
                        _hd_c="${_src:ci:1}"
                        if [[ -n "$_hd_quote" && "$_hd_c" == "$_hd_quote" ]]; then
                            (( ci++ )); break
                        fi
                        # An unquoted delimiter word ends at a shell metachar.
                        # `<`/`>` terminate too (they start a redirect) UNLESS
                        # immediately followed by `(` — then `<(`/`>(` is a proc-
                        # sub that bash absorbs into the word; leave it intact.
                        if [[ -z "$_hd_quote" ]]; then
                            case "$_hd_c" in
                                ' '|$'\t'|';'|')'|$'\n'|'|'|'&') break ;;
                                '<'|'>') [[ "${_src:ci+1:1}" != '(' ]] && break ;;
                            esac
                        fi
                        _hd_tag+="$_hd_c"; (( ci++ ))
                    done
                    _pending_hd_marker+=("$_hd_tag")
                    _pending_hd_dash+=("$_hd_strip")
                    [[ -z "$_hd_quote" ]] && _pending_hd_lit+=(true) || _pending_hd_lit+=(false)
                    continue
                fi

                # case keyword — increment case depth for this frame
                if [[ "$c" == 'c' && "${_src:ci:4}" == 'case' ]] && _cs_at_word_boundary; then
                    local _after="${_src:ci+4:1}"
                    if [[ "$_after" == ' ' || "$_after" == $'\t' || "$_after" == $'\n' || -z "$_after" ]]; then
                        (( _cur_case++ ))
                        (( ci += 4 )); continue
                    fi
                fi

                # esac keyword — decrement case depth for this frame
                if [[ "$c" == 'e' && "${_src:ci:4}" == 'esac' ]] && _cs_at_word_boundary; then
                    local _after="${_src:ci+4:1}"
                    if [[ "$_after" == ' ' || "$_after" == $'\t' || "$_after" == $'\n' || "$_after" == ')' || "$_after" == ';' || "$_after" == '&' || "$_after" == '|' || "$_after" == '<' || "$_after" == '>' || -z "$_after" ]]; then
                        (( _cur_case > 0 )) && (( _cur_case-- ))
                        (( ci += 4 )); continue
                    fi
                fi

                # Nested arithmetic $(( )) — consume as balanced parens with no
                # operator interpretation. Inside arithmetic, << is a left-shift,
                # not a heredoc (e.g. $(( 1<<2 ))); scanning it char-by-char
                # would otherwise trip the heredoc detector above. Only the
                # adjacent "((" form is arithmetic; "$( (" is a subshell cmdsub.
                if [[ "$c" == '$' && "${_src:ci+1:2}" == '((' ]]; then
                    local _arith_depth=2 _arith_j=$(( ci + 3 ))
                    while (( _arith_j < ${#_src} && _arith_depth > 0 )); do
                        local _arith_c="${_src:_arith_j:1}"
                        if [[ "$_arith_c" == '\' ]]; then
                            (( _arith_j += 2 )); continue
                        fi
                        [[ "$_arith_c" == '(' ]] && (( _arith_depth++ ))
                        [[ "$_arith_c" == ')' ]] && (( _arith_depth-- ))
                        (( _arith_j++ ))
                    done
                    # Only adopt the balanced span if it closed on this line;
                    # an unterminated arith falls through to normal handling.
                    if (( _arith_depth == 0 )); then
                        ci=$_arith_j; continue
                    fi
                fi

                # Nested $( — push new frame
                if [[ "$c" == '$' && "${_src:ci+1:1}" == '(' ]]; then
                    local _s="" _j
                    for _j in "${_cur_dq[@]}"; do _s+="${_FSEP}${_j}"; done
                    _fs+=("${_s:${#_FSEP}}")
                    _case_depth+=($_cur_case)
                    _cur_dq=()
                    _cur_sq=0
                    _cur_case=0
                    (( ci += 2 )); continue
                fi

                # ( not preceded by $ — push frame for paren depth (subshell, etc.)
                # But NOT when inside a case pattern context (_cur_case > 0):
                # in that context, ( is a pattern delimiter, not a subshell open.
                if [[ "$c" == '(' ]]; then
                    if (( _cur_case == 0 )); then
                        local _s="" _j
                        for _j in "${_cur_dq[@]}"; do _s+="${_FSEP}${_j}"; done
                        _fs+=("${_s:${#_FSEP}}")
                        _case_depth+=($_cur_case)
                        _cur_dq=()
                        _cur_sq=0
                        _cur_case=0
                    fi
                    (( ci++ )); continue
                fi

                # ) — close frame or case pattern
                if [[ "$c" == ')' ]]; then
                    if (( _cur_case > 0 )); then
                        # Inside case — ) is a pattern separator, not a frame close
                        (( ci++ )); continue
                    fi
                    if (( ${#_fs[@]} == 1 )); then
                        # Closing the outermost $( — we're done
                        body+="${_src:start_pos:ci-start_pos}"
                        # Flush any heredoc bodies deferred on this line so they
                        # land inside the interior, before the ) closes.
                        (( ${#_pending_hd_marker[@]} > 0 )) && _drain_subshell_hd
                        _pos=$(( ci + 1 ))
                        # Resync _src_offset if body-scanner pulled lines
                        if [[ "${_src_offset_set:-0}" != "1" ]]; then
                            _src_offset=$(( ${#_full_src} - ${#_src} - 1 ))
                        fi
                        unset _src_offset_set
                        _emit "$_emit_type" "${_val_prefix}$(_lit "$body")"
                        return 0
                    fi
                    # Pop frame — restore parent dq_stack and case depth
                    local _top="${_fs[-1]}"
                    unset '_fs[-1]'
                    _cur_case="${_case_depth[-1]}"
                    unset '_case_depth[-1]'
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

            # EOL without close — accumulate this line, flush any deferred
            # heredocs at this boundary, then pull the next line. The drain
            # advances _li past the body, so _pull_line_body resumes after it.
            if (( _li >= ${#_lines[@]} )); then break; fi
            body+="${_src:start_pos}"
            if (( ${#_pending_hd_marker[@]} > 0 )); then
                _drain_subshell_hd
                # A delimiter line bearing the closing ) hands back the remainder
                # (the ) and anything after); resume scanning it as the current
                # line so the frame closes, instead of pulling a fresh line.
                if [[ "$_hd_drain_has_remainder" == true ]]; then
                    _src="$_hd_drain_remainder"
                    start_pos=0; ci=0
                    continue
                fi
            else
                body+=$'\n'
            fi
            _pull_line_body
            start_pos=0
            ci=0
        done

        # Unterminated — emit what we have
        body+="${_src:start_pos}"
        (( ${#_pending_hd_marker[@]} > 0 )) && _drain_subshell_hd
        _pos=${#_src}
        _src_offset=$(( ${#_full_src} - ${#_src} - 1 ))
        _emit "$_emit_type" "${_val_prefix}$(_lit "$body")"
        return 94
    }

    # --------------------------------------------------------------------------
    # _cmdsub — consume $( ) starting at _pos; emits CMD_SUB
    # --------------------------------------------------------------------------
    _cmdsub() { _subshell_scan CMD_SUB ""; }

    # --------------------------------------------------------------------------
    # _cmdsub_ps — process substitution <( ) or >( ); emits PROC_SUB
    # Fully featured: multi-line, heredoc-aware, case/esac depth tracking.
    # --------------------------------------------------------------------------
    _cmdsub_ps() {
        local dir="$1"
        _subshell_scan PROC_SUB "${dir}|"
    }

    # --------------------------------------------------------------------------
    # _backtick — consume `...` starting at _pos; emits CMD_SUB
    # --------------------------------------------------------------------------
    _backtick() {
        local _bt_s=$_pos
        local i=$(( _pos + 1 ))
        while (( i < ${#_src} )); do
            local c="${_src:i:1}"
            [[ "$c" == '\' ]] && { (( i += 2 )); continue; }
            [[ "$c" == '`' ]] && {
                _pos=$(( i + 1 ))
                _emit BACKTICK "${_src:_bt_s:$(( i - _bt_s + 1 ))}"
                return
            }
            (( i++ ))
        done
        _pos=${#_src}
        _emit BACKTICK "${_src:_bt_s}"
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
        local _pe_start_pos=$_pos  # save original _pos for interior extraction
        local _pe_accumulated=""   # accumulated prefix lines when multi-line

        # ksh-style ${ list; } group-command-substitution: `${` immediately
        # followed by whitespace or end-of-line is not a parameter expansion
        # at all (no variable name can start that way) — bash lexes the whole
        # construct as a single WORD. Detect it here and emit it verbatim
        # (Cluster-E style) once the matching `}` is found below.
        local _pe_group=0 _pe_abs_start=$(( _src_offset + _pos ))
        if [[ "${_pe_dq_mode:-0}" != "1" ]]; then
            local _pe_after="${_src:i:1}"
            [[ "$_pe_after" == ' ' || "$_pe_after" == $'\t' || -z "$_pe_after" ]] && _pe_group=1
        fi

        while true; do
            while (( i < ${#_src} && depth > 0 )); do
                local c="${_src:i:1}"
                if [[ "$c" == '}' ]]; then
                    (( depth-- ))
                    (( depth == 0 )) && break
                elif [[ "$c" == '$' && $(( i + 1 < ${#_src} )) -eq 1 ]]; then
                    # ${ opens a nested param exp — recurse to consume it.
                    if [[ "${_src:i+1:1}" == '{' ]]; then
                        local _pe_saved_pos=$_pos
                        _pos=$i
                        _paramexp
                        i=$_pos
                        _pos=$_pe_saved_pos
                        continue
                    fi
                    # $$ special parameter
                    if [[ "${_src:i+1:1}" == '$' ]]; then
                        local _after_dollar="${_src:i+2:1}"
                        if [[ "$_after_dollar" != '{' && "$_after_dollar" != '(' ]]; then
                            (( i += 2 ))
                            continue
                        fi
                    fi
                fi
                (( i++ ))
            done
            # If depth == 0 we found the closing }
            (( depth == 0 )) && break
            # EOL without close — pull next line
            if (( _li >= ${#_lines[@]} )); then break; fi
            _pe_accumulated+="${_src:$(( _pe_start_pos + 2 ))}"$'\n'
            _pull_line_body
            _pe_start_pos=-2   # signal that interior is in _pe_accumulated
            i=0
        done

        local _interior
        if [[ -n "$_pe_accumulated" ]]; then
            _interior="${_pe_accumulated}${_src:0:i}"
        else
            _interior="${_src:_pos+2:i-_pos-2}"
        fi

        _pos=$(( i + 1 ))
        if [[ -n "$_pe_accumulated" ]]; then
            _src_offset=$(( ${#_full_src} - ${#_src} - 1 ))
            # _token_start was captured against the line `${` started on;
            # _src_offset now refers to the last-pulled line, so re-derive
            # _token_start from the absolute start position (_pe_abs_start)
            # captured at entry — keeps _tk_pos_arr/_tk_end_arr (and thus the
            # word-accumulator's _full_src reconstruction) correct.
            _token_start=$(( _pe_abs_start - _src_offset ))
        fi

        # Group-command-substitution: emit the whole ${ ... } span verbatim
        # as one WORD (sliced from _full_src) and bypass PE handling entirely.
        if (( _pe_group )); then
            local _pe_abs_end=$(( _src_offset + _pos ))
            _token_start=$(( _pe_abs_start - _src_offset ))
            _emit WORD "${_full_src:_pe_abs_start:_pe_abs_end-_pe_abs_start}" "$_pos"
            _cmd_pos=0
            return
        fi

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
                (( _pos++ ))
                _emit VAR_LITERAL "\$${next}"
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
    # _dollar_quote_string — consume $"..." or $'...' starting at _pos.
    # $1 is the closing quote char; emits token type $2. On EOL without a
    # closing quote, emits the partial token and consumes the rest of _src.
    # --------------------------------------------------------------------------
    _dollar_quote_string() {
        local _close="$1" _type="$2"
        local _qs=$(( _pos + 2 ))
        while (( _qs < ${#_src} )); do
            local _qc="${_src:_qs:1}"
            [[ "$_qc" == '\' ]] && (( _qs += 2 )) && continue
            if [[ "$_qc" == "$_close" ]]; then
                _emit "$_type" "${_src:_pos:_qs-_pos+1}" "$((_qs + 1))"
                _pos=$(( _qs + 1 ))
                break
            fi
            (( _qs++ ))
        done
        # EOL without closing quote — emit partial and consume rest of line
        if (( _qs >= ${#_src} && _pos < ${#_src} )); then
            _emit "$_type" "${_src:_pos}" "${#_src}"
            _pos=${#_src}
        fi
    }

    # --------------------------------------------------------------------------
    # _comment — consume # through end of _src; emits COMMENT
    # --------------------------------------------------------------------------
    _comment() {
        _pos=${#_src}
        _emit COMMENT "${_src:_token_start}" "$_pos"
    }

    # --------------------------------------------------------------------------
    # _collect_heredoc — shared heredoc-body matcher used by both the main loop
    # (_heredoc_body, which emits tokens) and _subshell_scan (which inlines the
    # body into the CMD_SUB/PROC_SUB value). Consumes lines from _lines/_li until
    # the delimiter marker; does NOT touch _full_src/_src_offset (the close-time
    # recompute handles offsets). Sets closure-scoped outputs:
    #   _hd_collected  body text (lines joined by \n; <<- strips leading tabs)
    #   _hd_tail       the matched delimiter line, or "" if EOF reached first
    #   _hd_found      true if the delimiter was found
    #   _hd_had_line   true if at least one body line was read
    _collect_heredoc() {
        local marker="$1" has_dash="$2" allow_remainder="${3:-false}"
        _hd_collected=""; _hd_tail=""; _hd_found=false; _hd_had_line=false
        _hd_remainder=""; _hd_has_remainder=false
        local sep=""
        while (( _li < ${#_lines[@]} )); do
            local line="${_lines[_li]}"
            (( _li++ ))
            # Backslash-newline continuation: an unquoted heredoc delimiter
            # performs \<NL> joining, so a body line ending in an odd number of
            # backslashes splices the next physical line on (trailing backslash
            # removed) BEFORE delimiter matching. Quoted delimiters disable it.
            if [[ "$_hd_literal" == true ]]; then
                while :; do
                    local _bs="${line##*[!\\]}"
                    (( ${#_bs} % 2 == 1 )) || break
                    (( _li < ${#_lines[@]} )) || break
                    line="${line%\\}${_lines[_li]}"
                    (( _li++ ))
                done
            fi
            local check="$line"
            [[ "$has_dash" == true ]] && check="${line#"${line%%[!$'\t']*}"}"
            if [[ "$check" == "$marker" ]]; then
                _hd_tail="$check"; _hd_found=true
                return 0
            fi
            # Delimiter sharing its line with the ) that closes an enclosing
            # subshell (bash permits "$(<<E)" with the ) on the delimiter line).
            # Opt-in: only _subshell_scan wants the remainder handed back.
            if [[ "$allow_remainder" == true && -n "$marker" \
                  && "${check:0:${#marker}}" == "$marker" ]]; then
                local _hd_rest="${check:${#marker}}"
                if [[ "$_hd_rest" =~ ^[[:space:]]*\) ]]; then
                    _hd_tail="$marker"; _hd_found=true
                    _hd_remainder="$_hd_rest"; _hd_has_remainder=true
                    return 0
                fi
            fi
            # \<NL>-joined body line that embeds the procsub-closing ) but is
            # not the delimiter (e.g. "a[)"). Split at the first ) : the part
            # before it is body, the ) onward is the remainder that closes the
            # enclosing procsub. The heredoc stays unterminated (EOF synth, an
            # empty delimiter line), matching bash's canonical AST.
            if [[ "$_hd_literal" == true && "$allow_remainder" == true \
                  && -n "$marker" && "$check" == *')'* ]]; then
                local _hd_pre="${check%%)*}"
                _hd_collected="${_hd_collected}${sep}${_hd_pre}"
                _hd_had_line=true
                _hd_remainder="${check:${#_hd_pre}}"
                _hd_has_remainder=true
                return 1
            fi
            if [[ "$has_dash" == true ]]; then
                _hd_collected="${_hd_collected}${sep}${check}"
            else
                _hd_collected="${_hd_collected}${sep}${line}"
            fi
            sep=$'\n'
            _hd_had_line=true
        done
        return 1
    }

    # _heredoc_body — consume heredoc body; emits HEREDOC_BODY + HEREDOC_TAIL
    # --------------------------------------------------------------------------
    _heredoc_body() {
        local marker="$1" has_dash="$2"
        _collect_heredoc "$marker" "$has_dash"
        local body="$_hd_collected"
        # Empty body with one empty line emits "\n"; no lines emits "".
        [[ "$_hd_had_line" == true && -z "$body" ]] && body=$'\n'
        _emit HEREDOC_BODY "$(_lit "$body")"
        $_hd_found && _emit HEREDOC_TAIL "$_hd_tail"
    }

    # --------------------------------------------------------------------------
    # _maybe_merge_vfd — merge preceding {varname} into last REDIRECT token
    # --------------------------------------------------------------------------
    _maybe_merge_vfd() {
        # Requires at least 3 tokens: {, WORD, }
        (( _tc >= 3 )) || return 0
        local _i=$(( _tc - 1 ))
        [[ "${_tk_type[_i]}" == "REDIRECT" ]] || return 0
        local _j=$(( _i - 3 ))
        (( _j >= 0 )) || return 0
        [[ "${_tk_type[_j]}" == "OP" && "${_tk_val[_j]}" == '{' ]] || return 0
        [[ "${_tk_type[_j+1]}" == "WORD" ]] || return 0
        [[ "${_tk_type[_j+2]}" == "OP" && "${_tk_val[_j+2]}" == '}' ]] || return 0
        # Merge: {WORD}REDIRECT
        _tk_val[_i]="{${_tk_val[_j+1]}}${_tk_val[_i]}"
        # Remove the {, WORD, } tokens
        _tk_type[_j]="__DEL__"
        _tk_val[_j]=""
        _tk_type[_j+1]="__DEL__"
        _tk_val[_j+1]=""
        _tk_type[_j+2]="__DEL__"
        _tk_val[_j+2]=""
    }

    # --------------------------------------------------------------------------
    # _maybe_merge_vfd_hs — merge preceding {varname} into last HEREDOC_HEAD
    # --------------------------------------------------------------------------
    _maybe_merge_vfd_hs() {
        (( _tc >= 3 )) || return 0
        local _i=$(( _tc - 1 ))
        [[ "${_tk_type[_i]}" == "HEREDOC_HEAD" ]] || return 0
        local _j=$(( _i - 3 ))
        (( _j >= 0 )) || return 0
        [[ "${_tk_type[_j]}" == "OP" && "${_tk_val[_j]}" == '{' ]] || return 0
        [[ "${_tk_type[_j+1]}" == "WORD" ]] || return 0
        [[ "${_tk_type[_j+2]}" == "OP" && "${_tk_val[_j+2]}" == '}' ]] || return 0
        _tk_val[_i]="{${_tk_val[_j+1]}}${_tk_val[_i]}"
        _tk_type[_j]="__DEL__"
        _tk_val[_j]=""
        _tk_type[_j+1]="__DEL__"
        _tk_val[_j+1]=""
        _tk_type[_j+2]="__DEL__"
        _tk_val[_j+2]=""
    }

    # --------------------------------------------------------------------------
    # _is_brace_exp — lookahead probe: does _src[from..] contain a valid brace
    # expansion starting at 'from'?  Returns 0 (true) if:
    #   - there is a matching } (accounting for nesting and quotes)
    #   - the content between { } contains a , or .. (brace expansion markers)
    #   - the content is not empty {}
    # Sets _brace_end to the index just past the closing }.
    # --------------------------------------------------------------------------
    _brace_end=0
    _is_brace_exp() {
        local from="$1"  # index of the opening {
        local i=$(( from + 1 ))
        local depth=1 has_marker=0
        local sq=0 dq=0
        while (( i < ${#_src} )); do
            local bc="${_src:i:1}"
            if (( sq )); then
                [[ "$bc" == "'" ]] && sq=0
                (( i++ )); continue
            fi
            if (( dq )); then
                [[ "$bc" == '\' ]] && { (( i += 2 )); continue; }
                [[ "$bc" == '"' ]] && dq=0
                (( i++ )); continue
            fi
            case "$bc" in
                "'") sq=1 ;;
                '"') dq=1 ;;
                '\') (( i += 2 )); continue ;;
                '{') (( depth++ )) ;;
                '}')
                    (( depth-- ))
                    if (( depth == 0 )); then
                        # Found matching } — valid only if non-empty and has marker
                        if (( i > from + 1 && has_marker )); then
                            _brace_end=$(( i + 1 ))
                            return 0
                        fi
                        return 1
                    fi ;;
                ',') (( depth == 1 )) && has_marker=1 ;;
                '.')
                    # Check for .. range marker
                    [[ "${_src:i:2}" == '..' ]] && (( depth == 1 )) && has_marker=1 ;;
            esac
            (( i++ ))
        done
        return 1  # no matching }
    }

    # --------------------------------------------------------------------------
    # _consume_brace_exp — consume a brace expansion (and any adjacent word
    # content) starting at _pos; emits WORD with the full raw source slice.
    # Called when _op sees { in word position, OR when _word hits { mid-word.
    # --------------------------------------------------------------------------
    _consume_brace_exp() {
        local brace_start=$_pos
        # Consume the brace group
        _pos=$_brace_end
        # Continue consuming any adjacent word characters or further brace expansions
        while (( _pos < ${#_src} )); do
            local _bc="${_src:_pos:1}"
            case "$_bc" in
                '{')
                    if _is_brace_exp "$_pos"; then
                        _pos=$_brace_end; continue
                    fi
                    break ;;
                ' '|$'\t'|$'\r'|$'\n'|';'|'|'|'&'|'<'|'>'|'('|')')
                    break ;;
                '\')
                    (( _pos + 1 < ${#_src} )) && { (( _pos += 2 )); continue; }
                    break ;;
                "'") _sq; continue ;;
                '"') _dq; continue ;;
                '`') _backtick; continue ;;
                '$')
                    case "${_src:_pos:3}" in '$((') _arith; continue ;; esac
                    case "${_src:_pos:2}" in
                        '$(') _cmdsub; continue ;;
                        '${') _paramexp; continue ;;
                    esac
                    _var_literal; continue ;;
                '}') break ;;  # lone } is an OP
            esac
            (( _pos++ ))
        done
        _emit WORD "${_src:brace_start:_pos-brace_start}"
        _cmd_pos=0
    }

    # --------------------------------------------------------------------------
    # _op — consume an operator at _pos; emits OP, REDIRECT, or HEREDOC_HEAD
    # --------------------------------------------------------------------------
    _op() {
        local three="${_src:_pos:3}" two="${_src:_pos:2}" one="${_src:_pos:1}"

        # Three-char operators — advance _pos BEFORE _emit for correct end position
        case "$three" in
            ';;&') (( _pos += 3 )); _emit OP  ';;&'; (( ${#_case_stack[@]} )) && _case_stack[-1]="PAT"; _cmd_pos=1; return ;;
            '&>>'|'2>>'|'2>&'|'1>&')
                   (( _pos += 3 )); _emit REDIRECT "$three"; return ;;
            '<<<') (( _pos += 3 )); _emit REDIRECT '<<<'; _maybe_merge_vfd; return ;;
            '<<-') (( _pos += 3 )); _emit HEREDOC_HEAD '<<-'; return ;;
        esac

        # Two-char operators
        case "$two" in
            '<<<') (( _pos += 3 )); _emit REDIRECT '<<<'; _maybe_merge_vfd; return ;;
            '<<')  (( _pos += 2 )); _emit HEREDOC_HEAD '<<'; return ;;
            '<('|'>(') _cmdsub_ps "${two:0:1}"; return ;;
            '((')  _arith_stmt; return ;;
            ';;')  (( _pos += 2 )); _emit OP  ';;'; (( ${#_case_stack[@]} )) && _case_stack[-1]="PAT"; _cmd_pos=1; return ;;
            ';&')  (( _pos += 2 )); _emit OP  ';&'; (( ${#_case_stack[@]} )) && _case_stack[-1]="PAT"; _cmd_pos=1; return ;;
            '&&')  (( _pos += 2 )); _emit OP  '&&'; _cmd_pos=1; return ;;
            '||')  (( _pos += 2 )); _emit OP  '||'; _cmd_pos=1; return ;;
            '|&')  (( _pos += 2 )); _emit OP  '|&'; _cmd_pos=1; return ;;
            '>>'|'>&'|'<&'|'<>'|'&>'|'>|')
                   (( _pos += 2 )); _emit REDIRECT "$two"; _maybe_merge_vfd; return ;;
        esac

        # Single-char — advance _pos BEFORE _emit
        case "$one" in
            ';')         (( _pos++ )); _emit OP       "$one"; _cmd_pos=1; return ;;
            '|'|'&')     (( _pos++ )); _emit OP       "$one"; _cmd_pos=1; return ;;
            '(')         (( _pos++ )); _emit OP       "$one"; _cmd_pos=1; return ;;
            ')')
                # Close a folded array-assignment WORD (name=(...)): discard
                # interior tokens, re-emit the verbatim source slice as one WORD.
                if (( _array_depth > 0 )); then
                    (( _pos++ )); (( _array_depth-- ))
                    _tc=$_array_saved_tc
                    local _end=$(( _src_offset + _pos ))
                    _token_start=$(( _array_start_off - _src_offset ))
                    _emit WORD "${_full_src:_array_start_off:_end-_array_start_off}" "$_pos"
                    _cmd_pos=0
                    return
                fi
                (( _pos++ )); _emit OP "$one"; _cmd_pos=1; return ;;
            '{')
                # In word position with a matching }: if the char after }
                # is a redirect operator (> < & |), emit as OP for var-fd
                # merge; otherwise consume the whole { ... } as a word.
                if (( _cmd_pos == 0 )); then
                    local _bi=$(( _pos + 1 )) _bd=1 _bsq=0 _bdq=0
                    while (( _bi < ${#_src} )); do
                        local _bc="${_src:_bi:1}"
                        if (( _bsq )); then
                            [[ "$_bc" == "'" ]] && _bsq=0
                            (( _bi++ )); continue
                        fi
                        if (( _bdq )); then
                            [[ "$_bc" == '\' ]] && { (( _bi += 2 )); continue; }
                            [[ "$_bc" == '"' ]] && _bdq=0
                            (( _bi++ )); continue
                        fi
                        case "$_bc" in
                            "'") _bsq=1 ;;
                            '"') _bdq=1 ;;
                            '\') (( _bi += 2 )); continue ;;
                            '{') (( _bd++ )) ;;
                            '}')
                                (( _bd-- ))
                                if (( _bd == 0 )); then
                                    local _after="${_src:_bi+1:1}"
                                    if [[ "$_after" != '>' && "$_after" != '<' && "$_after" != '&' ]]; then
                                        local _we=$(( _bi + 1 ))
                                        _emit WORD "${_src:_pos:_we-_pos}"
                                        _pos=$_we
                                        return
                                    fi
                                    break 2  # fall through to OP handling
                                fi ;;
                        esac
                        (( _bi++ ))
                    done
                fi
                # Block delimiter or var-fd: emit as OP, reset to cmd position, track block depth
                (( _pos++ )); _emit OP '{'; _cmd_pos=1; (( _brace_depth++ )); return ;;
            '}')
                # If inside a brace block, emit as OP and decrement depth.
                # Otherwise, } is a regular character — emit as WORD.
                if (( _brace_depth > 0 )); then
                    (( _pos++ )); _emit OP '}'; (( _brace_depth-- )); return
                fi
                (( _pos++ )); _emit WORD '}'; return ;;
            '>'|'<')     (( _pos++ )); _emit REDIRECT "$one"; _maybe_merge_vfd; return ;;
            $'\n')       (( _pos++ )); _emit OP       $'\n';  _cmd_pos=1; return ;;
        esac

        _word
    }

    # --------------------------------------------------------------------------
    # _consume_extglob — consume an extglob pattern *( ) +( ) ?( ) @( ) !( )
    # starting at _pos (which must be at the operator).  Returns 0 if a balanced
    # pattern was consumed (advancing _pos past the closing )), or 1 if the
    # operator is not followed by ( or no matching ) is found.
    # --------------------------------------------------------------------------
    _consume_extglob() {
        local op_char="${_src:_pos:1}"
        [[ "$op_char" == '*' || "$op_char" == '+' || "$op_char" == '?' \
            || "$op_char" == '@' || "$op_char" == '!' ]] || return 1
        local next="${_src:_pos+1:1}"
        [[ "$next" == '(' ]] || return 1
        # Scan for balanced ) starting after the opening (
        local i=$(( _pos + 2 )) depth=1
        while (( i < ${#_src} && depth > 0 )); do
            local c="${_src:i:1}"
            if   [[ "$c" == '(' ]]; then (( depth++ ))
            elif [[ "$c" == ')' ]]; then
                (( depth-- ))
                (( depth == 0 )) && break
            elif [[ "$c" == '\' ]]; then (( i += 2 )); continue
            elif [[ "$c" == "'" ]]; then
                # Single-quoted string — consume until unescaped '
                (( i++ ))
                while (( i < ${#_src} )) && [[ "${_src:i:1}" != "'" ]]; do (( i++ )); done
            elif [[ "$c" == '"' ]]; then
                # Double-quoted string — consume until unescaped "
                (( i++ ))
                while (( i < ${#_src} )); do
                    local _dc="${_src:i:1}"
                    [[ "$_dc" == '\' ]] && { (( i += 2 )); continue; }
                    [[ "$_dc" == '"' ]] && break
                    (( i++ ))
                done
            fi
            (( i++ ))
        done
        (( depth == 0 )) || return 1
        _pos=$(( i + 1 ))
        return 0
    }

    # --------------------------------------------------------------------------
    # _word — consume a bare word at _pos; emits WORD
    # --------------------------------------------------------------------------
    _word() {
        local start=$_pos
        local _wd_bracket=0  # depth inside [...] array subscript
        local c
        while (( _pos < ${#_src} )); do
            c="${_src:_pos:1}"
            # Inside [...]: whitespace is allowed, ] closes at depth 0
            if (( _wd_bracket > 0 )); then
                case "$c" in
                    '[') (( _wd_bracket++ )) ;;
                    ']') (( _wd_bracket-- )) ;;
                    $'\n')
                        # Newline inside [...]: pull next line
                        if (( _li < ${#_lines[@]} )); then
                            _src="${_src:0:_pos}${_lines[_li]}"
                            (( _li++ ))
                        fi ;;
                esac
                (( _pos++ )); continue
            fi
            case "$c" in
                '\')
                    # Backslash escape: consume next char as part of word
                    if (( _pos + 1 < ${#_src} )); then
                        (( _pos += 2 ))
                        continue
                    fi
                    # Trailing \ at end of line — include it as literal in the word
                    (( _pos++ ))
                    break ;;
                '[')
                    # Only enter array-subscript swallow mode (where unquoted
                    # whitespace is permitted, e.g. arr[x + y]=1) when the [ is
                    # attached to a preceding name char. A leading [ / [[ (the
                    # test builtin, a glob class, or [[: ) is NOT a subscript:
                    # bash word-splits inside it, so treat [ as an ordinary word
                    # char and let whitespace/metachars end the word normally.
                    # Enter array-subscript swallow mode (unquoted whitespace
                    # permitted) only for a real subscript: either attached to a
                    # preceding name char (arr[x + y]) or appearing inside an
                    # array-assignment value (a=([k]=v), _array_depth>0). A
                    # leading [ / [[ at command position (test, glob class, [[:)
                    # is NOT a subscript — bash word-splits inside it — so it
                    # stays an ordinary char and whitespace ends the word.
                    if { (( _pos > start )) && [[ "${_src:_pos-1:1}" == [[:alnum:]_] ]]; } \
                       || (( _array_depth > 0 )); then
                        (( _wd_bracket++ ))
                    fi
                    (( _pos++ )); continue ;;
                '{')
                    # Mid-word brace expansion: consume {..} inline if it looks like expansion
                    if _is_brace_exp "$_pos"; then
                        _pos=$_brace_end; continue
                    fi
                    break ;;
                ' '|$'\t'|$'\r'|$'\n'|';'|'|'|'&'|'<'|'>'|'('|')'|"'"|\"|'`'|'$'|'}')
                    break ;;
                '#')
                    # # only starts a comment at the beginning of a word
                    (( _pos == start )) && break ;;
            esac
            (( _pos++ ))
        done
        # Extglob: if word ends with *( +( ?( @( !( and is immediately followed by (
        # (possibly with intervening word chars already consumed), consume the pattern.
        # The extglob operator must be the last char consumed so far and be followed by (.
        if (( _pos > start )); then
            local last_char="${_src:_pos-1:1}"
            case "$last_char" in
                '*'|'+'|'?'|'@'|'!')
                    if [[ "${_src:_pos:1}" == '(' ]]; then
                        # Back up to the operator and try extglob consumption
                        local op_pos=$(( _pos - 1 ))
                        local _saved_pos=$_pos
                        _pos=$op_pos
                        if _consume_extglob; then
                            : # _pos advanced past )
                        else
                            _pos=$_saved_pos
                        fi
                    fi ;;
            esac
        fi
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
                    '&'|'<')
                        # Consume all following digits for multi-digit fd
                        while (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" =~ [0-9] ]]; do
                            _rval+="${_src:_pos:1}"
                            (( _pos++ ))
                        done
                        # Consume optional - (fd close)
                        if (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" == '-' ]]; then
                            _rval+='-'
                            (( _pos++ ))
                        fi
                        ;;
                    esac
                    _tk_val[$(( _tc - 1 ))]="$_rval"
                fi
                return ;;
            esac
        fi
        # Array assignment name=(...) / name+=(...) in command position: bash
        # lexes this as a single WORD. Fold the upcoming (...) into this word
        # instead of emitting it now; the closing ) in _op finalizes it.
        if (( _cmd_pos == 1 && _array_depth == 0 )) \
           && [[ "$word" =~ ^[A-Za-z_][A-Za-z0-9_]*\+?=$ ]] \
           && [[ "${_src:_pos:1}" == '(' ]]; then
            _array_start_off=$(( _src_offset + start ))
            _array_saved_tc=$_tc
            _array_name="$word"
            (( _array_depth++ ))
            return
        fi
        _emit WORD "$word"
        _cmd_pos=0

        # Keywords that reset to command position (next token is in cmd pos context)
        case "$word" in
            do|then|else|elif|fi|done|esac|coproc|'{') _cmd_pos=1 ;;
        esac

        # After =~, raw-scan to ]] and emit the entire regex as REGEX_PATTERN
        if [[ "$word" == "=~" ]]; then
            # Skip leading whitespace
            while (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" =~ [[:space:]] ]]; do
                (( _pos++ ))
            done
            local _rx_start=$_pos
            # Scan until ]] (not inside a bracket expression)
            local _bracket_depth=0
            while (( _pos < ${#_src} )); do
                local _c="${_src:_pos:1}"
                # Backslash escapes the next char (e.g. \[ is a literal, not a
                # bracket-expression open) — skip both so bracket tracking and
                # the ]] terminator aren't corrupted.
                if [[ "$_c" == '\' ]]; then
                    (( _pos += 2 )); continue
                fi
                # Outside a bracket expression the =~ RHS is a single word:
                # quotes group (whitespace inside is literal), and unquoted
                # whitespace ends the regex — e.g. the space before ) in
                # [[ ( x =~ re ) ]] must not be swallowed into the pattern.
                if (( _bracket_depth == 0 )); then
                    if [[ "$_c" == "'" ]]; then
                        (( _pos++ ))
                        while (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" != "'" ]]; do
                            (( _pos++ ))
                        done
                        (( _pos++ )); continue
                    elif [[ "$_c" == '"' ]]; then
                        (( _pos++ ))
                        while (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" != '"' ]]; do
                            [[ "${_src:_pos:1}" == '\' ]] && (( _pos++ ))
                            (( _pos++ ))
                        done
                        (( _pos++ )); continue
                    elif [[ "$_c" == ' ' || "$_c" == $'\t' ]]; then
                        break
                    fi
                fi
                if [[ "$_c" == '[' ]]; then
                    (( _bracket_depth++ ))
                elif [[ "$_c" == ']' ]]; then
                    if (( _bracket_depth > 0 )); then
                        (( _bracket_depth-- ))
                    elif [[ "${_src:$(( _pos + 1 )):1}" == ']' ]]; then
                        break
                    fi
                fi
                (( _pos++ ))
            done
            local _rx="${_src:_rx_start:_pos-_rx_start}"
            # Trim trailing whitespace
            while [[ "${_rx: -1}" == ' ' || "${_rx: -1}" == $'\t' ]]; do _rx="${_rx%?}"; done
            if [[ -n "$_rx" ]]; then
                _token_start=$_rx_start
                _emit REGEX_PATTERN "$_rx"
            fi
            # Emit ]] as WORD
            if [[ "${_src:_pos:2}" == "]]" ]]; then
                _token_start=$_pos
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
            if [[ "$c" == '\' ]]; then
                # Escaped character — skip next char
                (( _pos += 2 ))
                continue
            elif [[ "$c" == "'" ]]; then
                # Single-quoted span — a ) or ( inside is literal, no escapes.
                (( _pos++ ))
                while (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" != "'" ]]; do
                    (( _pos++ ))
                done
                (( _pos++ ))
                continue
            elif [[ "$c" == '"' ]]; then
                # Double-quoted span — ) or ( inside is literal; \ escapes.
                (( _pos++ ))
                while (( _pos < ${#_src} )) && [[ "${_src:_pos:1}" != '"' ]]; do
                    [[ "${_src:_pos:1}" == '\' ]] && (( _pos++ ))
                    (( _pos++ ))
                done
                (( _pos++ ))
                continue
            elif [[ "$c" == '(' ]]; then
                (( depth++ ))
            elif [[ "$c" == ')' ]]; then
                if (( depth == 0 )); then
                    # This ) closes the arm pattern
                    buf="${_src:start:_pos-start}"
                    _emit REGEX_PATTERN "$buf"
                    (( _pos++ ))
                    _emit OP ")" "$_pos"
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
        while (( _pos < ${#_src} )); do
            _token_start=$_pos
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
                    '$[') _arith_deprecated; continue ;;
                    # $"..." locale-translated string, $'...' ANSI-C string
                    '$"') _dollar_quote_string '"' LOCALE_STRING; continue ;;
                    "$'") _dollar_quote_string "'" RICH_STRING;  continue ;;
                esac
                # Unbraced variable expansion
                local next="${_src:$(( _pos + 1 )):1}"
                case "$next" in
                    [a-zA-Z_]|'#'|'@'|'*'|'?'|'$'|'!'|'-'|'0'|[1-9])
                        _var_literal
                        # Extglob after special param: $?() $@() $*( ) etc.
                        if (( _tc > 0 )) && [[ "${_src:_pos:1}" == '(' ]]; then
                            _vl_val="${_tk_val[$(( _tc - 1 ))]}"
                            _vl_last="${_vl_val: -1}"
                            case "$_vl_last" in
                                '*'|'+'|'?'|'@'|'!')
                                    _eg_op_pos=$(( _pos - 1 ))
                                    _saved_pos=$_pos
                                    _pos=$_eg_op_pos
                                    if _consume_extglob; then
                                        # Emit extglob pattern as a separate token
                                        # so word-accumulator merges it with the VAR_LITERAL
                                        _emit EXTGLOB "${_src:_eg_op_pos:_pos-_eg_op_pos}"
                                    else
                                        _pos=$_saved_pos
                                    fi ;;
                            esac
                        fi
                        continue ;;
            *)
                (( _pos++ )); _emit WORD '$'; continue ;;
                esac ;;

            # Quoted strings and backtick
            "'") _sq; [[ $? -eq 94 ]] && _sq_open=1; continue ;;
            '"') _dq_stack=(); _dq_cmd_depth=0; _dq
                 [[ $? -eq 94 ]] && _dq_open=1; continue ;;
            '`') _backtick; continue ;;

            # Operators
            ';'|'|'|'&'|'<'|'>'|'('|')'|'{'|'}'|$'\n')
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

    # First pass: identify heredoc body lines (for the preprocessor).
    # In bash, line continuation (\<NL>) is NOT applied inside heredoc bodies.
    # We mark lines that are between a <<MARKER and its closing marker.
    local -a _heredoc_body_lines=()  # 1 if line is heredoc body, 0 otherwise
    {
        local _hbl_i=0 _hbl_in_heredoc=0 _hbl_marker=""
        local _hbl_sq=0 _hbl_dq=0 _hbl_sub=0
        for _hbl_line in "${_lines[@]}"; do
            _heredoc_body_lines[$_hbl_i]=0
            if (( _hbl_in_heredoc )); then
                _heredoc_body_lines[$_hbl_i]=1
                local _hbl_check="$_hbl_line"
                [[ "$_hbl_has_dash" == true ]] && _hbl_check="${_hbl_line#"${_hbl_line%%[!$'\t']*}"}"
                if [[ "$_hbl_check" == "$_hbl_marker" ]]; then
                    _hbl_in_heredoc=0
                fi
                (( _hbl_i++ )); continue
            fi
            # Scan the line for << or <<- (outside quotes)
            local _hbl_j=0 _hbl_len=${#_hbl_line}
            _hbl_sq=0; _hbl_dq=0; _hbl_sub=0
            local _hbl_c
            while (( _hbl_j < _hbl_len )); do
                _hbl_c="${_hbl_line:_hbl_j:1}"
                if (( _hbl_sq )); then
                    [[ "$_hbl_c" == "'" ]] && _hbl_sq=0
                    (( _hbl_j++ )); continue
                fi
                if (( _hbl_dq )); then
                    [[ "$_hbl_c" == '\' ]] && { (( _hbl_j += 2 )); continue; }
                    [[ "$_hbl_c" == '"' ]] && _hbl_dq=0
                    (( _hbl_j++ )); continue
                fi
                if (( _hbl_sub > 0 )); then
                    [[ "$_hbl_c" == '\' ]] && { (( _hbl_j += 2 )); continue; }
                    [[ "$_hbl_c" == '$' && "${_hbl_line:_hbl_j+1:1}" == '(' ]] && { (( _hbl_sub++ )); (( _hbl_j += 2 )); continue; }
                    [[ "$_hbl_c" == '(' ]] && (( _hbl_sub++ ))
                    [[ "$_hbl_c" == ')' ]] && (( _hbl_sub-- ))
                    (( _hbl_j++ )); continue
                fi
                case "$_hbl_c" in
                    "'") _hbl_sq=1 ;;
                    '"') _hbl_dq=1 ;;
                    '$')
                        [[ "${_hbl_line:_hbl_j+1:1}" == '(' ]] && { (( _hbl_sub++ )); (( _hbl_j += 2 )); continue; }
                        ;;
                    '<')
                        if [[ "${_hbl_line:_hbl_j+1:1}" == '<'
                              && "${_hbl_line:_hbl_j+2:1}" != '<'
                              && (( _hbl_j == 0 || "${_hbl_line:_hbl_j-1:1}" != '<' )) ]]; then
                            local _hbl_skip=2
                            _hbl_has_dash=false
                            [[ "${_hbl_line:_hbl_j+2:1}" == '-' ]] && { _hbl_has_dash=true; _hbl_skip=3; }
                            local _hbl_tag_pos=$(( _hbl_j + _hbl_skip ))
                            # Skip whitespace
                            while (( _hbl_tag_pos < _hbl_len )) && [[ "${_hbl_line:_hbl_tag_pos:1}" == ' ' || "${_hbl_line:_hbl_tag_pos:1}" == $'\t' ]]; do
                                (( _hbl_tag_pos++ ))
                            done
                            # Read the marker (possibly quoted)
                            local _hbl_tag="" _hbl_qc=""
                            local _hbl_ch="${_hbl_line:_hbl_tag_pos:1}"
                            if [[ "$_hbl_ch" == '"' || "$_hbl_ch" == "'" || "$_hbl_ch" == '`' ]]; then
                                _hbl_qc="$_hbl_ch"; (( _hbl_tag_pos++ ))
                            fi
                            while (( _hbl_tag_pos < _hbl_len )); do
                                _hbl_ch="${_hbl_line:_hbl_tag_pos:1}"
                                if [[ -n "$_hbl_qc" && "$_hbl_ch" == "$_hbl_qc" ]]; then
                                    (( _hbl_tag_pos++ )); break
                                fi
                                # Mirror _subshell_scan: metachars end the word;
                                # `<`/`>` terminate unless `<(`/`>(` proc-sub.
                                if [[ -z "$_hbl_qc" ]]; then
                                    case "$_hbl_ch" in
                                        ' '|$'\t'|';'|')'|$'\n'|'|'|'&') break ;;
                                        '<'|'>') [[ "${_hbl_line:_hbl_tag_pos+1:1}" != '(' ]] && break ;;
                                    esac
                                fi
                                _hbl_tag+="$_hbl_ch"; (( _hbl_tag_pos++ ))
                            done
                            # Quoted marker: strip quotes
                            if [[ -n "$_hbl_qc" ]]; then
                                _hbl_marker="${_hbl_tag}"
                            else
                                _hbl_marker="${_hbl_tag}"
                            fi
                            _hbl_in_heredoc=1
                            break
                        fi
                        ;;
                esac
                (( _hbl_j++ ))
            done
            (( _hbl_i++ ))
        done
    }

    # Pre-process: join line-continuations (\ followed by newline) outside single quotes.
    # In bash, \<NL> is stripped before tokenisation in all contexts except inside '...'.
    # We track quote state carefully: ' only toggles SQ when not inside "..." or $'...',
    # and we skip ' inside $(...) subshells (where it would open/close SQ inside cmdsub).
    # NOTE: line continuation is NOT applied inside heredoc bodies.
    local -a _joined=()
    local -a _lc_stack=("top")   # lexical context stack; persists across lines
    local -a _lc_save=("top")    # stack snapshot before the current logical line
    local _lc_pending=""
    local _lc_idx=0
    for _lc_line in "${_lines[@]}"; do
        # Heredoc body lines: no line-continuation processing; emit as-is
        if (( _lc_idx < ${#_heredoc_body_lines[@]} )) && [[ "${_heredoc_body_lines[$_lc_idx]}" == "1" ]]; then
            # Still need to flush any pending continuation from a non-heredoc line above
            if [[ -n "$_lc_pending" ]]; then
                _joined+=("$_lc_pending")
                _lc_pending=""
            fi
            _joined+=("$_lc_line")
            (( _lc_idx++ )); continue
        fi
        if [[ -n "$_lc_pending" ]]; then
            # Rescanning the whole logical line: restore the pre-line context so
            # quote state is not applied twice, then prepend the pending text.
            _lc_stack=("${_lc_save[@]}")
            _lc_line="$_lc_pending${_lc_line}"
        else
            _lc_save=("${_lc_stack[@]}")
        fi
        _lc_pending=""
        # Walk each character maintaining a lexical context stack. This honours
        # single quotes inside $( ) (they can span lines and hide `)`), so the
        # `\`<NL> continuation decision below is made in the right context.
        local _lc_j=0 _lc_len=${#_lc_line} _lc_comment=0
        while (( _lc_j < _lc_len )); do
            local _lc_c="${_lc_line:_lc_j:1}"
            case "${_lc_stack[-1]}" in
                sq)
                    [[ "$_lc_c" == "'" ]] && unset '_lc_stack[-1]'
                    (( _lc_j++ )) ;;
                ansi)
                    if [[ "$_lc_c" == '\' ]]; then (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == "'" ]]; then unset '_lc_stack[-1]'; (( _lc_j++ ))
                    else (( _lc_j++ )); fi ;;
                bq)
                    if [[ "$_lc_c" == '\' ]]; then (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == '`' ]]; then unset '_lc_stack[-1]'; (( _lc_j++ ))
                    else (( _lc_j++ )); fi ;;
                dq)
                    if [[ "$_lc_c" == '\' ]]; then (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == '"' ]]; then unset '_lc_stack[-1]'; (( _lc_j++ ))
                    elif [[ "$_lc_c" == '$' && "${_lc_line:_lc_j+1:1}" == '(' ]]; then
                        if [[ "${_lc_line:_lc_j+2:1}" == '(' ]]; then _lc_stack+=(sub sub); (( _lc_j += 3 ))
                        else _lc_stack+=(sub); (( _lc_j += 2 )); fi
                    elif [[ "$_lc_c" == '$' && "${_lc_line:_lc_j+1:1}" == '{' ]]; then
                        _lc_stack+=(param); (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == '`' ]]; then _lc_stack+=(bq); (( _lc_j++ ))
                    else (( _lc_j++ )); fi ;;
                param)
                    if [[ "$_lc_c" == '\' ]]; then (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == '}' ]]; then unset '_lc_stack[-1]'; (( _lc_j++ ))
                    elif [[ "$_lc_c" == '{' ]]; then _lc_stack+=(param); (( _lc_j++ ))
                    elif [[ "$_lc_c" == "'" ]]; then _lc_stack+=(sq); (( _lc_j++ ))
                    elif [[ "$_lc_c" == '"' ]]; then _lc_stack+=(dq); (( _lc_j++ ))
                    elif [[ "$_lc_c" == '$' && "${_lc_line:_lc_j+1:1}" == '(' ]]; then
                        if [[ "${_lc_line:_lc_j+2:1}" == '(' ]]; then _lc_stack+=(sub sub); (( _lc_j += 3 ))
                        else _lc_stack+=(sub); (( _lc_j += 2 )); fi
                    else (( _lc_j++ )); fi ;;
                sub)
                    if [[ "$_lc_c" == '\' ]]; then (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == "'" ]]; then _lc_stack+=(sq); (( _lc_j++ ))
                    elif [[ "$_lc_c" == '"' ]]; then _lc_stack+=(dq); (( _lc_j++ ))
                    elif [[ "$_lc_c" == '$' && "${_lc_line:_lc_j+1:1}" == '(' ]]; then
                        if [[ "${_lc_line:_lc_j+2:1}" == '(' ]]; then _lc_stack+=(sub sub); (( _lc_j += 3 ))
                        else _lc_stack+=(sub); (( _lc_j += 2 )); fi
                    elif [[ "$_lc_c" == '$' && "${_lc_line:_lc_j+1:1}" == '{' ]]; then
                        _lc_stack+=(param); (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == '`' ]]; then _lc_stack+=(bq); (( _lc_j++ ))
                    elif [[ "$_lc_c" == '(' ]]; then _lc_stack+=(sub); (( _lc_j++ ))
                    elif [[ "$_lc_c" == ')' ]]; then unset '_lc_stack[-1]'; (( _lc_j++ ))
                    elif [[ "$_lc_c" == '#' ]]; then _lc_comment=1; break
                    else (( _lc_j++ )); fi ;;
                *)  # top
                    if [[ "$_lc_c" == '\' ]]; then (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == "'" ]]; then _lc_stack+=(sq); (( _lc_j++ ))
                    elif [[ "$_lc_c" == '"' ]]; then _lc_stack+=(dq); (( _lc_j++ ))
                    elif [[ "$_lc_c" == '$' && "${_lc_line:_lc_j+1:1}" == "'" ]]; then
                        _lc_stack+=(ansi); (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == '$' && "${_lc_line:_lc_j+1:1}" == '(' ]]; then
                        if [[ "${_lc_line:_lc_j+2:1}" == '(' ]]; then _lc_stack+=(sub sub); (( _lc_j += 3 ))
                        else _lc_stack+=(sub); (( _lc_j += 2 )); fi
                    elif [[ "$_lc_c" == '$' && "${_lc_line:_lc_j+1:1}" == '{' ]]; then
                        _lc_stack+=(param); (( _lc_j += 2 ))
                    elif [[ "$_lc_c" == '`' ]]; then _lc_stack+=(bq); (( _lc_j++ ))
                    elif [[ "$_lc_c" == '(' ]]; then _lc_stack+=(sub); (( _lc_j++ ))
                    elif [[ "$_lc_c" == '#' ]]; then _lc_comment=1; break
                    else (( _lc_j++ )); fi ;;
            esac
        done
        # \<NL> joins lines everywhere except inside '...', $'...' and comments.
        local _bs_run="${_lc_line##*[^\\]}"
        [[ "$_lc_line" != *'\' ]] && _bs_run=""
        local _lc_top="${_lc_stack[-1]}"
        if [[ "$_lc_top" != "sq" && "$_lc_top" != "ansi" && $_lc_comment -eq 0 ]] && (( ${#_bs_run} % 2 == 1 )); then
            _lc_line="${_lc_line%\\}"
            _lc_pending="$_lc_line"
            (( _lc_idx++ )); continue
        fi
        _joined+=("$_lc_line")
        (( _lc_idx++ ))
    done
    # Flush any pending continuation.
    # If _lc_pending is set, the last line ended with \ which was stripped as
    # a line continuation.  In the real shell this would wait for the next line
    # or report "unexpected end of file"; since we are tokenising a finite
    # buffer, restore the original line (with trailing \) so the tokeniser
    # sees a literal backslash rather than silently losing it.
    if [[ -n "$_lc_pending" ]]; then
        _joined+=("${_lines[-1]}")
    fi
    _lines=("${_joined[@]}")

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

            # This continuation line begins at the current _src_offset within
            # _full_src; mirror the main loop's bookkeeping so tokens emitted
            # after the closing ' get correct source positions (the word-
            # accumulator reconstructs merged WORDs by slicing _full_src).
            local _sq_line_start=$_src_offset
            _full_src+="${_sq_line}"$'\n'

            local _last=$(( _tc - 1 ))
            if (( _sq_close >= 0 )); then
                # Found closing ' — append prefix (with \n separator) and close
                _tk_val[_last]+=$'\n'"${_sq_line:0:_sq_close}"
                # The STRING_SQ token ends just past the closing ' on this line.
                _tk_end_arr[$_last]=$(( _sq_line_start + _sq_close + 1 ))
                _sq_open=0
                # Remainder of the line needs normal tokenisation
                _src="${_sq_line:$(( _sq_close + 1 ))}"
                _pos=0
                _src_offset=$(( _sq_line_start + _sq_close + 1 ))
                _scan_line
                # Advance offset to the start of the next line.
                _src_offset=$(( _sq_line_start + ${#_sq_line} + 1 ))
            else
                # Still no closing ' — append whole line and keep waiting
                _tk_val[_last]+=$'\n'"$_sq_line"
                _src_offset=$(( _sq_line_start + ${#_sq_line} + 1 ))
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
            # Update _full_src and _src_offset for this continuation line so that
            # any tokens emitted after the closing " get correct source positions.
            _full_src+="${_dq_line}"$'\n'
            local _dq_cont_offset=$_src_offset
            (( _src_offset += ${#_dq_line} + 1 ))
            _pos=-1
            _dq
            if (( $? == 94 )); then
                # Still unclosed — prepend \n separator and merge partial into original token
                _tk_val[_last]+="\n${_tk_val[$(( _tc - 1 ))]}"
                (( _tc-- ))
                # Keep the end position on the continuation line so the
                # word-accumulator reconstructs the merged WORD from source
                # across the newline instead of truncating it at line 1.
                _tk_end_arr[_last]=$(( _dq_cont_offset + ${#_dq_line} ))
            else
                # Closed — prepend \n separator and merge into original token
                _tk_val[_last]+="\n${_tk_val[$(( _tc - 1 ))]}"
                (( _tc-- ))
                _dq_open=0
                # End just past the closing " on this continuation line.
                _tk_end_arr[_last]=$(( _dq_cont_offset + _pos ))
                # Scan remainder of the continuation line after the closing "
                # _dq leaves _pos pointing just past the closing quote in _src.
                # Replace _src with the remainder, fix _src_offset, and scan.
                if (( _pos < ${#_src} )); then
                    local _dq_remainder="${_src:_pos}"
                    _src="$_dq_remainder"
                    # _src_offset was already advanced for the full _dq_line;
                    # rewind it to just past the closing quote's position.
                    _src_offset=$(( _dq_cont_offset + _pos ))
                    _scan_line
                    # Re-advance _src_offset for the scanned remainder
                    (( _src_offset = _dq_cont_offset + ${#_dq_line} + 1 ))
                fi
            fi
            continue
        fi

        if (( ${#_pending_hd_marker[@]} > 0 )); then
            local _phk
            for (( _phk=0; _phk < ${#_pending_hd_marker[@]}; _phk++ )); do
                _heredoc_body "${_pending_hd_marker[_phk]}" "${_pending_hd_dash[_phk]}"
            done
            _pending_hd_marker=()
            _pending_hd_dash=()
            continue
        fi

        _src="${_lines[_li]}"
        (( _li++ ))
        _full_src+="${_src}"$'\n'

        _progress_render "Tokenising..." "$_li" "${#_lines[@]}" "lines"
        (( _tc > 0 )) && { _token_start=0; _emit OP $'\n'; }
        _scan_line
        # Advance offset past this line (length + 1 for the newline that was emitted)
        (( _src_offset += ${#_src} + 1 ))

        # Look back for HEREDOC_HEAD + TAG
        # Skip <<< (herestring — no body) and keep looking for << or <<-
        # Delimiter may span multiple tokens: WORD, STRING_*, and OP '\'
        # (e.g., \EOF, E"OF", 'E'OF, E\OF)
        # Marker for body matching is the quote-removed form.
        local _i=$(( _tc - 1 ))
        while (( _i >= 0 )); do
            local _t="${_tk_type[_i]}"
            [[ "$_t" == "OP" && "${_tk_val[_i]}" == $'\n' ]] && break
            if [[ "$_t" == "HEREDOC_HEAD" ]]; then
                [[ "${_tk_val[_i]}" == '<<<' ]] && { (( _i-- )); continue; }
                # Collect consecutive tokens that form the delimiter
                local _j=$(( _i + 1 ))
                local _delim="" _marker=""
                while (( _j < _tc )); do
                    local _tj="${_tk_type[_j]}"
                    if [[ "$_tj" == "WORD" || "$_tj" == "STRING_SQ" || "$_tj" == "STRING_DQ" ]]; then
                        _delim+="${_tk_val[_j]}"
                        # Quote removal for marker: strip surrounding quotes
                        local _dv="${_tk_val[_j]}"
                        if [[ "$_tj" == "STRING_SQ" || "$_tj" == "STRING_DQ" ]]; then
                            _dv="${_dv:1:-1}"
                        fi
                        _marker+="$_dv"
                        _tk_type[_j]="HEREDOC_TAG"
                        (( _j++ ))
                    elif [[ "$_tj" == "OP" && "${_tk_val[_j]}" == '\' ]]; then
                        _delim+='\'
                        # Backslash is a quoting char, not part of marker
                        _tk_type[_j]="HEREDOC_TAG"
                        (( _j++ ))
                    else
                        break
                    fi
                done
                if [[ -n "$_marker" ]] || [[ "${_tk_val[_i]}" == '<<' || "${_tk_val[_i]}" == '<<-' ]]; then
                    _pending_hd_marker+=("$_marker")
                    [[ "${_tk_val[_i]}" == '<<-' ]] \
                        && _pending_hd_dash+=(true) || _pending_hd_dash+=(false)
                fi
                break
            fi
            (( _i-- ))
        done
    done

    # Unclosed array-assignment fold at EOF: the withheld name=( word never
    # got its closing ) as a standalone token (e.g. naive [...] bracket
    # counting followed by a real quote absorbed it into a later WORD).
    # Re-insert the withheld word at its original slot.
    if (( _array_depth > 0 )); then
        local _ai
        for (( _ai=_tc; _ai>_array_saved_tc; _ai-- )); do
            _tk_type[_ai]="${_tk_type[_ai-1]}"
            _tk_val[_ai]="${_tk_val[_ai-1]}"
            _tk_pos_arr[_ai]="${_tk_pos_arr[_ai-1]}"
            _tk_end_arr[_ai]="${_tk_end_arr[_ai-1]}"
        done
        _tk_type[_array_saved_tc]="WORD"
        _tk_val[_array_saved_tc]="$_array_name"
        _tk_pos_arr[_array_saved_tc]=$_array_start_off
        _tk_end_arr[_array_saved_tc]=$(( _array_start_off + ${#_array_name} ))
        (( _tc++ ))
        _array_depth=0
    fi

    # Post-processing: collapse consecutive newline tokens in-place
    # Also compute adjacency: _tk_adj[i]=1 means token i is adjacent to token i-1
    # (no whitespace between them in source)
    local _raw_count=$_tc
    local _wi=0 _ri=0 _prev_nl=0
    for (( _ri=0; _ri<_raw_count; _ri++ )); do
        local _rtype="${_tk_type[_ri]}" _rval="${_tk_val[_ri]}"
        [[ "$_rtype" == "__DEL__" ]] && continue
        if [[ "$_rtype" == "OP" && "$_rval" == $'\n' ]]; then
            (( _prev_nl )) && continue
            _prev_nl=1
        else
            _prev_nl=0
        fi
        if (( _wi != _ri )); then
            _tk_type[_wi]="$_rtype"
            _tk_val[_wi]="$_rval"
            _tk_pos_arr[$_wi]="${_tk_pos_arr[$_ri]}"
            _tk_end_arr[$_wi]="${_tk_end_arr[$_ri]}"
        fi
        (( _wi++ ))
    done
    for (( _ri=_wi; _ri<_raw_count; _ri++ )); do
        unset "_tk_type[_ri]" "_tk_val[_ri]" "_tk_pos_arr[$_ri]" "_tk_end_arr[$_ri]"
    done
    _tc=$_wi
    # Compute adjacency: check if source between consecutive tokens has only spaces/tabs
    # Newlines are NOT whitespace for adjacency (they are line separators)
    # Use END of previous token (not start) as the check origin
    local -a _tk_adj=()
    _tk_adj[0]=0
    for (( i=1; i<_tc; i++ )); do
        local _prev_end=$(( _tk_end_arr[i-1] ))
        local _cur_start=$(( _tk_pos_arr[i] ))
        local _has_ws=0
        for (( j=_prev_end; j<_cur_start; j++ )); do
            local _ch="${_full_src:$j:1}"
            if [[ "$_ch" == ' ' || "$_ch" == $'\t' ]]; then
                _has_ws=1
                break
            fi
        done
        _tk_adj[$i]=$(( _has_ws == 0 ? 1 : 0 ))
    done

    # --------------------------------------------------------------------------
    # Word-accumulator pass — merge adjacent word-constituent tokens into a
    # single WORD token whose val is reconstructed verbatim from _full_src.
    #
    # Mergeable types (word constituents — can appear mid-word in bash):
    #   WORD, VAR_LITERAL, PARAM_EXP, CMD_SUB, ARITH, BACKTICK,
    #   PROC_SUB, STRING_SQ, STRING_DQ, RICH_STRING, LOCALE_STRING,
    #   ARITH_DEPRECATED
    #
    # Non-mergeable (structural — always a word boundary):
    #   OP, REDIRECT, HEREDOC_*, COMMENT, ARITH_STMT, __DEL__
    #
    # ARITH_STMT is explicitly excluded: it is the standalone ((...)) command
    # form, not a word constituent, even though ARITH ($((...))) is.
    #
    # Algorithm: single linear pass; maintain a run of adjacent mergeable tokens.
    # When the run ends (gap, non-mergeable type, or EOL), collapse it into one
    # WORD token using the source slice [run_start_pos, run_end_pos).
    # Runs of length 1 that are already WORD are left as-is (no val change needed,
    # but type is normalised to WORD for consistency).
    # --------------------------------------------------------------------------
    _wa_is_mergeable() {
        case "$1" in
            WORD|VAR_LITERAL|PARAM_EXP|CMD_SUB|ARITH|BACKTICK|\
            PROC_SUB|STRING_SQ|STRING_DQ|RICH_STRING|LOCALE_STRING|\
            ARITH_DEPRECATED|EXTGLOB)
                return 0 ;;
            *) return 1 ;;
        esac
    }

    local _wa_in=0        # index into current (post-newline-collapse) stream
    local _wa_out=0       # write index for compacted output
    local _wa_tc=$_tc

    # Temporary parallel arrays for the merged stream
    local -a _wa_type=() _wa_val=() _wa_pos=() _wa_end=() _wa_adj=()

    while (( _wa_in < _wa_tc )); do
        local _wa_t="${_tk_type[_wa_in]}"

        # Non-mergeable: pass through unchanged
        if ! _wa_is_mergeable "$_wa_t"; then
            _wa_type+=("$_wa_t")
            _wa_val+=("${_tk_val[_wa_in]}")
            _wa_pos+=("${_tk_pos_arr[_wa_in]}")
            _wa_end+=("${_tk_end_arr[_wa_in]}")
            _wa_adj+=("${_tk_adj[_wa_in]}")
            (( _wa_in++ ))
            continue
        fi

        # Start of a potential mergeable run
        local _run_start=$_wa_in
        local _run_src_start="${_tk_pos_arr[_wa_in]}"
        local _run_src_end="${_tk_end_arr[_wa_in]}"
        local _run_adj="${_tk_adj[_wa_in]}"
        (( _wa_in++ ))

        # Extend run while next token is adjacent AND mergeable
        while (( _wa_in < _wa_tc )); do
            local _wa_nt="${_tk_type[_wa_in]}"
            local _wa_nadj="${_tk_adj[_wa_in]}"
            if (( _wa_nadj == 1 )) && _wa_is_mergeable "$_wa_nt"; then
                _run_src_end="${_tk_end_arr[_wa_in]}"
                (( _wa_in++ ))
            else
                break
            fi
        done

        local _run_len=$(( _wa_in - _run_start ))

        if (( _run_len == 1 )); then
            # Single-token run — pass through unchanged
            _wa_type+=("${_tk_type[_run_start]}")
            _wa_val+=("${_tk_val[_run_start]}")
            _wa_pos+=("$_run_src_start")
            _wa_end+=("$_run_src_end")
            _wa_adj+=("$_run_adj")
        else
            # Multi-token run — prefer source reconstruction, but fall back to
            # val concatenation if any token is CMD_SUB or PROC_SUB (their
            # positions may be unreliable after multi-line body pulls).
            local _has_multiline_tok=0 _j
            for (( _j=_run_start; _j<_wa_in; _j++ )); do
                case "${_tk_type[_j]}" in CMD_SUB|PROC_SUB) _has_multiline_tok=1; break ;; esac
            done
            local _merged_val
            if (( _has_multiline_tok )); then
                # Concatenate vals: reconstruct the raw source form per token type
                _merged_val=""
                for (( _j=_run_start; _j<_wa_in; _j++ )); do
                    local _jt="${_tk_type[_j]}" _jv="${_tk_val[_j]}" _jd=""
                    case "$_jt" in
                        PROC_SUB)
                            local _jdir="${_jv%%|*}"
                            _unlit "${_jv#*|}" _jd
                            _merged_val+="${_jdir}(${_jd})" ;;
                        CMD_SUB)   _unlit "$_jv" _jd; _merged_val+="\$(${_jd})" ;;
                        PARAM_EXP) _unlit "$_jv" _jd; _merged_val+="\${${_jd}}" ;;
                        ARITH)     _unlit "$_jv" _jd; _merged_val+="\$((${_jd}))" ;;
                        STRING_SQ) _unlit "$_jv" _jd; _merged_val+="'${_jd}'" ;;
                        STRING_DQ) _unlit "$_jv" _jd; _merged_val+="\"${_jd}\"" ;;
                        *)         _unlit "$_jv" _jd; _merged_val+="$_jd" ;;
                    esac
                done
            else
                # Source reconstruction — positions are reliable
                _merged_val="${_full_src:_run_src_start:$(( _run_src_end - _run_src_start ))}"
            fi
            _wa_type+=("WORD")
            _wa_val+=("$_merged_val")
            _wa_pos+=("$_run_src_start")
            _wa_end+=("$_run_src_end")
            _wa_adj+=("$_run_adj")
        fi
    done

    # Write merged stream back into the caller-visible arrays
    local _wa_new_tc=${#_wa_type[@]}
    for (( i=0; i<_wa_new_tc; i++ )); do
        _tk_type[$i]="${_wa_type[$i]}"
        _tk_val[$i]="${_wa_val[$i]}"
        _tk_pos_arr[$i]="${_wa_pos[$i]}"
        _tk_end_arr[$i]="${_wa_end[$i]}"
        _tk_adj[$i]="${_wa_adj[$i]}"
    done
    # Truncate any leftover entries from the pre-merge stream
    for (( i=_wa_new_tc; i<_wa_tc; i++ )); do
        unset "_tk_type[$i]" "_tk_val[$i]" "_tk_pos_arr[$i]" "_tk_end_arr[$i]" "_tk_adj[$i]"
    done
    _tc=$_wa_new_tc

    # Expose adjacency via nameref if caller passed a base name for it
    if [[ -n "${4:-}" ]]; then
        local -n _tk_adj_out="$4"
        _tk_adj_out=("${_tk_adj[@]}")
    fi
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
