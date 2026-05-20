#!/usr/bin/env bash
# optimize.sh — standalone Bash optimiser
#
# Applies a configurable pipeline of optimisation passes to Bash scripts.
#
# Usage:
#   ./optimize.sh [options] input.sh [output.sh]
#   ./optimize.sh [options] -
#
# Always-on passes (--no-X to disable):
#   fold-constants, dce, positional-inline, array-inline, if-collapse
#
# Opt-in passes:
#   --framehead-specific, --inline-functions, --fold-bc, --dce-aggressive
#
# Inline annotations (shellcheck-style):
#   # optimiser ignore=all
#   # optimiser ignore=inline,dce scope=function
#   # optimiser enable=fold-bc scope=block
#
# Requires: bash 4.3+
# Optional: bc (for --fold-bc)
# _minify_log_mode: unset = progress, "verbose" = verbose, "quiet" = quiet
_minify_log_mode=""

_log_verbose() {
    [[ "$_minify_log_mode" == verbose ]] || return 0
    printf '%s\n' "$*" >&2
}

_log_progress() {
    [[ "$_minify_log_mode" == quiet ]] && return 0
    [[ "$_minify_log_mode" == verbose ]] && return 0
    printf '\r%s' "$*" >&2
}

_log_progress_nl() {
    # Print final newline after progress line to avoid overwrite by next shell output
    [[ "$_minify_log_mode" == quiet ]] && return 0
    [[ "$_minify_log_mode" == verbose ]] && return 0
    printf '\n' >&2
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
# With PE parsing:
#   local -A tokens pe_table
#   local token_count=0
#   PARSE_PE=1 tokenise "$source" tokens token_count pe_table
#
# All helpers are private subfunctions of tokenise().

# ==============================================================================
# tokenise — main entry point
#
# Usage:
#   local -A tokens
#   local token_count=0
#   tokenise "$source" tokens token_count [pe_table_name]
# ==============================================================================
tokenise() {
    local input="$1"
    local -n _tk="$2"
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
        _tk[${_tc}_type]="$1"
        _tk[${_tc}_val]="$2"
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
            local _pe_parsed
            _pe_parsed="$(_parse_pe "$_interior")"
            local _RS=$'\x1E'
            local _pe_prefix="${_pe_parsed%%${_RS}*}"
            local _pe_rest="${_pe_parsed#*${_RS}}"
            local _pe_name="${_pe_rest%%${_RS}*}"
            local _pe_rest2="${_pe_rest#*${_RS}}"
            local _pe_op="${_pe_rest2%%${_RS}*}"
            local _pe_operand="${_pe_rest2#*${_RS}}"
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
    # _parse_pe — parse PE interior into structured val
    #
    # Input:  raw interior string e.g. "var:-default" "!arr[@]" "#str" "var//p/r"
    # Output: prefix RS name RS op RS operand   (RS = $'\x1E')
    #
    # Name extraction: scan until first operator character or end.
    # Operator characters after name: [ : # % / ^ , @ }(end)
    # Special: ## %% // /# /% ^^ ,, are two-char ops.
    # Prefix # and ! must be distinguished from the # operator:
    #   ${#name}  → prefix=#, no op (length of name)
    #   ${name#p} → no prefix, op=#
    # --------------------------------------------------------------------------
    _parse_pe() {
        local raw="$1"
        local RS=$'\x1E'
        local prefix='' name='' op='' operand=''
        local pos=0 len=${#raw}

        # ---- Extract prefix (# or !) ----
        local first="${raw:0:1}"
        if [[ "$first" == '!' ]]; then
            prefix='!'
            (( pos++ ))
        elif [[ "$first" == '#' ]]; then
            # # is prefix (length) only if what follows is a valid name/array
            # and there's no further operator — i.e. ${#var} not ${#} or ${name#pat}
            # Heuristic: if second char is a valid name-start or [ or @ or *
            # and the rest has no operator chars → length prefix
            # Otherwise it's the # removal operator on the name that follows
            local second="${raw:1:1}"
            if [[ "$second" =~ [a-zA-Z_\[\@\*] || "$second" == '#' ]]; then
                prefix='#'
                (( pos++ ))
            fi
            # if second is not a name char, it's ${#} (length of $0 equiv) — keep as-is
        fi

        # ---- Extract name ----
        # Name chars: [a-zA-Z0-9_]  plus [ ] for subscripts
        # Stop at: : # % / ^ , @ and end-of-string
        local name_start=$pos
        local in_subscript=0
        while (( pos < len )); do
            local c="${raw:pos:1}"
            if [[ "$c" == '[' ]]; then
                in_subscript=1
                (( pos++ ))
            elif [[ "$c" == ']' ]]; then
                in_subscript=0
                (( pos++ ))
            elif (( in_subscript )); then
                (( pos++ ))   # anything inside [...] is part of name
            elif [[ "$c" =~ [a-zA-Z0-9_] ]]; then
                (( pos++ ))
            else
                break
            fi
        done
        name="${raw:name_start:pos-name_start}"

        # ---- Extract operator ----
        if (( pos >= len )); then
            # No operator — plain ${name} or ${prefix name}
            printf '%s%s%s%s%s%s%s' "$prefix" "$RS" "$name" "$RS" "$op" "$RS" "$operand"
            return
        fi

        local c1="${raw:pos:1}"
        local c2="${raw:pos:2}"
        local c3="${raw:pos:3}"

        case "$c2" in
            ':-'|':='|':+'|':?')   op="$c2"; (( pos += 2 )) ;;
            '//'|'/#'|'/%')        op="$c2"; (( pos += 2 )) ;;
            '##'|'%%'|'^^'|',,')   op="$c2"; (( pos += 2 )) ;;
            ':-'|':')\
                # bare : is substring  ${name:offset} or ${name:off:len}
                op=':'; (( pos++ )) ;;
            *)
                case "$c1" in
                    ':')  op=':';  (( pos++ )) ;;
                    '#')  op='#';  (( pos++ )) ;;
                    '%')  op='%';  (( pos++ )) ;;
                    '/')  op='/';  (( pos++ )) ;;
                    '^')  op='^';  (( pos++ )) ;;
                    ',')  op=',';  (( pos++ )) ;;
                    '@')  op='@';  (( pos++ )) ;;
                esac ;;
        esac

        # ---- Remainder is operand ----
        operand="${raw:pos}"

        printf '%s%s%s%s%s%s%s' "$prefix" "$RS" "$name" "$RS" "$op" "$RS" "$operand"
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
            local _meta_pat=$'[;|&<>(){}\\\\\\n]'
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
                _tk[${_last}_val]+=$'\n'"${_sq_line:0:_sq_close}"
                _sq_open=0
                # Remainder of the line needs normal tokenisation
                _src="${_sq_line:$(( _sq_close + 1 ))}"
                _pos=0
                _scan_line
            else
                # Still no closing ' — append whole line and keep waiting
                _tk[${_last}_val]+=$'\n'"$_sq_line"
            fi
            continue
        fi

        # Multi-line double-quoted string continuation
        if (( _dq_open )); then
            local _dq_line="${_lines[_li]}"
            (( _li++ ))
            local _last=$(( _tc - 1 ))
            # Append newline + new line content to last token val
            _tk[${_last}_val]+="\n"
            _src="$_dq_line"
            _pos=0
            _dq
            if (( $? == 94 )); then
                # Still unclosed — append what _dq scanned and keep waiting
                _tk[${_last}_val]+="${_tk[$(( _tc - 1 ))_val]}"
                (( _tc-- ))
            else
                # Closed — merge the continuation into the original token
                _tk[${_last}_val]+="${_tk[$(( _tc - 1 ))_val]}"
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

        (( _tc > 0 )) && _emit OP $'\n'
        _scan_line

        # Look back for HEREDOC_HEAD + TAG
        local _i=$(( _tc - 1 ))
        while (( _i >= 0 )); do
            local _t="${_tk[${_i}_type]}"
            [[ "$_t" == "OP" && "${_tk[${_i}_val]}" == $'\n' ]] && break
            if [[ "$_t" == "HEREDOC_HEAD" ]]; then
                # <<< is a herestring — no body/marker follows, skip pending
                [[ "${_tk[${_i}_val]}" == '<<<' ]] && break
                local _j=$(( _i + 1 ))
                while (( _j < _tc )); do
                    local _tj="${_tk[${_j}_type]}"
                    if [[ "$_tj" == "WORD" || "$_tj" == "STRING_SQ" || "$_tj" == "STRING_DQ" ]]; then
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

    # Post-processing: collapse consecutive newline tokens in-place
    # COMMENT tokens are preserved — callers decide whether to skip them
    local _raw_count=$_tc
    local _wi=0 _ri=0 _prev_nl=0
    for (( _ri=0; _ri<_raw_count; _ri++ )); do
        local _rtype="${_tk[${_ri}_type]}" _rval="${_tk[${_ri}_val]}"
        if [[ "$_rtype" == "OP" && "$_rval" == $'\n' ]]; then
            (( _prev_nl )) && continue
            _prev_nl=1
        else
            _prev_nl=0
        fi
        if (( _wi != _ri )); then
            _tk[${_wi}_type]="$_rtype"
            _tk[${_wi}_val]="$_rval"
        fi
        (( _wi++ ))
    done
    for (( _ri=_wi; _ri<_raw_count; _ri++ )); do
        unset "_tk[${_ri}_type]" "_tk[${_ri}_val]"
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
    local -A tokens=()
    local token_count=0

    _log_verbose "[Minifier] Tokenising input..."
    tokenise "$input" tokens token_count
    _log_verbose "[Minifier] Tokenising done (${token_count} tokens)"

    # COMMENT tokens are skipped during emit — newline collapse handled by tokenise

    # Build minified output from tokens
    local buffer=""
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

        # No semi after && or || or | (they continue the expression)
        [[ "$prev_type" == "OP" && "$prev_val" == "&&" ]] && return 0
        [[ "$prev_type" == "OP" && "$prev_val" == "||" ]] && return 0
        [[ "$prev_type" == "OP" && "$prev_val" == "|"  ]] && return 0

        return 1  # Default: add semi (including before fi/done/esac/})
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
            '}')  [[ "$prev_type" == OP && "$prev_val" == ';' ]] && return 0 ;;
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
    _log_verbose "[Minifier] Processing ${token_count} tokens..."
    while (( i < token_count )); do
        local type="${tokens[${i}_type]}"
        local val="${tokens[${i}_val]}"
        (( i++ ))

        # Skip comments — preserved in token stream for other consumers
        [[ "$type" == "COMMENT" ]] && { _log_verbose "[Minifier] Skipping COMMENT token"; continue; }

        # Handle newlines: convert to semicolons (conservative default)
        if [[ "$type" == "OP" && "$val" == $'\n' ]]; then
            # Backslash continuation — strip the \ already in buffer and join with space
            if [[ "$prev_type" == "OP" && "$prev_val" == '\' ]]; then
                buffer="${buffer%\\} "
                prev_type=""
                prev_val=""
                _update_depth "$type" "$val"
                continue
            fi

            # Preserve newline after HEREDOC_TAIL
            if [[ "$prev_type" == "HEREDOC_TAIL" ]]; then
                buffer+=$'\n'
                prev_type=""
                prev_val=""
                _update_depth "$type" "$val"
                continue
            fi

            # Skip consecutive newlines
            while (( i < token_count )); do
                local next_type="${tokens[${i}_type]}"
                local next_val="${tokens[${i}_val]}"
                [[ "$next_type" == "OP" && "$next_val" == $'\n' ]] && { (( i++ )); continue; }
                break
            done

            # Inside brackets/parens (arrays), use space instead of semicolon
            if (( ${#_paren_stack[@]} > 0 || array_depth > 0 || bracket_depth > 0 )); then
                buffer+=" "
                prev_type="OP"; prev_val=" "
            elif [[ -n "$prev_type" && "$buffer" =~ [^[:space:]]$ ]]; then
                if (( i < token_count )); then
                    local next_type="${tokens[${i}_type]}"
                    local next_val="${tokens[${i}_val]}"
                    # else\nif is genuinely nested (not elif) — keep newline so shellcheck
                    # doesn't flag SC1075 "use elif instead of else if"
                    if [[ "$prev_val" == "else" && "$next_type" == "WORD" && "$next_val" == "if" ]]; then
                        buffer+=$'\n'
                        _log_verbose "[Minifier] Preserving newline for else-if pattern"
                        prev_type="OP"; prev_val=$'\n'
                    elif ! _skip_semi "$prev_type" "$prev_val" "$next_type" "$next_val"; then
                        buffer+="; "
                        _log_verbose "[Minifier] Inserting semicolon between ${prev_type}(${prev_val}) and ${next_type}(${next_val})"
                        prev_type="OP"; prev_val=";"
                    else
                        _log_verbose "[Minifier] Skipping semicolon between ${prev_type}(${prev_val}) and ${next_type}(${next_val})"
                    fi
                fi
            fi
            _update_depth "$type" "$val"
            _log_progress "Minifying... (${#buffer} bytes)"
            continue
        fi

        # Update depth tracking before processing token
        local pre_paren_depth=${#_paren_stack[@]}
        local pre_paren_top="${_paren_stack[$((pre_paren_depth > 0 ? pre_paren_depth-1 : 0))]:-}"
        _update_depth "$type" "$val"
        local post_paren_depth=${#_paren_stack[@]}
        local post_paren_top="${_paren_stack[$((post_paren_depth > 0 ? post_paren_depth-1 : 0))]:-}"

        # Add space if needed
        if [[ -n "$prev_type" && "$buffer" =~ [^[:space:]]$ ]]; then
            if _needs_space "$prev_type" "$prev_val" "$type" "$val" "$array_depth" "$brace_expand" "$pre_paren_top" "$post_paren_top"; then
                _log_verbose "[Minifier] Adding space for ${prev_type}(${prev_val})-${type}(${val}) pattern"
                buffer+=" "
            else
                _log_verbose "[Minifier] No space for ${prev_type}(${prev_val})-${type}(${val}) pattern"
            fi
        fi

        # Append token
        buffer+="$(_token_to_string "$type" "$val")"
        _log_verbose "[Minifier] Appended ${type}(${val}), buffer now ${#buffer} bytes"

        # Track brace expansion: { directly after a value token = brace expansion, not command group.
        # WORD is included but only if it's not a statement-level keyword (those use { as cmd group).
        local _kw_pat='^(then|do|in|else|elif|done|fi|esac|if|while|until|for|case|function)$'
        if [[ "$type" == "OP" && "$val" == "{" ]]; then
            if [[ "$prev_type" =~ ^(STRING_DQ|STRING_SQ|VAR_LITERAL|PARAM_EXP|RICH_STRING)$ ]]; then
                brace_expand=1
            elif [[ "$prev_type" == WORD && ! "$prev_val" =~ $_kw_pat ]]; then
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

    # Final cleanup
    buffer="${buffer//  / }"
    buffer="${buffer//; ;/;}"
    buffer="${buffer# }"
    buffer="${buffer% }"
    buffer="${buffer%;}"

    _log_verbose "[Minifier] Done. Output: ${#buffer} bytes"

    printf '%s\n' "$buffer"
}


# ==============================================================================
# OPTIMISER
# ==============================================================================
#
# Passes (always-on unless flagged off):
#   fold-constants     — inline integer/string constants, fold arithmetic
#   dce                — eliminate dead branches and unused locals
#   positional-inline  — inline local var="$N" positional captures
#   array-inline       — inline local -a arr=("$@") array captures
#   if-collapse        — nested-then → && merge, else-if → elif
#
# Passes (opt-in):
#   framehead-specific — ::fast rewriting, ::legacy upgrade, math::bc→$(()),
#                        trivial one-liner inlining (multipass)
#   inline-functions   — nontrivial function inlining, minifier-validated
#   fold-bc            — build-time bc expression evaluation
#   dce-aggressive     — whole-script callgraph dead function pruning
#
# Annotation syntax (shellcheck-style, no colon):
#   # optimiser ignore=all
#   # optimiser ignore=inline,dce scope=function
#   # optimiser enable=fold-bc scope=block
#
# Scopes: line (default), block, function, file
# Specificity: line > block > function > file
# ==============================================================================

# ==============================================================================
# ANNOTATION PARSER
# ==============================================================================

# _opt_parse_annotations — pre-pass: collect all # optimiser annotations
# Builds two associative arrays:
#   _ann_ignore[lineno:pass] = scope
#   _ann_enable[lineno:pass] = scope
# Usage: _opt_parse_annotations "content" _ann_ignore _ann_enable
_opt_parse_annotations() {
    local content="$1"
    local -n _ann_ign="$2"
    local -n _ann_ena="$3"

    local lineno=0
    local line
    while IFS= read -r line; do
        (( lineno++ ))
        # Match: # optimiser ignore=PASSES [scope=SCOPE]
        #        # optimiser enable=PASSES [scope=SCOPE]
        if [[ "$line" =~ ^[[:space:]]*#[[:space:]]*optimiser[[:space:]]+(ignore|enable)=([a-zA-Z0-9_,-]+)([[:space:]]+scope=([a-zA-Z-]+))?[[:space:]]*$ ]]; then
            local verb="${BASH_REMATCH[1]}"
            local passes="${BASH_REMATCH[2]}"
            local scope="${BASH_REMATCH[4]:-line}"
            local pass
            IFS=',' read -ra _passes <<< "$passes"
            for pass in "${_passes[@]}"; do
                pass="${pass// /}"
                if [[ "$verb" == ignore ]]; then
                    _ann_ign["${lineno}:${pass}"]="$scope"
                else
                    _ann_ena["${lineno}:${pass}"]="$scope"
                fi
            done
        fi
    done <<< "$content"
}

# _opt_has_annotation — check if a given line/pass combo is annotated
# Checks line, then block (requires block_end), then function (requires fn_start/fn_end), then file
# Usage: _opt_has_annotation ignore|enable pass lineno [block_end] [fn_start] [fn_end] [file_start]
# Returns 0 if annotated, 1 if not
# Uses globals: _ann_ignore _ann_enable (set by _opt_parse_annotations)
_opt_has_annotation() {
    local verb="$1" pass="$2" lineno="$3"
    local block_end="${4:-0}" fn_start="${5:-0}" fn_end="${6:-0}" file_start="${7:-0}"
    local -n _ann_ref="_ann_${verb/ignore/ign}"

    local check_passes=("$pass")
    [[ "$pass" != all ]] && check_passes+=("all")

    local p scope ann_line
    for p in "${check_passes[@]}"; do
        # line scope: annotation on immediately preceding line
        ann_line=$(( lineno - 1 ))
        if [[ -n "${_ann_ref["${ann_line}:${p}"]:-}" ]]; then
            scope="${_ann_ref["${ann_line}:${p}"]}"
            [[ "$scope" == line ]] && return 0
        fi

        # block scope: annotation before block_end
        if (( block_end > 0 )); then
            for (( ann_line=lineno-1; ann_line>=lineno-10; ann_line-- )); do
                if [[ "${_ann_ref["${ann_line}:${p}"]:-}" == block ]]; then
                    (( lineno <= block_end )) && return 0
                fi
            done
        fi

        # function scope
        if (( fn_start > 0 && fn_end > 0 )); then
            for (( ann_line=fn_start; ann_line<=fn_end; ann_line++ )); do
                if [[ "${_ann_ref["${ann_line}:${p}"]:-}" == function ]]; then
                    (( lineno >= fn_start && lineno <= fn_end )) && return 0
                fi
            done
        fi

        # file scope: any annotation before this line with scope=file
        for (( ann_line=file_start; ann_line<lineno; ann_line++ )); do
            if [[ "${_ann_ref["${ann_line}:${p}"]:-}" == file ]]; then
                return 0
            fi
        done
    done
    return 1
}

# ==============================================================================
# IGNORE MAP — CLI-level per-function/line protection
# ==============================================================================

# Global ignore map: _cli_ignore[fname:pass] = 1
declare -A _cli_ignore=()

# _cli_is_ignored fname pass
# Returns 0 if ignored
_cli_is_ignored() {
    local fname="$1" pass="$2"
    [[ -n "${_cli_ignore["${fname}__${pass}"]:-}" ]] ||
    [[ -n "${_cli_ignore["${fname}__all"]:-}" ]]
}

# _cli_add_ignore fname passes_csv
_cli_add_ignore() {
    local fname="$1"
    local pass
    IFS=',' read -ra _ps <<< "$2"
    for pass in "${_ps[@]}"; do
        pass="${pass// /}"
        _cli_ignore["${fname}__${pass}"]=1
    done
}

# ==============================================================================
# CONSTANT FOLDING
# (extracted from main.sh fold_constants, adapted for optimiser pipeline)
# ==============================================================================

fold_constants() {
    local input="$1"
    local current="$input"
    local dirty=1

    while (( dirty )); do
        dirty=0
        local -a lines=()
        while IFS= read -r line; do lines+=("$line"); done <<< "$current"

        declare -A constants=()
        for line in "${lines[@]}"; do
            if [[ "$line" =~ ^[[:space:]]*(local|readonly)[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)=(-?[0-9]+)[[:space:]]*$ ]]; then
                constants["${BASH_REMATCH[2]}"]="${BASH_REMATCH[3]}"
            elif [[ "$line" =~ ^[[:space:]]*(local|readonly)[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)=\"(-?[0-9]+)\"[[:space:]]*$ ]]; then
                constants["${BASH_REMATCH[2]}"]="${BASH_REMATCH[3]}"
            fi
        done

        declare -A to_inline=()
        for const_var in "${!constants[@]}"; do
            local const_val="${constants[$const_var]}"
            local safe=true usage_count=0
            for line in "${lines[@]}"; do
                [[ "$line" =~ ^[[:space:]]*(local|readonly)[[:space:]]+${const_var}= ]] && continue
                [[ "$line" =~ ${const_var}= ]] && { safe=false; break; }
                [[ "$line" =~ \(\([[:space:]]*${const_var}(\+\+|--|+=|-=) ]] && { safe=false; break; }
                local temp="$line"
                while [[ "$temp" =~ \$${const_var}([^a-zA-Z0-9_]|$) ]] || \
                      [[ "$temp" =~ \$\{${const_var}\} ]] || \
                      [[ "$temp" =~ [^a-zA-Z0-9_]${const_var}([^a-zA-Z0-9_]|$) ]]; do
                    (( usage_count++ ))
                    temp="${temp#*${const_var}}"
                done
            done
            $safe && (( usage_count > 0 )) && to_inline["$const_var"]="$const_val"
        done

        if (( ${#to_inline[@]} > 0 )); then
            local -a new_output=()
            for line in "${lines[@]}"; do
                local skip_line=false
                for const_var in "${!to_inline[@]}"; do
                    if [[ "$line" =~ ^[[:space:]]*(local|readonly)[[:space:]]+${const_var}=[^[:space:]]*$ ]]; then
                        skip_line=true; break
                    fi
                done
                if ! $skip_line; then
                    for const_var in "${!to_inline[@]}"; do
                        local const_val="${to_inline[$const_var]}"
                        line="${line//\$\{${const_var}\}/${const_val}}"
                        line="${line//\$${const_var}/${const_val}}"
                        line=$(printf '%s' "$line" | sed "s/\([^a-zA-Z0-9_]\)${const_var}\([^a-zA-Z0-9_]\)/\1${const_val}\2/g")
                    done
                    # Fold arithmetic literals: $(( N op M ))
                    while [[ "$line" =~ \$\(\([[:space:]]*(-?[0-9]+)[[:space:]]*\+[[:space:]]*(-?[0-9]+)[[:space:]]*\)\) ]]; do
                        line="${line//\$(( ${BASH_REMATCH[1]} + ${BASH_REMATCH[2]} ))/$(( BASH_REMATCH[1] + BASH_REMATCH[2] ))}"
                    done
                    while [[ "$line" =~ \$\(\([[:space:]]*(-?[0-9]+)[[:space:]]*-[[:space:]]*(-?[0-9]+)[[:space:]]*\)\) ]]; do
                        line="${line//\$(( ${BASH_REMATCH[1]} - ${BASH_REMATCH[2]} ))/$(( BASH_REMATCH[1] - BASH_REMATCH[2] ))}"
                    done
                    while [[ "$line" =~ \$\(\([[:space:]]*(-?[0-9]+)[[:space:]]*\*[[:space:]]*(-?[0-9]+)[[:space:]]*\)\) ]]; do
                        line="${line//\$(( ${BASH_REMATCH[1]} * ${BASH_REMATCH[2]} ))/$(( BASH_REMATCH[1] * BASH_REMATCH[2] ))}"
                    done
                    while [[ "$line" =~ \$\(\([[:space:]]*(-?[0-9]+)[[:space:]]*/[[:space:]]*(-?[0-9]+)[[:space:]]*\)\) ]]; do
                        local _b="${BASH_REMATCH[2]}"
                        (( _b != 0 )) && line="${line//\$(( ${BASH_REMATCH[1]} / ${BASH_REMATCH[2]} ))/$(( BASH_REMATCH[1] / BASH_REMATCH[2] ))}"
                    done
                    # Identity folding: $(( x + 0 )) $(( x * 1 )) $(( x - 0 ))
                    line=$(printf '%s' "$line" | sed -E \
                        -e 's/\$\(\(([a-zA-Z_][a-zA-Z0-9_]*) \+ 0\)\)/$(\1)/g' \
                        -e 's/\$\(\(([a-zA-Z_][a-zA-Z0-9_]*) - 0\)\)/$(\1)/g' \
                        -e 's/\$\(\(([a-zA-Z_][a-zA-Z0-9_]*) \* 1\)\)/$(\1)/g')
                    new_output+=("$line")
                fi
            done
            local _fc_new
            _fc_new=$(printf '%s\n' "${new_output[@]}")
            [[ "$_fc_new" != "$current" ]] && dirty=1
            current="$_fc_new"
        fi
        unset constants to_inline
    done
    printf '%s' "$current"
}

# ==============================================================================
# DEAD CODE ELIMINATION
# ==============================================================================

eliminate_dead_code() {
    local input="$1"
    local -a lines=()
    while IFS= read -r line; do lines+=("$line"); done <<< "$input"

    local -a output=()
    local i=0 n=${#lines[@]}
    local skip_until_fi=false skip_else=false in_true_branch=false

    while (( i < n )); do
        local line="${lines[$i]}"

        # Dead branch: if (( 0 )); then ... fi
        if [[ "$line" =~ ^[[:space:]]*if[[:space:]]*\(\([[:space:]]*0[[:space:]]*\)\) ]]; then
            skip_until_fi=true skip_else=false
            (( i++ )); continue
        fi
        # Always-true branch: if (( 1 )); then
        if [[ "$line" =~ ^[[:space:]]*if[[:space:]]*\(\([[:space:]]*1[[:space:]]*\)\) ]]; then
            in_true_branch=true
            (( i++ )); continue
        fi
        if $skip_until_fi; then
            [[ "$line" =~ ^[[:space:]]*(else|elif) ]] && { skip_until_fi=false; skip_else=true; (( i++ )); continue; }
            [[ "$line" =~ ^[[:space:]]*fi[[:space:]]*$ ]] && { skip_until_fi=false; (( i++ )); continue; }
            (( i++ )); continue
        fi
        if $skip_else; then
            [[ "$line" =~ ^[[:space:]]*fi[[:space:]]*$ ]] && { skip_else=false; (( i++ )); continue; }
            (( i++ )); continue
        fi
        if $in_true_branch; then
            [[ "$line" =~ ^[[:space:]]*(else|elif|fi)[[:space:]]*$ ]] && { in_true_branch=false; (( i++ )); continue; }
        fi

        output+=("$line")
        (( i++ ))
    done

    # Pass 2: remove unused locals
    local -a lines2=("${output[@]}")
    local -A declared=() used=()
    for line in "${lines2[@]}"; do
        if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)([^=]|$) ]]; then
            declared["${BASH_REMATCH[1]}"]="${BASH_REMATCH[1]}"
        fi
        for var in "${!declared[@]}"; do
            [[ "$line" =~ \$${var}([^a-zA-Z0-9_]|$) ]] && used["$var"]=1
            [[ "$line" =~ \$\{${var} ]] && used["$var"]=1
        done
    done

    local -a output2=()
    for line in "${lines2[@]}"; do
        local skip=false
        for var in "${!declared[@]}"; do
            [[ -z "${used[$var]:-}" ]] || continue
            if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+${var}([^a-zA-Z0-9_=]|=|$) ]]; then
                skip=true; break
            fi
        done
        $skip || output2+=("$line")
    done

    printf '%s\n' "${output2[@]}"
}

# ==============================================================================
# IF/ELIF STRUCTURAL COLLAPSE
# ==============================================================================

# _collapse_if — two passes:
#   1. else-if → elif (outer else contains only inner if)
#   2. nested-then → && (outer then contains only inner if, inner has no else)
_collapse_if() {
    local input="$1"
    local dirty=1 current="$input"

    while (( dirty )); do
        dirty=0
        local -a lines=()
        while IFS= read -r line; do lines+=("$line"); done <<< "$current"
        local n=${#lines[@]} i
        local -a out=()

        for (( i=0; i<n; i++ )); do
            local line="${lines[$i]}"

            # --- else-if → elif ---
            # Pattern: else\n  if [[ cond ]]; then ... [else ...] fi\nfi
            if [[ "$line" =~ ^([[:space:]]*)else[[:space:]]*$ ]]; then
                local indent="${BASH_REMATCH[1]}"
                local next_i=$(( i+1 ))
                # Skip blank lines
                while (( next_i < n )) && [[ "${lines[$next_i]}" =~ ^[[:space:]]*$ ]]; do
                    (( next_i++ ))
                done
                if (( next_i < n )) && [[ "${lines[$next_i]}" =~ ^${indent}[[:space:]]+(if[[:space:]].+then)[[:space:]]*$ ]]; then
                    local inner_if="${BASH_REMATCH[1]}"
                    # Find matching fi for this inner if — track depth
                    local depth=1 scan=$(( next_i+1 ))
                    local inner_fi=-1 inner_else=-1
                    while (( scan < n && depth > 0 )); do
                        [[ "${lines[$scan]}" =~ ^[[:space:]]*(if|for|while|until|case)[[:space:]] ]] && (( depth++ ))
                        if [[ "${lines[$scan]}" =~ ^${indent}[[:space:]]+fi[[:space:]]*$ && depth -eq 1 ]]; then
                            inner_fi=$scan
                            (( depth-- ))
                        elif [[ "${lines[$scan]}" =~ ^${indent}[[:space:]]+else[[:space:]]*$ && depth -eq 1 ]]; then
                            inner_else=$scan
                        fi
                        (( scan++ ))
                    done
                    # Check nothing after inner fi before outer fi
                    local after_fi=$(( inner_fi+1 ))
                    while (( after_fi < n )) && [[ "${lines[$after_fi]}" =~ ^[[:space:]]*$ ]]; do
                        (( after_fi++ ))
                    done
                    if (( inner_fi > 0 )) && \
                       (( after_fi < n )) && \
                       [[ "${lines[$after_fi]}" =~ ^${indent}fi[[:space:]]*$ ]]; then
                        # Emit: elif <cond>; then
                        out+=("${indent}elif ${inner_if#if }")
                        for (( si=next_i+1; si<inner_fi; si++ )); do
                            if (( inner_else > 0 && si == inner_else )); then
                                out+=("${indent}else")
                            else
                                out+=("${lines[$si]}")
                            fi
                        done
                        # Emit closing fi (replaces both inner fi and outer fi)
                        out+=("${indent}fi")
                        # Skip past outer fi (after_fi); for loop will i++ to after_fi+1
                        i=$after_fi
                        dirty=1
                        continue
                    fi
                fi
            fi

            # --- nested-then → && ---
            # Pattern: if [[ cond_a ]]; then\n  if [[ cond_b ]]; then ... fi\nfi
            # Outer then must contain ONLY the inner if (no else on inner)
            if [[ "$line" =~ ^([[:space:]]*)if[[:space:]](.+)[[:space:]]*then[[:space:]]*$ ]]; then
                local indent="${BASH_REMATCH[1]}"
                local cond_a="${BASH_REMATCH[2]}"
                # Strip trailing semicolon from cond_a
                cond_a="${cond_a%%;*}"
                cond_a="${cond_a%%then}"
                cond_a="${cond_a%% }"
                local next_i=$(( i+1 ))
                while (( next_i < n )) && [[ "${lines[$next_i]}" =~ ^[[:space:]]*$ ]]; do
                    (( next_i++ ))
                done
                if (( next_i < n )) && [[ "${lines[$next_i]}" =~ ^${indent}[[:space:]]+(if[[:space:]].+then)[[:space:]]*$ ]]; then
                    local inner_cond="${BASH_REMATCH[1]}"
                    local depth=1 scan=$(( next_i+1 ))
                    local inner_fi=-1 has_else=false
                    while (( scan < n && depth > 0 )); do
                        [[ "${lines[$scan]}" =~ ^[[:space:]]*(if|for|while|until|case)[[:space:]] ]] && (( depth++ ))
                        if [[ "${lines[$scan]}" =~ ^${indent}[[:space:]]+fi[[:space:]]*$ ]] && (( depth == 1 )); then
                            inner_fi=$scan; (( depth-- ))
                        elif [[ "${lines[$scan]}" =~ ^${indent}[[:space:]]+(else|elif)[[:space:]]* ]] && (( depth == 1 )); then
                            has_else=true
                        fi
                        (( scan++ ))
                    done
                    # Check: nothing between outer if and inner if
                    # Check: nothing after inner fi before outer fi
                    local after_fi=$(( inner_fi+1 ))
                    while (( after_fi < n )) && [[ "${lines[$after_fi]}" =~ ^[[:space:]]*$ ]]; do
                        (( after_fi++ ))
                    done
                    if (( inner_fi > 0 )) && ! $has_else && \
                       (( after_fi < n )) && \
                       [[ "${lines[$after_fi]}" =~ ^${indent}fi[[:space:]]*$ ]]; then
                        # Extract inner condition
                        local cond_b="${inner_cond#if }"
                        cond_b="${cond_b%%; then}"
                        cond_b="${cond_b%% then}"
                        # Emit merged if
                        out+=("${indent}if ${cond_a} && ${cond_b}; then")
                        for (( si=next_i+1; si<inner_fi; si++ )); do
                            out+=("${lines[$si]}")
                        done
                        out+=("${indent}fi")
                        i=$after_fi
                        dirty=1
                        continue
                    fi
                fi
            fi

            out+=("$line")
        done

        current=$(printf '%s\n' "${out[@]}")
    done
    printf '%s' "$current"
}

# ==============================================================================
# POSITIONAL ARG / ARRAY INLINING
# (adapted from main.sh optimize_function_body)
# ==============================================================================

optimize_function_body() {
    local input="$1"
    local current="$input"
    local dirty=1

    while (( dirty )); do
        dirty=0
        local -a lines=()
        while IFS= read -r line; do lines+=("$line"); done <<< "$current"

        local -A candidates=() to_inline=()
        local -A array_candidates=() array_to_inline=()
        local has_shift=false has_at=false remove_shift=false

        # Check for eval — bail entire function
        for line in "${lines[@]}"; do
            [[ "$line" =~ eval[[:space:]] ]] && { printf '%s' "$current"; return; }
        done

        # Check shift + $@ coexistence
        for line in "${lines[@]}"; do
            [[ "$line" =~ ^[[:space:]]*shift([[:space:]]|;|$) ]] && has_shift=true
            [[ "$line" =~ \$@ || "$line" =~ \$\{@\} || "$line" =~ \$\{@: ]] && has_at=true
        done
        $has_shift && $has_at && remove_shift=true

        # PASS 1: collect scalar candidates
        for line in "${lines[@]}"; do
            if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)=\"(\$\{?[0-9]+[^\"]*)\"|^[[:space:]]*local[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)=(\$\{?[0-9]+[^[:space:]]*) ]]; then
                local vname="${BASH_REMATCH[1]:-${BASH_REMATCH[3]}}"
                local vval="${BASH_REMATCH[2]:-${BASH_REMATCH[4]}}"
                [[ -n "$vname" ]] && candidates["$vname"]="$vval"
            fi
        done

        # PASS 2: legality check
        for vname in "${!candidates[@]}"; do
            local vval="${candidates[$vname]}"
            local safe=true
            for line in "${lines[@]}"; do
                [[ "$line" =~ ^[[:space:]]*local[[:space:]].*${vname}= ]] && continue
                [[ "$line" =~ ${vname}= ]] && { safe=false; break; }
                [[ "$line" =~ \(\([[:space:]]*${vname}(\+\+|--|+=|-=) ]] && { safe=false; break; }
                # arithmetic usage check handled by positional inline pass
                [[ "$line" =~ local[[:space:]]+-n ]] && { safe=false; break; }
            done
            $safe && to_inline["$vname"]="$vval"
        done

        # PASS 1b: collect array candidates
        for line in "${lines[@]}"; do
            if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+-a[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)=\(\"\$@\"\) ]]; then
                array_candidates["${BASH_REMATCH[1]}"]="AT_SIGN_ARRAY"
            elif [[ "$line" =~ ^[[:space:]]*local[[:space:]]+-a[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)=\(\"\$\{([a-zA-Z_][a-zA-Z0-9_]*)\[@\]\}\"\) ]]; then
                array_candidates["${BASH_REMATCH[1]}"]="SRC_ARRAY:${BASH_REMATCH[2]}"
            fi
        done

        # PASS 2b: array legality
        for arr_var in "${!array_candidates[@]}"; do
            local safe=true usage_count=0
            for line in "${lines[@]}"; do
                [[ "$line" =~ ^[[:space:]]*local[[:space:]]+-a[[:space:]]+${arr_var}= ]] && continue
                [[ "$line" =~ ${arr_var}\[.*\]= ]] && { safe=false; break; }
                [[ "$line" =~ \$\{${arr_var}\[@\]\} ]] && (( usage_count++ ))
                [[ "$line" =~ \$\{#${arr_var}\[@\]\} ]] && (( usage_count++ ))
                [[ "$line" =~ \$\{${arr_var}\[[0-9-] ]] && (( usage_count++ ))
            done
            $safe && (( usage_count > 0 )) && array_to_inline["$arr_var"]="${array_candidates[$arr_var]}"
        done

        if (( ${#to_inline[@]} == 0 && ${#array_to_inline[@]} == 0 )); then
            break
        fi

        # PASS 3: apply
        local -a new_output=()
        for line in "${lines[@]}"; do
            local skip_line=false is_local=false
            [[ "$line" =~ ^[[:space:]]*local[[:space:]]+ ]] && is_local=true

            $remove_shift && [[ "$line" =~ ^[[:space:]]*shift([[:space:]]|;|$) ]] && { skip_line=true; }

            for arr_var in "${!array_to_inline[@]}"; do
                [[ "$line" =~ ^[[:space:]]*local[[:space:]]+-a[[:space:]]+${arr_var}= ]] && { skip_line=true; break; }
            done

            if ! $skip_line; then
                for vname in "${!to_inline[@]}"; do
                    local vval="${to_inline[$vname]}"
                    [[ "$line" =~ \'[^\']*\$${vname}[^\']*\' ]] && continue
                    line="${line//\$\{${vname}\}/${vval}}"
                    line="${line//\$${vname}/${vval}}"
                done

                if $is_local; then
                    for vname in "${!to_inline[@]}"; do
                        line=$(printf '%s' "$line" | sed -E "s/${vname}=\"[^\"]*\" *//")
                        line=$(printf '%s' "$line" | sed 's/local  */local /')
                        line=$(printf '%s' "$line" | sed 's/local ;/;/')
                    done
                    line=$(printf '%s' "$line" | sed 's/^[[:space:]]*;[[:space:]]*//')
                    [[ "$line" =~ ^[[:space:]]*local[[:space:]]*$ ]] && skip_line=true
                    [[ -z "${line// /}" ]] && skip_line=true
                fi

                for arr_var in "${!array_to_inline[@]}"; do
                    local atype="${array_to_inline[$arr_var]}"
                    local replacement
                    if [[ "$atype" == AT_SIGN_ARRAY ]]; then replacement='"$@"'
                    elif [[ "$atype" =~ ^SRC_ARRAY:(.+)$ ]]; then replacement="\"$\{${BASH_REMATCH[1]}[@]\}\""
                    else continue; fi
                    line=$(printf '%s' "$line" | sed "s/\"\\${${arr_var}\\[@\\]}\"/${replacement//\//\\/}/g")
                    line="${line//\$\{#${arr_var}\[@\]\}/\$#}"
                    while [[ "$line" =~ \$\{${arr_var}\[([0-9]+)\]\} ]]; do
                        local idx="${BASH_REMATCH[1]}"
                        line="${line//\$\{${arr_var}\[$idx\]\}/\$$(( idx+1 ))}"
                    done
                    line="${line//\$\{${arr_var}\[-1\]\}/\${!#\}}"
                done
            fi

            $skip_line || new_output+=("$line")
        done

        # Collapse consecutive blank lines
        local -a final=() prev_blank=false
        for line in "${new_output[@]}"; do
            if [[ -z "${line// /}" ]]; then
                $prev_blank || { final+=("$line"); prev_blank=true; }
            else
                final+=("$line"); prev_blank=false
            fi
        done

        local _new_current
        _new_current=$(printf '%s\n' "${final[@]}")
        [[ "$_new_current" != "$current" ]] && dirty=1
        current="$_new_current"
    done

    printf '%s' "$current"
}

# ==============================================================================
# FRAMEHEAD-SPECIFIC PASS
# ==============================================================================

# ==============================================================================
# FRAMEHEAD-SPECIFIC PASS — TABLE-DRIVEN
# ==============================================================================
#
# Each rewrite rule is a table entry:
#   _FH_*_DESC[n]   — human-readable description (used in --verbose output)
#   _FH_*_PRE[n]    — precondition function name; called as: fn content [match...]
#                     returns 0 = proceed, 1 = skip this callsite
#   _FH_*_APPLY[n]  — apply function name; called as: fn content_nameref [match...]
#                     mutates content via nameref, returns 1 if changed
#
# Adding a new rewrite = one entry per table, one precondition fn, one apply fn.
# No inline logic in the dispatcher.
# ==============================================================================

# ------------------------------------------------------------------------------
# Precondition helpers
# ------------------------------------------------------------------------------

# _fh_pre_fast_exists content fn_name
# True if fn_name::fast is defined anywhere in content
_fh_pre_fast_exists() {
    local content="$1" fn_name="$2"
    [[ "$content" =~ ${fn_name}::fast[(][)] ]]
}

# _fh_pre_no_positional_args body
# True if body contains no $1..$9 references (safe for no-arg trivial inline)
_fh_pre_no_positional_args() {
    local body="$1"
    ! [[ "$body" =~ \$[1-9] ]]
}

# _fh_pre_bc_available
# True if bc is in PATH (build-time constant folding requires it)
_fh_pre_bc_available() {
    command -v bc &>/dev/null
}

# _fh_pre_not_ignored content fn_name pass
# True if fn_name is not CLI-ignored for the given pass
_fh_pre_not_ignored() {
    local fn_name="$2" pass="$3"
    ! _cli_is_ignored "$fn_name" "$pass"
}

# _fh_pre_always — always proceed (no precondition)
_fh_pre_always() { return 0; }

# ------------------------------------------------------------------------------
# _is_trivial_function body — true if body is a single non-empty statement
# ------------------------------------------------------------------------------
_is_trivial_function() {
    local body="$1"
    local -a lines=()
    local line
    while IFS= read -r line; do
        [[ -z "${line// /}" ]] && continue
        lines+=("$line")
    done <<< "$body"
    (( ${#lines[@]} == 1 ))
}

# ------------------------------------------------------------------------------
# Apply functions — each mutates content via nameref, returns 1 if changed
# ------------------------------------------------------------------------------

# _fh_apply_legacy content_nameref
# Strips ::legacy suffix from all callsites
_fh_apply_legacy() {
    local -n _fal_c="$1"
    local new="${_fal_c//::legacy/}"
    [[ "$new" != "$_fal_c" ]] || return 0
    _fal_c="$new"
    return 1
}

# _fh_apply_fast content_nameref capture_var fn_name fn_args
# Rewrites: capture_var=$(fn_name fn_args) → fn_name::fast capture_var fn_args
_fh_apply_fast() {
    local -n _faf_c="$1"
    local capture_var="$2" fn_name="$3" fn_args="$4"
    local old_call="${capture_var}=\$(${fn_name} ${fn_args})"
    local new_call="${fn_name}::fast ${capture_var} ${fn_args}"
    local new="${_faf_c//$old_call/$new_call}"
    [[ "$new" != "$_faf_c" ]] || return 0
    _faf_c="$new"
    return 1
}

# _fh_apply_bc_fold content_nameref expr result
# Replaces $(math::bc "expr") and math::bc "expr" with pre-evaluated result
# Subshell form first so var=$(math::bc "X") -> var=result, not var=$(result)
_fh_apply_bc_fold() {
    local -n _fabc_c="$1"
    local expr="$2" result="$3"
    local new="$_fabc_c"
    # Subshell-wrapped form: $(math::bc "EXPR") -> result
    new="${new//\$\(math::bc \"${expr}\"\)/$result}"
    new="${new//\$\(math::bc \'${expr}\'\)/$result}"
    # Bare form: math::bc "EXPR" -> result
    new="${new//math::bc \"${expr}\"/$result}"
    new="${new//math::bc \'${expr}\'/$result}"
    [[ "$new" != "$_fabc_c" ]] || return 0
    _fabc_c="$new"
    return 1
}

# _fh_apply_trivial_inline content_nameref fn_name fn_body
# Inlines a no-arg trivial one-liner at all callsites, removes definition
# Only fires if the definition is actually present in content
_fh_apply_trivial_inline() {
    local -n _fati_c="$1"
    local fn_name="$2" fn_body="$3"
    local old_def="${fn_name}() { ${fn_body}; }"
    # Guard: only proceed if definition exists
    [[ "$_fati_c" == *"$old_def"* ]] || return 0
    local new="${_fati_c//$old_def/}"
    new=$(printf '%s' "$new" | \
        sed -E "s/(^|[^a-zA-Z0-9_:])${fn_name}([^a-zA-Z0-9_:(]|$)/\1${fn_body}\2/g")
    [[ "$new" != "$_fati_c" ]] || return 0
    _fati_c="$new"
    return 1
}

# ------------------------------------------------------------------------------
# Dispatcher — one pass over all rewrite categories
# Returns 1 (dirty) if any rewrite fired, 0 if clean
# ------------------------------------------------------------------------------
_framehead_pass() {
    local -n _fh_result="$1"
    local _fhp_c="$_fh_result"
    local changed=false

    # ------------------------------------------------------------------
    # RULE: ::legacy stripping
    # ------------------------------------------------------------------
    if [[ "$_fhp_c" =~ ::legacy ]]; then
        _log_verbose "[framehead] Applying rule: ::legacy strip"
        _fh_apply_legacy _fhp_c && true || changed=true
    fi

    # ------------------------------------------------------------------
    # RULE: ::fast call-site rewriting
    # Pattern: var=$(module::fn args)  ->  module::fn::fast var args
    # Precondition: fn::fast must be defined in the same file
    # ------------------------------------------------------------------
    local _fast_re="([a-zA-Z_][a-zA-Z0-9_]*)=[$][(]([a-zA-Z_][a-zA-Z0-9_:]*) ([^)]+)[)]"
    if [[ "$_fhp_c" =~ $_fast_re ]]; then
        local _fh_capture="${BASH_REMATCH[1]}"
        local _fh_fn="${BASH_REMATCH[2]}"
        local _fh_args="${BASH_REMATCH[3]}"
        if _fh_pre_fast_exists "$_fhp_c" "$_fh_fn"; then
            _log_verbose "[framehead] Applying rule: ::fast rewrite for ${_fh_fn}"
            _fh_apply_fast _fhp_c "$_fh_capture" "$_fh_fn" "$_fh_args" && true || changed=true
        else
            _log_verbose "[framehead] Skipping ::fast rewrite for ${_fh_fn} -- ::fast not defined in file"
        fi
    fi

    # ------------------------------------------------------------------
    # RULE: math::bc constant folding (build-time, via bc)
    # Pattern: math::bc "EXPR" with no variable references
    # Precondition: bc in PATH; expression fully static (no $ refs)
    # Result: bc-evaluated literal (float-safe, no runtime cost)
    # ------------------------------------------------------------------
    local _bc_re _bc_re_sq _bc_matched=false _bc_expr=""
    _bc_re='math::bc[[:space:]]+"([^"$\]+)"'
    _bc_re_sq="math::bc[[:space:]]+'([^'$]+)'"
    if [[ "$_fhp_c" =~ $_bc_re ]]; then
        _bc_matched=true; _bc_expr="${BASH_REMATCH[1]}"
    elif [[ "$_fhp_c" =~ $_bc_re_sq ]]; then
        _bc_matched=true; _bc_expr="${BASH_REMATCH[1]}"
    fi
    if $_bc_matched; then
        if _fh_pre_bc_available; then
            local _bc_result
            _bc_result=$(printf '%s\n' "scale=10; ${_bc_expr}" | bc -l 2>/dev/null)
            if [[ -n "$_bc_result" ]]; then
                _bc_result=$(printf '%s' "$_bc_result" | \
                    sed 's/\.\([0-9]*[1-9]\)0*$/.\1/' | sed 's/\.0*$//')
                _log_verbose "[framehead] Folding math::bc \"${_bc_expr}\" -> ${_bc_result}"
                _fh_apply_bc_fold _fhp_c "$_bc_expr" "$_bc_result" && true || changed=true
            fi
        else
            _log_verbose "[framehead] Skipping math::bc fold -- bc not in PATH"
        fi
    fi

    # ------------------------------------------------------------------
    # RULE: trivial no-arg one-liner inlining
    # Pattern: fn() { single_statement; } with no $1..$9 refs
    # Positional-arg bodies deferred to --inline-functions
    # ------------------------------------------------------------------
    local _tl_re='([a-zA-Z_][a-zA-Z0-9_:]*)[(][)][[:space:]]*[{][[:space:]]*([^{}]+)[[:space:]]*[}]'
    if [[ "$_fhp_c" =~ $_tl_re ]]; then
        local _tl_fn="${BASH_REMATCH[1]}"
        local _tl_body="${BASH_REMATCH[2]}"
        _tl_body="${_tl_body%% }"
        _tl_body="${_tl_body## }"
        _tl_body="${_tl_body%;}"
        _tl_body="${_tl_body%% }"
        _tl_body="${_tl_body## }"
        if _is_trivial_function "$_tl_body" && \
           _fh_pre_no_positional_args "$_tl_body" && \
           _fh_pre_not_ignored "" "$_tl_fn" inline; then
            _log_verbose "[framehead] Trivial inline: ${_tl_fn}() { ${_tl_body} }"
            _fh_apply_trivial_inline _fhp_c "$_tl_fn" "$_tl_body" && true || changed=true
        fi
    fi

    _fh_result="$_fhp_c"
    $changed && return 1 || return 0
}

# framehead_specific — multipass framehead rewrite loop
# Max 20 iterations as safety valve against pathological inputs
framehead_specific() {
    local content="$1"
    local dirty=true iters=0
    while $dirty && (( iters < 20 )); do
        dirty=false
        (( iters++ ))
        _framehead_pass content || dirty=true
    done
    (( iters >= 20 )) &&         _log_verbose "[framehead] Warning: hit iteration limit (possible cycle in rewrites)"
    printf '%s' "$content"
}

# ==============================================================================
# FOLD-BC PASS (build-time bc evaluation, dep-gated)
# ==============================================================================

fold_bc() {
    local content="$1"
    if ! command -v bc &>/dev/null; then
        echo "optimize.sh: --fold-bc requires bc (not found in PATH)" >&2
        printf '%s' "$content"
        return 1
    fi
    # Find math::bc "expression" calls — evaluate at build time
    # Only when expression contains no variable references
    while [[ "$content" =~ math::bc[[:space:]]+\"([^\"$\\]+)\" ]]; do
        local expr="${BASH_REMATCH[1]}"
        local result
        result=$(echo "scale=10; ${expr}" | bc -l 2>/dev/null) || break
        # Strip trailing zeros for clean output
        result=$(printf '%s' "$result" | sed 's/\.0*$//' | sed 's/\(\.[0-9]*[1-9]\)0*/\1/')
        content="${content//math::bc \"${expr}\"/${result}}"
    done
    printf '%s' "$content"
}

# ==============================================================================
# DCE-AGGRESSIVE (callgraph traversal)
# ==============================================================================

dce_aggressive() {
    local content="$1"
    local -n _roots="$2"  # array of entry point function names to keep

    # Build function list: name → body
    local -A fn_bodies=()
    local -a fn_order=()
    local fn_name fn_body
    local in_fn=false depth=0 body_acc=""

    local -a lines=()
    while IFS= read -r line; do lines+=("$line"); done <<< "$content"
    local i n=${#lines[@]}

    for (( i=0; i<n; i++ )); do
        local line="${lines[$i]}"
        if ! $in_fn && [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_:]*)(\(\))[[:space:]]*\{ ]]; then
            fn_name="${BASH_REMATCH[1]}"
            in_fn=true depth=1 body_acc="$line"$'\n'
            continue
        fi
        if $in_fn; then
            body_acc+="$line"$'\n'
            [[ "$line" =~ \{ ]] && (( depth++ ))
            [[ "$line" =~ \} ]] && (( depth-- ))
            if (( depth == 0 )); then
                fn_bodies["$fn_name"]="$body_acc"
                fn_order+=("$fn_name")
                in_fn=false body_acc=""
            fi
        fi
    done

    # BFS from roots
    local -A reachable=()
    local -a queue=("${_roots[@]}")
    for r in "${_roots[@]}"; do reachable["$r"]=1; done

    while (( ${#queue[@]} > 0 )); do
        local cur="${queue[0]}"
        queue=("${queue[@]:1}")
        local body="${fn_bodies[$cur]:-}"
        [[ -z "$body" ]] && continue
        for fn in "${fn_order[@]}"; do
            [[ -n "${reachable[$fn]:-}" ]] && continue
            local _fn_pat=" ${fn}[ (;]|\t${fn}[ (;]|^${fn}[ (;]"
            if printf '%s' "$body" | grep -qE "$_fn_pat" 2>/dev/null; then
                reachable["$fn"]=1
                queue+=("$fn")
            fi
        done
    done

    # Rebuild content: keep functions in reachable set, keep global scope
    local output="" in_fn=false depth=0 cur_fn=""
    for (( i=0; i<n; i++ )); do
        local line="${lines[$i]}"
        if ! $in_fn && [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_:]*)(\(\))[[:space:]]*\{ ]]; then
            cur_fn="${BASH_REMATCH[1]}"
            in_fn=true depth=1
            if [[ -n "${reachable[$cur_fn]:-}" ]]; then
                output+="$line"$'\n'
            fi
            continue
        fi
        if $in_fn; then
            [[ "$line" =~ \{ ]] && (( depth++ ))
            [[ "$line" =~ \} ]] && (( depth-- ))
            if [[ -n "${reachable[$cur_fn]:-}" ]]; then
                output+="$line"$'\n'
            fi
            if (( depth == 0 )); then
                in_fn=false cur_fn=""
            fi
            continue
        fi
        output+="$line"$'\n'
    done

    printf '%s' "$output"
}

# ==============================================================================
# SOURCE INLINE PASS
# ==============================================================================
#
# Resolves source/. calls with static paths, inlines file content wrapped in
# boundary markers, then runs a recursive optimiser pass on each inlined block
# with --dce-aggressive forced on (stricter: dead if not referenced outside
# the boundary).
#
# Bails per-callsite (leaves source call intact) if:
#   - Path is dynamic ($var, $(cmd), ${arr[i]})
#   - Process substitution (source <(cmd))
#   - Path not resolvable at build time
#   - Depth limit reached (5 levels)
#
# Boundary markers (stripped after outer DCE):
#   # @source-begin: path/to/file.sh
#   # @source-end: path/to/file.sh
# ==============================================================================

_SOURCE_INLINE_DEPTH_LIMIT=5

# _source_inline_block — DCE within a @source-begin/@source-end boundary
# Removes functions defined in the block that are never referenced outside it
_source_inline_dce() {
    local content="$1"

    # Extract boundary blocks and outer content
    local -a lines=()
    while IFS= read -r line; do lines+=("$line"); done <<< "$content"
    local n=${#lines[@]} i

    # Find all boundary regions
    local -A boundary_start=() boundary_end=() boundary_file=()
    local block_id=0
    for (( i=0; i<n; i++ )); do
        if [[ "${lines[$i]}" =~ ^#[[:space:]]*@source-begin:[[:space:]]*(.+)$ ]]; then
            boundary_start[$block_id]=$i
            boundary_file[$block_id]="${BASH_REMATCH[1]}"
        elif [[ "${lines[$i]}" =~ ^#[[:space:]]*@source-end:[[:space:]]*(.+)$ ]]; then
            boundary_end[$block_id]=$i
            (( block_id++ ))
        fi
    done

    local total_blocks=$block_id
    (( total_blocks == 0 )) && { printf '%s' "$content"; return; }

    # Build outer content for usage scanning
    # Includes everything outside boundaries PLUS non-definition lines inside boundaries
    # (calls inside sourced files count as usage — we only prune truly unreferenced defs)
    local outer_content=""
    for (( i=0; i<n; i++ )); do
        local in_boundary=false cur_bnd=-1
        for (( b=0; b<total_blocks; b++ )); do
            if (( i > boundary_start[$b] && i < boundary_end[$b] )); then
                in_boundary=true; cur_bnd=$b; break
            fi
        done
        if $in_boundary; then
            # Include non-definition lines from inside boundaries (calls, assignments etc)
            local _bl="${lines[$i]}"
            [[ "$_bl" =~ ^[a-zA-Z_][a-zA-Z0-9_:]*[(][)][[:space:]]*[{] ]] ||                 outer_content+="${_bl}"$'\n'
        else
            outer_content+="${lines[$i]}"$'\n'
        fi
    done

    # For each boundary block: prune functions not referenced in outer content
    local -a output_lines=()
    for (( i=0; i<n; i++ )); do
        local line="${lines[$i]}"

        # Determine which block this line is in (if any)
        local cur_block=-1
        for (( b=0; b<total_blocks; b++ )); do
            if (( i > boundary_start[$b] && i < boundary_end[$b] )); then
                cur_block=$b; break
            fi
        done

        if (( cur_block >= 0 )); then
            # Inside boundary — check if this is a function definition
            if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_:]*)[(][)][[:space:]]*[{] ]]; then
                local fn_name="${BASH_REMATCH[1]}"
                # Check if fn_name appears in outer content
                if ! grep -qE "(^|[^a-zA-Z0-9_:])${fn_name}([^a-zA-Z0-9_:(]|$)" <<< "$outer_content" 2>/dev/null; then
                    # Dead — skip until matching closing }
                    local skip_depth=1 skip_i=$(( i+1 ))
                    while (( skip_i < n && skip_depth > 0 )); do
                        [[ "${lines[$skip_i]}" =~ [{] ]] && (( skip_depth++ ))
                        [[ "${lines[$skip_i]}" =~ [}] ]] && (( skip_depth-- ))
                        (( skip_i++ ))
                    done
                    _log_verbose "[source-inline] Pruned dead function '${fn_name}' from boundary '${boundary_file[$cur_block]}'"
                    i=$(( skip_i - 1 ))
                    continue
                fi
            fi
        fi
        output_lines+=("$line")
    done

    printf '%s\n' "${output_lines[@]}"
}

# _source_inline_file — inline a single source file into content
# Usage: _source_inline_file "content" "source_path" depth opts_serial src_dir [seen_serial] [seen_nameref]
_source_inline_file() {
    local content="$1"
    local src_path="$2"
    local depth="$3"
    local opts_serial="$4"
    local src_dir="${5:-$(pwd)}"
    local seen_serial="${6:-}"
    local seen_nameref="${7:-}"
    # Deserialise opts
    local -A _si_opts=()
    local _kv
    for _kv in $opts_serial; do
        local _k="${_kv%%=*}" _v="${_kv#*=}"
        _si_opts["$_k"]="$_v"
    done
    # Deserialise seen set
    local -A _si_seen=()
    local _sp
    for _sp in $seen_serial; do _si_seen["$_sp"]=1; done

    # Resolve path relative to the script being processed
    local resolved_path
    if [[ "$src_path" == /* ]]; then
        resolved_path="$src_path"
    else
        resolved_path="${src_dir}/${src_path}"
    fi

    if [[ ! -f "$resolved_path" ]]; then
        echo "optimize.sh: warning: source-inline: cannot resolve '${src_path}' — leaving intact" >&2
        printf '%s' "$content"
        return
    fi

    # Duplicate check — already inlined this path
    if [[ -n "${_si_seen[$resolved_path]+x}" ]]; then
        _log_verbose "[source-inline] Skipping already-inlined: ${resolved_path}"
        # Strip the source call from content (it was handled earlier)
        local -a _dedup_in=() _dedup_out=()
        while IFS= read -r _dl; do _dedup_in+=("$_dl"); done <<< "$content"
        for _dl in "${_dedup_in[@]}"; do
            if [[ "$_dl" =~ ^[[:space:]]*(source|\.)[[:space:]]+ ]]; then
                local _da="${_dl#*source }"
                [[ "$_dl" =~ ^[[:space:]]*\.[[:space:]] ]] && _da="${_dl#*. }"
                _da="${_da%% *}"; _da="${_da//[\"\']}"
                [[ "$_da" == "$src_path" ]] && continue
            fi
            _dedup_out+=("$_dl")
        done
        printf '%s
' "${_dedup_out[@]}"
        return
    fi
    # Mark as seen — update caller's seen set via nameref if provided
    _si_seen["$resolved_path"]=1
    if [[ -n "$seen_nameref" ]]; then
        local -n _si_seen_ref="$seen_nameref"
        _si_seen_ref["$resolved_path"]=1
    fi

    local file_content
    file_content=$(cat "$resolved_path")

    # Recursively inline sources within this file first (depth+1)
    local inlined_content
    # Serialise opts and seen for recursive call
    local _opts_serial=""
    for _k in "${!_si_opts[@]}"; do _opts_serial+="${_k}=${_si_opts[$_k]} "; done
    local _seen_out=""
    for _sp in "${!_si_seen[@]}"; do _seen_out+="${_sp} "; done
    inlined_content=$(source_inline "$file_content" $(( depth + 1 )) "$_opts_serial" "$resolved_path" "$_seen_out")

    # Run optimiser on inlined block with inherited opts
    # DCE is disabled — boundary DCE handles dead code after full merge
    local -A block_opts=()
    for _k in "${!_si_opts[@]}"; do block_opts[$_k]="${_si_opts[$_k]}"; done
    block_opts[dce]=0
    block_opts[dce_aggressive]=0
    block_opts[source_inline]=0   # don't recurse again here, already handled
    local optimised_block
    optimised_block=$(optimize "$inlined_content" block_opts "$resolved_path")

    # Wrap in boundary markers
    local boundary_content
    boundary_content="# @source-begin: ${resolved_path}"$'\n'
    boundary_content+="$optimised_block"$'\n'
    boundary_content+="# @source-end: ${resolved_path}"

    # Replace the source callsite in content — line-by-line to avoid sed multiline issues
    local -a in_lines=() out_lines=()
    while IFS= read -r l; do in_lines+=("$l"); done <<< "$content"
    local replaced=false
    for l in "${in_lines[@]}"; do
        if ! $replaced && [[ "$l" =~ ^([[:space:]]*)(source|\.)[[:space:]]+ ]]; then
            local _after="${l#*source }"
            [[ "$l" =~ ^[[:space:]]*\.[[:space:]] ]] && _after="${l#*. }"
            _after="${_after%% *}"
            _after="${_after//\"/}"
            _after="${_after//\'/}"
            if [[ "$_after" == "$src_path" ]]; then
                # Replace this line with boundary content
                while IFS= read -r bl; do out_lines+=("$bl"); done <<< "$boundary_content"
                replaced=true
                continue
            fi
        fi
        out_lines+=("$l")
    done
    printf '%s\n' "${out_lines[@]}"
}

# source_inline — main entry point for source inlining pass
# Usage: source_inline "content" depth opts_serial_or_nameref [script_path] [seen_serial]
# opts: nameref name (from optimize()) or serialised "k=v ..." (recursive)
# seen_serial: space-separated list of already-inlined absolute paths
source_inline() {
    local content="$1"
    local depth="${2:-1}"
    local _sil_arg="$3"
    local script_path="${4:-}"
    local _seen_serial="${5:-}"
    local -A _sil_opts=()
    # Detect if arg is a nameref name or serialised string
    if [[ "$_sil_arg" =~ [[:space:]]|= ]]; then
        # Serialised string
        local _kv
        for _kv in $_sil_arg; do
            local _k="${_kv%%=*}" _v="${_kv#*=}"
            _sil_opts["$_k"]="$_v"
        done
    else
        # Nameref name — copy into local assoc
        local -n _sil_ref="$_sil_arg"
        for _k in "${!_sil_ref[@]}"; do _sil_opts[$_k]="${_sil_ref[$_k]}"; done
    fi
    # Build seen-paths set from serialised string
    local -A _sil_seen=()
    local _sp
    for _sp in $_seen_serial; do _sil_seen["$_sp"]=1; done
    local script_dir
    script_dir=$(dirname "${script_path:-$(pwd)/dummy}")

    if (( depth > _SOURCE_INLINE_DEPTH_LIMIT )); then
        echo "optimize.sh: warning: source-inline depth limit (${_SOURCE_INLINE_DEPTH_LIMIT}) reached -- skipping remaining inlines" >&2
        printf '%s' "$content"
        return
    fi

    local -a lines=()
    while IFS= read -r line; do lines+=("$line"); done <<< "$content"
    local n=${#lines[@]} i
    local result="$content"

    for (( i=0; i<n; i++ )); do
        local line="${lines[$i]}"

        # Match source or . followed by a path
        # Bail patterns: dynamic ($var, $(cmd), ${...}, <(...))
        if [[ "$line" =~ ^[[:space:]]*(source|\.)[[:space:]]+ ]]; then
            local after="${line#*source }"
            [[ "$line" =~ ^[[:space:]]*\.[[:space:]] ]] && after="${line#*. }"
            after="${after%% *}"  # first arg only
            after="${after//\"/}"
            after="${after//\'/}"

            # Bail checks
            if [[ "$after" =~ ^\$ ]] || \
               [[ "$after" =~ \$[\({] ]] || \
               [[ "$after" =~ ^\<\( ]]; then
                _log_verbose "[source-inline] Skipping dynamic source: ${line}"
                continue
            fi

            _log_verbose "[source-inline] Inlining: ${after} (depth ${depth})"
            local _serial=""
            for _k in "${!_sil_opts[@]}"; do _serial+="${_k}=${_sil_opts[$_k]} "; done
            local _seen_out=""
            for _sp in "${!_sil_seen[@]}"; do _seen_out+="${_sp} "; done
            result=$(_source_inline_file "$result" "$after" "$depth" "$_serial" "$script_dir" "$_seen_out")

            # Re-read lines from updated result for subsequent iterations
            lines=()
            while IFS= read -r l; do lines+=("$l"); done <<< "$result"
            n=${#lines[@]}

            # Update seen set from @source-begin markers now present in result
            # (subshell means we cannot get seen updates back directly)
            local _l
            for _l in "${lines[@]}"; do
                if [[ "$_l" =~ ^#[[:space:]]*@source-begin:[[:space:]]*(.+)$ ]]; then
                    _sil_seen["${BASH_REMATCH[1]}"]=1
                fi
            done
        fi
    done

    printf '%s' "$result"
}

# _strip_source_boundaries — remove boundary markers from final output
_strip_source_boundaries() {
    local content="$1"
    printf '%s' "$content" | grep -v '^[[:space:]]*# @source-begin:' | grep -v '^[[:space:]]*# @source-end:'
}

# ==============================================================================
# MAIN OPTIMISER ENTRY POINT
# ==============================================================================

# optimize "content" opts_nameref [script_path]
# opts_nameref: associative array with keys matching flag names
optimize() {
    local src="$1"
    local -n _opts="$2"
    local _opt_script_path="${3:-}"

    local do_source_inline="${_opts[source_inline]:-0}"
    local do_framehead="${_opts[framehead_specific]:-0}"
    local do_inline_fn="${_opts[inline_functions]:-0}"
    local do_fold_bc="${_opts[fold_bc]:-0}"
    local do_dce="${_opts[dce]:-1}"
    local do_fold_const="${_opts[fold_constants]:-1}"
    local do_pos_inline="${_opts[positional_inline]:-1}"
    local do_arr_inline="${_opts[array_inline]:-1}"
    local do_if_collapse="${_opts[if_collapse]:-1}"
    local do_dce_agg="${_opts[dce_aggressive]:-0}"
    local -a dce_roots=()
    [[ -n "${_opts[dce_roots]:-}" ]] && IFS=',' read -ra dce_roots <<< "${_opts[dce_roots]}"
    local ignore_annotations="${_opts[ignore_annotations]:-0}"

    # Pre-pass: collect annotations
    local -A _ann_ignore=() _ann_enable=()
    if (( !ignore_annotations )); then
        _opt_parse_annotations "$src" _ann_ignore _ann_enable
    fi

    local current="$src"
    local global_dirty=true

    _log_verbose "[Optimiser] Starting optimisation pipeline..."

    # 0. Source inlining — runs once before the main loop
    if (( do_source_inline )); then
        _log_verbose "[Optimiser] Pass: source-inline"
        current=$(source_inline "$current" 1 _opts "$_opt_script_path")  # _opts is nameref name, detected inside
        # Boundary DCE — prune functions in inlined blocks not used outside them
        (( do_dce )) && current=$(_source_inline_dce "$current")
        # Strip boundary markers after boundary DCE is done
        current=$(_strip_source_boundaries "$current")
    fi

    while $global_dirty; do
        global_dirty=false
        local prev="$current"

        # 1. Framehead-specific (multipass internally)
        if (( do_framehead )); then
            _log_verbose "[Optimiser] Pass: framehead-specific"
            current=$(framehead_specific "$current")
        fi

        # 2. Per-function passes: positional inline, array inline, fold constants, DCE, if-collapse
        # Split into function bodies, apply passes, reassemble
        local -a lines=()
        while IFS= read -r line; do lines+=("$line"); done <<< "$current"
        local n=${#lines[@]} i
        local output="" in_fn=false depth=0 fn_body_acc="" fn_header="" cur_fn=""

        for (( i=0; i<n; i++ )); do
            local line="${lines[$i]}"
            if ! $in_fn && [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_:]*)[(][)][[:space:]]*[{] ]]; then
                cur_fn="${BASH_REMATCH[1]}"
                # One-liner: { ... } on same line — emit as-is, no body passes needed
                if [[ "$line" =~ [}][[:space:]]*$ ]]; then
                    output+="$line"$'\n'
                    continue
                fi
                in_fn=true depth=1 fn_body_acc="" fn_header="$line"
                continue
            fi
            if $in_fn; then
                [[ "$line" =~ [^#]*[{] ]] && (( depth++ ))
                [[ "$line" =~ [}] ]] && (( depth-- ))
                if (( depth == 0 )); then
                    # closing } — apply passes to accumulated body
                    local fn_body="$fn_body_acc"
                    _cli_is_ignored "$cur_fn" all || {
                        (( do_pos_inline )) && ! _cli_is_ignored "$cur_fn" positional_inline &&                             fn_body=$(optimize_function_body "$fn_body")
                        (( do_fold_const )) && ! _cli_is_ignored "$cur_fn" fold_constants &&                             fn_body=$(fold_constants "$fn_body")
                        (( do_dce )) && ! _cli_is_ignored "$cur_fn" dce &&                             fn_body=$(eliminate_dead_code "$fn_body")
                        (( do_if_collapse )) && ! _cli_is_ignored "$cur_fn" if_collapse &&                             fn_body=$(_collapse_if "$fn_body")
                    }
                    # Ensure body ends with newline before closing brace
                    [[ "${fn_body: -1}" != $'\n' ]] && fn_body+=$'\n'
                    output+="${fn_header}"$'\n'"${fn_body}""${line}"$'\n'
                    in_fn=false cur_fn=""
                else
                    fn_body_acc+="$line"$'\n'
                fi
                continue
            fi
            # Global scope
            output+="$line"$'\n'
        done
        current="$output"

        # 3. fold-bc
        if (( do_fold_bc )); then
            _log_verbose "[Optimiser] Pass: fold-bc"
            current=$(fold_bc "$current")
        fi

        # 4. dce-aggressive (run once, not in dirty loop)
        if (( do_dce_agg && ${#dce_roots[@]} > 0 )); then
            _log_verbose "[Optimiser] Pass: dce-aggressive (roots: ${dce_roots[*]})"
            current=$(dce_aggressive "$current" dce_roots)
            do_dce_agg=0  # only once per pipeline run
        fi

        # Strip trailing newline before comparing to avoid perpetual dirty
        local _cur_trimmed="${current%$'\n'}"
        local _prev_trimmed="${prev%$'\n'}"
        [[ "$_cur_trimmed" != "$_prev_trimmed" ]] && global_dirty=true
        current="$_cur_trimmed"
    done

    _log_verbose "[Optimiser] Done. Output: ${#current} bytes"
    printf '%s\n' "$current"
}

# ==============================================================================
# CLI
# ==============================================================================

_optimize_cli() {
    local input_file="" output_file="" check=0
    local -A opts=(
        [fold_constants]=1 [dce]=1 [positional_inline]=1
        [array_inline]=1 [if_collapse]=1
        [framehead_specific]=0 [inline_functions]=0
        [fold_bc]=0 [dce_aggressive]=0
        [source_inline]=0
        [ignore_annotations]=0 [dce_roots]=""
    )
    local -a ignore_args=()

    while (( $# )); do
        case "$1" in
            --no-all)
                printf '%s\n' "optimize.sh: --no-all arg? Why are you even executing it in the first place :|" >&2
                return 1 ;;
            --all)
                opts[framehead_specific]=1
                opts[inline_functions]=1
                opts[fold_bc]=1
                opts[dce_aggressive]=1
                opts[source_inline]=1 ;;
            --source-inline)     opts[source_inline]=1 ;;
            --check)             check=1 ;;
            --verbose)           [[ -z "$_minify_log_mode" ]] && _minify_log_mode=verbose ;;
            --quiet)             [[ -z "$_minify_log_mode" ]] && _minify_log_mode=quiet ;;
            --ignore-annotates)  opts[ignore_annotations]=1 ;;
            # Always-on toggles
            --no-fold-constants) opts[fold_constants]=0 ;;
            --fold-constants)    opts[fold_constants]=1 ;;
            --no-dce)            opts[dce]=0 ;;
            --dce)               opts[dce]=1 ;;
            --no-positional-inline) opts[positional_inline]=0 ;;
            --positional-inline) opts[positional_inline]=1 ;;
            --no-array-inline)   opts[array_inline]=0 ;;
            --array-inline)      opts[array_inline]=1 ;;
            --no-if-collapse)    opts[if_collapse]=0 ;;
            --if-collapse)       opts[if_collapse]=1 ;;
            # Opt-in passes
            --framehead-specific) opts[framehead_specific]=1 ;;
            --inline-functions)  opts[inline_functions]=1 ;;
            --fold-bc)           opts[fold_bc]=1 ;;
            --dce-aggressive)    opts[dce_aggressive]=1 ;;
            --ignore=*)
                local _fn="${1#--ignore=}"
                IFS=',' read -ra _fns <<< "$_fn"
                for f in "${_fns[@]}"; do _cli_add_ignore "$f" all; done ;;
            --ignore-all=*)
                local _fn="${1#--ignore-all=}"
                IFS=',' read -ra _fns <<< "$_fn"
                for f in "${_fns[@]}"; do _cli_add_ignore "$f" all; done ;;
            --ignore-dce=*)
                local _fn="${1#--ignore-dce=}"
                IFS=',' read -ra _fns <<< "$_fn"
                for f in "${_fns[@]}"; do _cli_add_ignore "$f" dce; done ;;
            --ignore-dce-aggressive=*)
                local _fn="${1#--ignore-dce-aggressive=}"
                IFS=',' read -ra _fns <<< "$_fn"
                for f in "${_fns[@]}"; do _cli_add_ignore "$f" dce_aggressive; done ;;
            --ignore-inline=*)
                local _fn="${1#--ignore-inline=}"
                IFS=',' read -ra _fns <<< "$_fn"
                for f in "${_fns[@]}"; do _cli_add_ignore "$f" inline; done ;;
            --ignore-framehead=*)
                local _fn="${1#--ignore-framehead=}"
                IFS=',' read -ra _fns <<< "$_fn"
                for f in "${_fns[@]}"; do _cli_add_ignore "$f" framehead; done ;;
            --ignore-source-inline=*)
                local _fn="${1#--ignore-source-inline=}"
                IFS=',' read -ra _fns <<< "$_fn"
                for f in "${_fns[@]}"; do _cli_add_ignore "$f" source_inline; done ;;
            --ignore-fold-bc=*)
                local _fn="${1#--ignore-fold-bc=}"
                IFS=',' read -ra _fns <<< "$_fn"
                for f in "${_fns[@]}"; do _cli_add_ignore "$f" fold_bc; done ;;
            --entry=*|--ignore-dce-aggressive-entry=*)
                # --entry= is only valid with --dce-aggressive, warn otherwise
                local _entry="${1#*=}"
                IFS=',' read -ra _roots <<< "$_entry"
                local _r; for _r in "${_roots[@]}"; do
                    opts[dce_roots]+="${opts[dce_roots]:+,}${_r}"
                done ;;
            --)  shift; break ;;
            -)
                if [[ -z "$input_file" ]]; then input_file="-"
                elif [[ -z "$output_file" ]]; then output_file="-"
                else echo "optimize.sh: unexpected argument: $1" >&2; return 1; fi ;;
            -*)  echo "optimize.sh: unknown option: $1" >&2; return 1 ;;
            *)
                if [[ -z "$input_file" ]]; then input_file="$1"
                elif [[ -z "$output_file" ]]; then output_file="$1"
                else echo "optimize.sh: unexpected argument: $1" >&2; return 1; fi ;;
        esac
        shift
    done

    # Validate dce-aggressive needs roots
    if (( opts[dce_aggressive] && ${#opts[dce_roots]} == 0 )); then
        echo "optimize.sh: --dce-aggressive requires --entry=fname" >&2
        return 1
    fi

    # Warn if --entry without --dce-aggressive
    if (( !opts[dce_aggressive] && ${#opts[dce_roots]} > 0 )); then
        echo "optimize.sh: warning: --entry= has no effect without --dce-aggressive" >&2
    fi

    if [[ -z "$input_file" ]]; then
        cat >&2 << 'USAGE'
Usage: optimize.sh [options] input.sh [output.sh]
       optimize.sh [options] -

Always-on passes (use --no-X to disable):
  --[no-]fold-constants     constant inlining and arithmetic folding (default: on)
  --[no-]dce                dead code elimination (default: on)
  --[no-]positional-inline  positional arg capture inlining (default: on)
  --[no-]array-inline       array capture inlining (default: on)
  --[no-]if-collapse        nested-if/else-if structural collapse (default: on)

Opt-in passes:
  --framehead-specific      ::fast rewriting, ::legacy upgrade, trivial inlining
  --inline-functions        nontrivial function inlining (minifier-validated)
  --fold-bc                 build-time bc expression evaluation (requires bc)
  --dce-aggressive          whole-script callgraph dead function pruning
  --source-inline           inline source/. calls (static paths only), with
                            boundary-scoped aggressive DCE on inlined content
  --all                     enable all opt-in passes

  --entry=fname[,fname]     root functions for --dce-aggressive (required with it)

Per-symbol ignore (comma-separated or repeated):
  --ignore=fname            skip all passes for fname
  --ignore-all=fname        same as --ignore
  --ignore-dce=fname
  --ignore-dce-aggressive=fname
  --ignore-inline=fname
  --ignore-framehead=fname
  --ignore-fold-bc=fname

Annotation (shellcheck-style, in source):
  # optimiser ignore=all
  # optimiser ignore=inline,dce scope=function
  # optimiser enable=fold-bc scope=block

  --ignore-annotates        ignore all # optimiser annotations

General:
  --check                   validate output syntax only, do not write
  --verbose                 log every pass decision to stderr
  --quiet                   suppress all progress output
USAGE
        return 1
    fi

    # Read input
    local content
    if [[ "$input_file" == "-" ]]; then
        content=$(cat)
    else
        [[ ! -f "$input_file" ]] && { echo "optimize.sh: file not found: $input_file" >&2; return 1; }
        content=$(cat "$input_file")
    fi

    local input_bytes=${#content}
    local label="$input_file" target="${output_file:-stdout}"

    _log_progress "Optimising ${label} -> ${target}... (${input_bytes} bytes)"

    local optimised
    optimised=$(optimize "$content" opts "$input_file")
    _log_progress_nl

    # Syntax check
    if ! bash -n <<< "$optimised" 2>/dev/null; then
        echo "optimize.sh: output failed syntax check" >&2
        bash -n <<< "$optimised" 2>&1 | head -5 >&2
        if [[ -n "$output_file" && "$output_file" != "-" ]]; then
            printf '%s\n' "$optimised" > "${output_file}.broken"
            echo "optimize.sh: broken output written to ${output_file}.broken" >&2
        fi
        return 1
    fi

    local output_bytes=${#optimised}
    local reduction=$(( (input_bytes - output_bytes) * 100 / (input_bytes > 0 ? input_bytes : 1) ))

    (( check )) && { echo "optimize.sh: syntax OK (${output_bytes} bytes, ${reduction}% reduction)" >&2; return 0; }

    if [[ -z "$output_file" || "$output_file" == "-" ]]; then
        printf '%s\n' "$optimised"
    else
        printf '%s\n' "$optimised" > "$output_file"
        chmod +x "$output_file"
        [[ "$_minify_log_mode" != quiet ]] && \
            echo "Optimised ${input_file} -> ${output_file} (${input_bytes} -> ${output_bytes} bytes, ${reduction}%)" >&2
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _optimize_cli "$@"
fi
