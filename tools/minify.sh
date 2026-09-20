#!/usr/bin/env bash
# minify.sh — standalone Bash minifier
#
# Collapses a Bash script to minimal whitespace using the tokeniser.
# Strips comments, converts newlines to semicolons where safe, removes
# redundant whitespace, and re-emits tokens with minimal separators.
#
# Usage:
#   ./minify.sh [options] input.sh [output.sh]
#   ./minify.sh [options] -          # read from stdin
#
# Options:
#   --check       Validate output syntax only, do not write
#   --verbose     Log every tokeniser/minifier decision to stderr
#   --quiet       Suppress progress output entirely
#
# When sourceable:
#   source ./minify.sh
#   minified=$(minify "$content")
#
# Requires: bash 4.3+ (namerefs), tools/tokeniser.sh
# _minify_log_mode: unset = progress, "verbose" = verbose, "quiet" = quiet

# Resolve tools/ directory relative to this script
_tools_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_tools_dir}/tokeniser.sh"

# ==============================================================================
# Module-level flags — set by _cli(), read by minify()/_token_to_string()
# ==============================================================================
_minify_dump_tokens=0
_minify_backtick_to_dollar=0
_minify_drop_locale=0
_minify_verify=0
_minify_stats=0
_minify_source_map=""

# ==============================================================================
# _unescape — convert _lit-encoded values back to raw text
# Reverses: \\ → \, \n → newline, \t → tab
# Writes decoded text into var named $2 (NOT stdout) to avoid trailing-NL strip.
# ==============================================================================
_unescape() {
    local s="$1"
    s="${s//\\\\/$'\x01'}"    # protect \\ → sentinel
    s="${s//\\n/$'\n'}"       # \n → newline
    s="${s//\\t/$'\t'}"       # \t → tab
    s="${s//$'\x01'/\\}"      # sentinel → single backslash
    printf -v "$2" '%s' "$s"
}

# ==============================================================================
# _unescape_str — convert _lit-encoded values for string output
# Only normalises \\\\ → \\; preserves \n and \t as literal escape sequences.
# Writes into the variable named by $2 (NOT stdout).
# ==============================================================================
_unescape_str() {
    local s="$1"
    s="${s//\\\\/\\}"
    printf -v "$2" '%s' "$s"
}

# ==============================================================================
# _word_btick — convert unquoted `...` spans inside a WORD value to $(...)
# The tokeniser's merge pass fuses backticks adjacent to a word (e.g. var=`cmd`)
# into a single WORD, so the standalone BACKTICK re-emit never sees them. This
# walks the WORD respecting single-quote spans (no processing) and backslash
# escapes; backticks inside "..." are still command subs and are converted.
# Mirrors the naive standalone conversion: outer ` ` stripped, inner verbatim.
# Writes into the variable named by $2 (NOT stdout).
# ==============================================================================
_word_btick() {
    local s="$1" _out="$2" out="" i=0 n=${#1}
    while (( i < n )); do
        local ch="${s:i:1}"
        case "$ch" in
            '\') out+="${s:i:2}"; (( i += 2 )) ;;
            "'")
                out+="'"; (( i++ ))
                while (( i < n )) && [[ "${s:i:1}" != "'" ]]; do
                    out+="${s:i:1}"; (( i++ ))
                done
                (( i < n )) && { out+="'"; (( i++ )); } ;;
            '`')
                (( i++ )); local inner=""
                while (( i < n )) && [[ "${s:i:1}" != '`' ]]; do
                    inner+="${s:i:1}"; (( i++ ))
                done
                (( i < n )) && (( i++ ))
                out+="\$(${inner})" ;;
            *) out+="$ch"; (( i++ )) ;;
        esac
    done
    printf -v "$_out" '%s' "$out"
}

# ==============================================================================
# _dump_tokens — print token stream to stderr for debugging
# Usage: _dump_tokens base_name count [adj_array_name]
# Arrays expected: ${base}_type, ${base}_val, ${base}_pos, ${base}_end
# ==============================================================================
_dump_tokens() {
    local _dt_base="$1" _dt_count="$2" _dt_adj_name="${3:-}"
    local -n _dt_type="${_dt_base}_type" _dt_val="${_dt_base}_val"
    local -n _dt_pos="${_dt_base}_pos" _dt_end="${_dt_base}_end"
    local -a _dt_adj=()
    [[ -n "$_dt_adj_name" ]] && declare -p "$_dt_adj_name" &>/dev/null && {
        local -n _dt_adj_ref="$_dt_adj_name"
        _dt_adj=("${_dt_adj_ref[@]}")
    }

    printf '# %-6s %-15s %-8s %-8s %-5s %s\n' 'TOKEN' 'TYPE' 'POS' 'END' 'ADJ' 'VALUE' >&2
    local _dj
    for (( _dj=0; _dj<_dt_count; _dj++ )); do
        local _adj="${_dt_adj[$_dj]:--}"
        printf 'T[%d]  %-15s %-8d %-8d %-5s %s\n' \
            "$_dj" "${_dt_type[$_dj]}" "${_dt_pos[$_dj]}" "${_dt_end[$_dj]}" "$_adj" "${_dt_val[$_dj]}" >&2
    done
}

# ==============================================================================
# _collapse_cmdsub_sq — rewrite newlines inside single-quoted spans in a
# command-substitution / process-substitution body as $'...' escapes, so the
# body stays on one line. Newlines inside '...' are literal bytes; unlike a
# top-level STRING_SQ token (handled in _token_to_string) a whole $( ... ) is
# one token, so its interior is scanned here with a lexical context stack.
# Writes into the variable named by $2.
# ==============================================================================
_collapse_cmdsub_sq() {
    local _s="$1" _out="" _i=0 _n=${#1} _sqs=0 _c _top _content _enc _nx
    local -a _st=("top")
    while (( _i < _n )); do
        _c="${_s:_i:1}"
        _top="${_st[-1]}"
        if [[ "$_top" == "sq" ]]; then
            if [[ "$_c" == "'" ]]; then
                _content="${_s:_sqs+1:_i-_sqs-1}"
                if [[ "$_content" == *$'\n'* ]]; then
                    _enc="${_content//\\/\\\\}"
                    _enc="${_enc//'/\\'}"
                    _enc="${_enc//$'\n'/\\n}"
                    _out+="\$'${_enc}'"
                else
                    _out+="'${_content}'"
                fi
                unset '_st[-1]'
                (( _i++ ))
            else
                (( _i++ ))
            fi
            continue
        fi
        case "$_top" in
            ansi)
                if [[ "$_c" == '\' ]]; then _out+="${_s:_i:2}"; (( _i += 2 ))
                elif [[ "$_c" == "'" ]]; then _out+="'"; unset '_st[-1]'; (( _i++ ))
                else _out+="$_c"; (( _i++ )); fi ;;
            bq)
                if [[ "$_c" == '\' ]]; then _out+="${_s:_i:2}"; (( _i += 2 ))
                elif [[ "$_c" == '`' ]]; then _out+='`'; unset '_st[-1]'; (( _i++ ))
                elif [[ "$_c" == "'" ]]; then _sqs=$_i; _st+=("sq"); (( _i++ ))
                elif [[ "$_c" == '"' ]]; then _st+=("dq"); _out+='"'; (( _i++ ))
                else _out+="$_c"; (( _i++ )); fi ;;
            dq)
                if [[ "$_c" == '\' ]]; then _out+="${_s:_i:2}"; (( _i += 2 )); continue; fi
                if [[ "$_c" == '"' ]]; then _out+='"'; unset '_st[-1]'; (( _i++ )); continue; fi
                case "$_c" in
                    '$')
                        _nx="${_s:_i+1:1}"
                        if [[ "$_nx" == "'" ]]; then _st+=("ansi"); _out+="\$'"; (( _i += 2 ))
                        elif [[ "$_nx" == '(' ]]; then
                            if [[ "${_s:_i+2:1}" == '(' ]]; then _st+=("sub" "sub"); _out+='$(('; (( _i += 3 ))
                            else _st+=("sub"); _out+='$('; (( _i += 2 )); fi
                        elif [[ "$_nx" == '{' ]]; then _st+=("param"); _out+='${'; (( _i += 2 ))
                        else _out+='$'; (( _i++ )); fi ;;
                    '`') _st+=("bq"); _out+='`'; (( _i++ )) ;;
                    *) _out+="$_c"; (( _i++ )) ;;
                esac ;;
            *)
                case "$_c" in
                    '\') _out+="${_s:_i:2}"; (( _i += 2 )) ;;
                    "'") _sqs=$_i; _st+=("sq"); (( _i++ )) ;;
                    '"') _st+=("dq"); _out+='"'; (( _i++ )) ;;
                    '`') _st+=("bq"); _out+='`'; (( _i++ )) ;;
                    '$')
                        _nx="${_s:_i+1:1}"
                        if [[ "$_nx" == "'" ]]; then _st+=("ansi"); _out+="\$'"; (( _i += 2 ))
                        elif [[ "$_nx" == '(' ]]; then
                            if [[ "${_s:_i+2:1}" == '(' ]]; then _st+=("sub" "sub"); _out+='$(('; (( _i += 3 ))
                            else _st+=("sub"); _out+='$('; (( _i += 2 )); fi
                        elif [[ "$_nx" == '{' ]]; then _st+=("param"); _out+='${'; (( _i += 2 ))
                        else _out+='$'; (( _i++ )); fi ;;
                    '(') _st+=("sub"); _out+='('; (( _i++ )) ;;
                    ')') [[ "$_top" == "sub" ]] && unset '_st[-1]'; _out+=')'; (( _i++ )) ;;
                    '}') [[ "$_top" == "param" ]] && unset '_st[-1]'; _out+='}'; (( _i++ )) ;;
                    *) _out+="$_c"; (( _i++ )) ;;
                esac ;;
        esac
    done
    printf -v "$2" '%s' "$_out"
}

# ==============================================================================
# _token_to_string — reconstruct source text for one token
# Writes into the variable named by $3 (NOT stdout) to avoid a per-token
# command-substitution fork, which dominated minify() runtime.
# ==============================================================================
_token_to_string() {
    local type="$1" val="$2" _out="$3"
    local _d
    case "$type" in
        WORD)
            # A merged WORD can carry a multi-line single-quoted span from
            # source reconstruction; collapse it to one line too.
            if [[ "$val" == *$'\n'* ]]; then
                _collapse_cmdsub_sq "$val" _d
                val="$_d"
            fi
            if (( _minify_backtick_to_dollar )) && [[ "$val" == *'`'* ]]; then
                _word_btick "$val" "$_out"
            else
                printf -v "$_out" '%s' "$val"
            fi ;;
        REDIRECT|VAR_LITERAL|RICH_STRING|REGEX_PATTERN|EXTGLOB)
            printf -v "$_out" '%s' "$val" ;;
        LOCALE_STRING)
            if (( _minify_drop_locale )); then
                local _ls="${val#\$\"}"
                _ls="${_ls%\"}"
                printf -v "$_out" '"%s"' "$_ls"
            else
                printf -v "$_out" '%s' "$val"
            fi ;;
        OP)
            printf -v "$_out" '%s' "$val" ;;
        STRING_SQ)
            if [[ "$val" == *$'\n'* ]]; then
                local _sq="$val"
                _sq="${_sq//\\/\\\\}"
                _sq="${_sq//'/\\'}"
                _sq="${_sq//$'\n'/\\n}"
                printf -v "$_out" "\$'%s'" "$_sq"
            else
                printf -v "$_out" "'%s'" "$val"
            fi ;;
        STRING_DQ)
            local _ds
            _unescape_str "$val" _ds
            printf -v "$_out" '"%s"' "$_ds" ;;
        ARITH)
            # Tokeniser emits full construct with delimiters — emit verbatim
            printf -v "$_out" '%s' "$val" ;;
        ARITH_STMT)
            # Tokeniser emits full construct with delimiters — emit verbatim
            printf -v "$_out" '%s' "$val" ;;
        ARITH_DEPRECATED)
            printf -v "$_out" '%s' "$val" ;;
        CMD_SUB)
            _unescape "$val" _d
            _collapse_cmdsub_sq "$_d" _d
            printf -v "$_out" '$(%s)' "$_d" ;;
        PROC_SUB)
            local _dir="${val%%|*}"
            local _content="${val#*|}"
            _unescape "$_content" _d
            _collapse_cmdsub_sq "$_d" _d
            printf -v "$_out" '%s(%s)' "$_dir" "$_d" ;;
        PARAM_EXP)
            printf -v "$_out" '${%s}' "$val" ;;
        BACKTICK)
            if (( _minify_backtick_to_dollar )); then
                local _bt="${val}"
                _bt="${_bt#\`}"
                _bt="${_bt%\`}"
                printf -v "$_out" '$(%s)' "$_bt"
            else
                printf -v "$_out" '%s' "$val"
            fi ;;
        HEREDOC_HEAD)
            printf -v "$_out" '%s' "$val" ;;
        HEREDOC_TAG)
            printf -v "$_out" '%s' "$val" ;;
        HEREDOC_BODY)
            _unescape "$val" _d
            printf -v "$_out" '\n%s' "$_d" ;;
        HEREDOC_TAIL)
            printf -v "$_out" '\n%s' "$val" ;;
        COMMENT)
            printf -v "$_out" '%s' "" ;;  # stripped — should not reach here
        *)
            printf -v "$_out" '%s' "$val" ;;
    esac
}

# ==============================================================================
# _skip_semi — return 0 (true) if we should NOT insert a semicolon
# ==============================================================================
_skip_semi() {
    local prev_type="$1" prev_val="$2" curr_type="$3" curr_val="$4"

    [[ "$curr_type" == "COMMENT" ]] && return 0
    [[ "$curr_type" == "REGEX_PATTERN" || "$prev_type" == "REGEX_PATTERN" ]] && return 0
    case "$curr_type" in HEREDOC_HEAD|HEREDOC_TAG|HEREDOC_BODY|HEREDOC_TAIL) return 0 ;; esac
    case "$prev_type" in HEREDOC_TAG|HEREDOC_HEAD|HEREDOC_TAIL) return 0 ;; esac

    if [[ "$prev_type" == "OP" ]]; then
        case "$prev_val" in
            ';'|'&'|'('|'{'|'&&'|'||'|'|'|';;'|';;&'|';&') return 0 ;;
        esac
    fi
    if [[ "$curr_type" == "OP" ]]; then
        case "$curr_val" in
            ')'|';;'|';;&'|';&') return 0 ;;
        esac
    fi
    if [[ "$curr_type" == "WORD" ]]; then
        case "$curr_val" in then|do|in) return 0 ;; esac
    fi
    if [[ "$prev_type" == "WORD" ]]; then
        case "$prev_val" in then|do|in|else|elif) return 0 ;; esac
    fi

    return 1
}

# ==============================================================================
# _needs_space — return 0 (true) if a space should be emitted between tokens
#
# Four sections:
#   1. Context overrides — brace_expand, array subscript, [[ ]] conditionals
#   2. Assignment RHS   — var= attaches directly to its value
#   3. Prev-token rules  — space required AFTER certain prev tokens
#   4. Curr-token rules  — space required BEFORE certain curr tokens
# Default: no space.
# ==============================================================================
_needs_space() {
    local prev_type="$1" prev_val="$2" curr_type="$3" curr_val="$4" \
          in_cond="${5:-0}" brace_expand="${6:-0}" \
          pre_paren_top="${7:-}" post_paren_top="${8:-}" \
          adj="${9:-0}"

    # ---- 1. Context overrides ----

    (( brace_expand )) && return 1

    # Array subscript: prev WORD ends with a single `[` attached to a name
    # (e.g. arr[). A standalone `[` (the test builtin) must keep its space.
    [[ "$prev_type" == WORD && "$prev_val" == *'[' && "$prev_val" != '[' && "$prev_val" != *'[[' ]] && return 1
    [[ "$curr_type" == WORD && "$curr_val" =~ ^\](\+?=) && "$prev_type" != OP ]] && return 1

    if (( in_cond )); then
        [[ "$curr_type" == REDIRECT && ( "$curr_val" == '<' || "$curr_val" == '>' ) ]] && return 0
        [[ "$prev_type" == REDIRECT && ( "$prev_val" == '<' || "$prev_val" == '>' ) ]] && return 0
    fi

    # ---- 2. Assignment RHS ----

    local _assign_lhs=''
    (( in_cond == 0 )) && [[ "$prev_type" == WORD ]] && \
        [[ "$prev_val" =~ ^[a-zA-Z_][a-zA-Z0-9_]*(\[[^]]*\])?\+?=$ ]] && \
        _assign_lhs=1

    if [[ -n "$_assign_lhs" ]]; then
        case "$curr_type" in
            PARAM_EXP|VAR_LITERAL|ARITH|ARITH_STMT|CMD_SUB|RICH_STRING) return 1 ;;
            STRING*) return 1 ;;
        esac
        [[ "$curr_type" == OP && "$curr_val" == '(' ]] && return 1
    fi

    # ---- 3. Prev-token rules ----

    [[ "$prev_type" == WORD ]] && case "$prev_val" in
        then|do|in|else|elif|\[\[|\]\]|=~) return 0 ;;
    esac

    [[ "$prev_type" == OP ]] && case "$prev_val" in
        '{')        return 0 ;;
        '(')        [[ "$post_paren_top" == subshell ]] && return 0; return 1 ;;
        '&')        return 0 ;;
        ';')        return 0 ;;
        '&&'|'||')  return 0 ;;
        ';;'|';;&'|';&') return 0 ;;
    esac

    if [[ "$curr_type" != OP ]]; then
        case "$prev_type" in
            ARITH|ARITH_STMT|CMD_SUB|PROC_SUB) return 0 ;;
        esac
    fi
    [[ "$prev_type" == PARAM_EXP   && "$curr_type" == WORD ]] && return 0
    [[ "$prev_type" == VAR_LITERAL && "$curr_type" == WORD ]] && return 0

    [[ "$prev_type" == OP && "$prev_val" == ')' ]] && {
        [[ "$curr_type" == OP   && "$curr_val" == '{' ]] && return 0
        [[ "$curr_type" == WORD ]] && return 0
    }

    [[ "$prev_type" == REGEX_PATTERN ]] && return 0

    case "$prev_type" in
        STRING_SQ|STRING_DQ|RICH_STRING|LOCALE_STRING)
            [[ "$curr_type" == WORD && "$curr_val" != '*' ]] && return 0
            case "$curr_type" in
                STRING_SQ|STRING_DQ|RICH_STRING|LOCALE_STRING) return 0 ;;
            esac ;;
    esac

    [[ "$prev_type" == REDIRECT && "$curr_type" == WORD ]] && return 1

    # ---- 4. Curr-token rules ----

    # A digit-leading redirection (fd redirect, e.g. 2>&1) must keep a space
    # after a word-like token, else the fd digit is appended to that word.
    if [[ "$curr_type" == REDIRECT && "$curr_val" =~ ^[0-9] && -z "$_assign_lhs" ]]; then
        case "$prev_type" in
            WORD|STRING_SQ|STRING_DQ|RICH_STRING|LOCALE_STRING|PARAM_EXP|\
            VAR_LITERAL|CMD_SUB|ARITH|ARITH_STMT|BACKTICK|PROC_SUB)
                return 0 ;;
        esac
    fi

    [[ "$curr_type" == WORD ]] && case "$curr_val" in
        then|do|in) return 0 ;;
        ']]') return 0 ;;
    esac

    [[ "$curr_type" == OP ]] && case "$curr_val" in
        '&&'|'||')           return 0 ;;
        ';;'|';;&'|';&')     return 0 ;;
        '(')
            [[ -n "$_assign_lhs" ]] && return 1
            [[ "$prev_type" == WORD ]] && case "$prev_val" in
                if|while|until|for|then|do|else|elif|'!') return 0 ;;
            esac
            [[ "$prev_type" == OP ]] && return 0
            [[ -z "$prev_type" ]] && return 0
            return 1 ;;
        ')')
            [[ "$pre_paren_top" == subshell ]] && return 0
            return 1 ;;
        '{')
            [[ "$prev_type" == WORD && -z "$_assign_lhs" ]] && return 0
            # After a string/expansion token a `{` is only a brace expansion
            # when directly attached; otherwise it opens a block and needs a space.
            case "$prev_type" in
                STRING_SQ|STRING_DQ|RICH_STRING|LOCALE_STRING|PARAM_EXP|VAR_LITERAL|CMD_SUB|ARITH|BACKTICK|PROC_SUB)
                    (( adj )) && return 1
                    return 0 ;;
            esac ;;
        '}')
            [[ "$prev_type" == OP && "$prev_val" == ';' ]] && return 0
            [[ "$prev_type" != OP ]] && return 0 ;;
    esac

    [[ "$curr_type" == ARITH     && "$prev_type" != OP ]] && return 0
    [[ "$curr_type" == ARITH_STMT && "$prev_type" != OP ]] && return 0
    [[ "$curr_type" == CMD_SUB   && "$prev_type" != OP ]] && return 0
    [[ "$curr_type" == BACKTICK  && "$prev_type" != OP ]] && return 0
    [[ "$curr_type" == PROC_SUB ]] && return 0
    [[ "$curr_type" == REGEX_PATTERN ]] && return 0

    if [[ "$prev_type" == WORD && -z "$_assign_lhs" && "$prev_val" != '*' ]]; then
        case "$curr_type" in
            STRING_SQ|STRING_DQ|RICH_STRING|LOCALE_STRING) return 0 ;;
            PARAM_EXP|VAR_LITERAL|CMD_SUB)                 return 0 ;;
            REDIRECT|HEREDOC_HEAD)                         return 0 ;;
        esac
    fi

    [[ "$prev_type" == WORD && "$curr_type" == WORD ]] && return 0

    return 1
}

# ==============================================================================
# _update_depth — track bracket/paren depth for array/subshell handling
# ==============================================================================
_update_depth() {
    local type="$1" val="$2"
    if [[ "$type" == "OP" ]]; then
        case "$val" in
            '(')
                if [[ "$prev_type" == WORD && "$prev_val" =~ ([a-zA-Z0-9_]|\]|\+)=$ ]]; then
                    _paren_stack+=('array')
                else
                    _paren_stack+=('subshell')
                fi
                ;;
            ')')
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

# ==============================================================================
# _case_track — track case-statement state so the minifier knows when a `)`
# closes a case PATTERN (after which a following newline must NOT become `;`,
# e.g. `a)\n  cmd` must minify to `a) cmd`, not the invalid `a); cmd`).
# States pushed on _case_st: IN (after `case`, awaiting `in`), PAT (awaiting a
# pattern-terminating `)`), BODY (inside a branch). Sets _cur_case_pat_close=1
# iff the current token is a pattern-closing `)`. Relies on dynamic scope for
# _case_st / prev_type / prev_val (minify() locals), like _update_depth.
# ==============================================================================
_case_track() {
    local type="$1" val="$2"
    _cur_case_pat_close=0
    local _top=""
    (( ${#_case_st[@]} )) && _top="${_case_st[-1]}"
    if [[ "$type" == WORD ]]; then
        # Pattern labels quoted: case/in/esac are reserved words.
        case "$val" in
            'case')
                # Only a case-start in command position (else it's an argument).
                local _cmdpos=0
                if [[ -z "$prev_type" ]]; then
                    _cmdpos=1
                elif [[ "$prev_type" == OP ]]; then
                    case "$prev_val" in
                        $'\n'|';'|';;'|';&'|';;&'|'&&'|'||'|'|'|'('|')'|'{'|'&') _cmdpos=1 ;;
                    esac
                elif [[ "$prev_type" == WORD ]]; then
                    case "$prev_val" in then|do|else|elif) _cmdpos=1 ;; esac
                fi
                (( _cmdpos )) && _case_st+=("IN") ;;
            'in')   [[ "$_top" == IN ]] && _case_st[-1]="PAT" ;;
            'esac') (( ${#_case_st[@]} )) && unset '_case_st[-1]' ;;
        esac
    elif [[ "$type" == OP ]]; then
        case "$val" in
            ')')             [[ "$_top" == PAT ]] && { _case_st[-1]="BODY"; _cur_case_pat_close=1; } ;;
            ';;'|';&'|';;&') [[ "$_top" == BODY ]] && _case_st[-1]="PAT" ;;
        esac
    fi
}

# ==============================================================================
# minify — main entry point
#
# Usage: minify "content"
#   tokenises, strips comments, collapses whitespace, emits minified source.
# When called with pre-built token arrays: minify "src" base token_count
# ==============================================================================
minify() {
    local input="$1"

    local -a _mf_type=() _mf_val=() _mf_pos=() _mf_end=() _mf_adj=()
    local _mf_count=0

    if [[ -n "${2:-}" ]]; then
        local -n _mf_src_type="${2}_type" _mf_src_val="${2}_val"
        local _mf_tc="$3"
        _mf_type=("${_mf_src_type[@]}")
        _mf_val=("${_mf_src_val[@]}")
        _mf_count=$_mf_tc
        _log_verbose "[Minifier] Using pre-built token arrays (${_mf_count} tokens)"
    else
        _log_verbose "[Minifier] Starting tokenisation..."
        tokenise "$input" _mf _mf_count _mf_adj
        _log_verbose "[Minifier] Tokenisation complete: ${_mf_count} tokens"
    fi

    # Dump tokens if requested
    if (( _minify_dump_tokens )); then
        _dump_tokens _mf "$_mf_count" _mf_adj
    fi

    local -a parts=()
    local _last_was_space=0
    local prev_type="" prev_val=""
    local i=0
    # Precompute whether the per-token progress call can do anything, so the
    # inner loop can skip the function call and its argument expansion.
    local _do_progress=0
    [[ "$_minify_log_mode" != quiet && -t 2 ]] && _do_progress=1
    local -a _paren_stack=()
    local array_depth=0
    local bracket_depth=0
    local brace_expand=0
    local -A _mf_stats=()
    local -a _mf_source_map=()
    local _mf_out_offset=0
    local -a _case_st=()           # case-statement state stack (IN/PAT/BODY)
    local _prev_case_pat_close=0   # 1 if last non-NL token closed a case pattern
    local _cur_case_pat_close=0

    _log_verbose "[Minifier] Starting token processing loop (${_mf_count} tokens)..."

    while (( i < _mf_count )); do
        local type="${_mf_type[i]}"
        local val="${_mf_val[i]}"
        (( i++ ))

        # Skip comments
        [[ "$type" == "COMMENT" ]] && continue

        # Handle newlines — convert to semicolons
        if [[ "$type" == "OP" && "$val" == $'\n' ]]; then
            # Backslash continuation
            if [[ "$prev_type" == "OP" && "$prev_val" == '\' ]]; then
                parts[-1]="${parts[-1]%\\}"
                parts+=(" "); _last_was_space=1
                prev_type=""
                prev_val=""
                _update_depth "$type" "$val"
                continue
            fi
            # Fallback: the line-continuation pre-scan can miss a joining when
            # its quote state desyncs (e.g. awk inside $( )). The word scanner
            # then folds the trailing `\` into the last token, so strip a
            # trailing continuation backslash here rather than emit `\;`.
            if (( ${#parts[@]} )) && [[ "${parts[-1]: -1}" == '\' ]]; then
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
            while (( i < _mf_count )); do
                local _nt="${_mf_type[i]}" _nv="${_mf_val[i]}"
                [[ "$_nt" == "OP" && "$_nv" == $'\n' ]] && { (( i++ )); continue; }
                break
            done

            # Inside brackets/parens — use space instead of semicolon
            if (( ${#_paren_stack[@]} > 0 || array_depth > 0 || bracket_depth > 0 )); then
                parts+=(" "); _last_was_space=1
                prev_type="OP"; prev_val=" "
            elif [[ -n "$prev_type" ]] && (( !_last_was_space )); then
                if (( i < _mf_count )); then
                    local _nt="${_mf_type[i]}" _nv="${_mf_val[i]}"
                    # `else` cannot be followed by `;`, so join to `else if`
                    # with a space (a newline here would needlessly add a line).
                    if [[ "$prev_val" == "else" && "$_nt" == "WORD" && "$_nv" == "if" ]]; then
                        parts+=(" "); _last_was_space=1
                        prev_type="OP"; prev_val=" "
                    elif (( ! _prev_case_pat_close )) && \
                         ! _skip_semi "$prev_type" "$prev_val" "$_nt" "$_nv"; then
                        parts+=("; "); _last_was_space=1
                        prev_type="OP"; prev_val=";"
                    fi
                fi
            fi
            _update_depth "$type" "$val"
            continue
        fi

        # Depth tracking
        local pre_paren_depth=${#_paren_stack[@]}
        local pre_paren_top="${_paren_stack[$((pre_paren_depth > 0 ? pre_paren_depth-1 : 0))]:-}"
        _update_depth "$type" "$val"
        local post_paren_depth=${#_paren_stack[@]}
        local post_paren_top="${_paren_stack[$((post_paren_depth > 0 ? post_paren_depth-1 : 0))]:-}"

        # Case-statement state (uses prev_*; must run before prev_* is updated)
        _case_track "$type" "$val"
        _prev_case_pat_close=$_cur_case_pat_close

        # Add space if needed
        if [[ -n "$prev_type" ]] && (( !_last_was_space )); then
            if _needs_space "$prev_type" "$prev_val" "$type" "$val" "$array_depth" "$brace_expand" "$pre_paren_top" "$post_paren_top" "${_mf_adj[i-1]:-0}"; then
                parts+=(" "); _last_was_space=1
            fi
        fi

        # Append token
        local _tok_str
        _token_to_string "$type" "$val" _tok_str
        parts+=("$_tok_str"); _last_was_space=0
        (( _do_progress )) && _progress_render "Minifying..." "$i" "$_mf_count"

        # Stats tracking
        if (( _minify_stats )); then
            _mf_stats[$type]=$(( ${_mf_stats[$type]:-0} + ${#_tok_str} ))
        fi

        # Source map tracking
        if [[ -n "$_minify_source_map" ]]; then
            local _tok_len=${#_tok_str}
            local _sm_out_end=$(( _mf_out_offset + _tok_len ))
            local _sm_in_s="${_mf_pos[$((i-1))]}" _sm_in_e="${_mf_end[$((i-1))]}"
            _mf_source_map+=("${_mf_out_offset}:${_sm_out_end}:${_sm_in_s}:${_sm_in_e}")
            _mf_out_offset=$_sm_out_end
        fi

        # Track brace expansion. Only a `{` directly attached to the previous
        # token (no intervening whitespace) can be a brace expansion; a
        # separated `{` is a block delimiter (e.g. `coproc NAME { ...; }`).
        if [[ "$type" == "OP" && "$val" == "{" ]]; then
            if (( ${_mf_adj[i-1]:-0} )) && [[ "$prev_type" =~ ^(STRING_DQ|STRING_SQ|VAR_LITERAL|PARAM_EXP|RICH_STRING)$ ]]; then
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

    local buffer
    buffer="$(printf '%s' "${parts[@]}")"

    # Trim leading/trailing space and trailing semicolon
    buffer="${buffer# }"
    buffer="${buffer% }"
    buffer="${buffer%;}"

    # Output stats if requested
    if (( _minify_stats )); then
        echo "Token stats:" >&2
        local _sk
        for _sk in "${!_mf_stats[@]}"; do
            printf '  %-15s %d bytes\n' "$_sk" "${_mf_stats[$_sk]}" >&2
        done
    fi

    # Output source map if requested
    if [[ -n "$_minify_source_map" ]]; then
        local _sm_i _sm_total=${#_mf_source_map[@]}
        printf '[' > "$_minify_source_map"
        for (( _sm_i=0; _sm_i<_sm_total; _sm_i++ )); do
            (( _sm_i > 0 )) && printf ',' >> "$_minify_source_map"
            local _sm_entry="${_mf_source_map[$_sm_i]}"
            local _sm_out_s="${_sm_entry%%:*}" _sm_rest="${_sm_entry#*:}"
            local _sm_out_e="${_sm_rest%%:*}" _sm_rest="${_sm_rest#*:}"
            local _sm_in_s="${_sm_rest%%:*}" _sm_in_e="${_sm_rest#*:}"
            printf '{"out_start":%d,"out_end":%d,"in_start":%d,"in_end":%d}' \
                "$_sm_out_s" "$_sm_out_e" "$_sm_in_s" "$_sm_in_e" >> "$_minify_source_map"
        done
        printf ']' >> "$_minify_source_map"
    fi

    printf '%s\n' "$buffer"
}

# ==============================================================================
# _verify_minified — re-tokenise output and compare against input tokens
# Returns 0 if OK, 1 if mismatch found.
# ==============================================================================
_verify_minified() {
    local original="$1" minified="$2"
    local -a _vo_type=() _vo_val=() _vm_type=() _vm_val=()
    local _vo_count=0 _vm_count=0

    tokenise "$original" _vo _vo_count
    tokenise "$minified" _vm _vm_count

    # Filter to semantic tokens (skip all OP tokens and comments)
    # The minifier transforms OPs (newlines→semicolons, whitespace removal),
    # so we only compare non-OP tokens which carry the actual content.
    local -a _vo_f_type=() _vo_f_val=() _vm_f_type=() _vm_f_val=()
    local _vi _mi
    for (( _vi=0; _vi<_vo_count; _vi++ )); do
        case "${_vo_type[$_vi]}" in
            OP|COMMENT) continue ;;
        esac
        _vo_f_type+=("${_vo_type[$_vi]}")
        _vo_f_val+=("${_vo_val[$_vi]}")
    done
    for (( _mi=0; _mi<_vm_count; _mi++ )); do
        case "${_vm_type[$_mi]}" in
            OP|COMMENT) continue ;;
        esac
        _vm_f_type+=("${_vm_type[$_mi]}")
        _vm_f_val+=("${_vm_val[$_mi]}")
    done

    # When backtick-to-dollar is active, output has CMD_SUB where input has BACKTICK
    # When drop-locale is active, output has STRING_DQ where input has LOCALE_STRING
    # Normalize both sides before comparison
    local -a _vo_n_type=() _vo_n_val=() _vm_n_type=() _vm_n_val=()
    for (( _vi=0; _vi<${#_vo_f_type[@]}; _vi++ )); do
        local _vt="${_vo_f_type[$_vi]}" _vv="${_vo_f_val[$_vi]}"
        if (( _minify_backtick_to_dollar )) && [[ "$_vt" == BACKTICK ]]; then
            _vt=CMD_SUB
            local _bt="${_vv}"
            _bt="${_bt#\`}"
            _bt="${_bt%\`}"
            _unescape "$_bt" _vv
        fi
        # WORD-embedded backticks (var=`cmd`) are converted on output too, so
        # apply the same transform here to keep input/output WORDs comparable.
        if (( _minify_backtick_to_dollar )) && [[ "$_vt" == WORD && "$_vv" == *'`'* ]]; then
            _word_btick "$_vv" _vv
        fi
        if (( _minify_drop_locale )) && [[ "$_vt" == LOCALE_STRING ]]; then
            _vt=STRING_DQ
            local _ls="${_vv#\$\"}"
            _ls="${_ls%\"}"
            _vv="$_ls"
        fi
        _vo_n_type+=("$_vt")
        _vo_n_val+=("$_vv")
    done
    for (( _mi=0; _mi<${#_vm_f_type[@]}; _mi++ )); do
        local _vt="${_vm_f_type[$_mi]}" _vv="${_vm_f_val[$_mi]}"
        _vm_n_type+=("$_vt")
        _vm_n_val+=("$_vv")
    done

    local _vf_total=${#_vo_n_type[@]}
    if (( ${#_vm_n_type[@]} != _vf_total )); then
        echo "verify: token count mismatch (input=${_vf_total}, output=${#_vm_n_type[@]})" >&2
        return 1
    fi

    for (( _vi=0; _vi<_vf_total; _vi++ )); do
        if [[ "${_vo_n_type[$_vi]}" != "${_vm_n_type[$_vi]}" ]]; then
            echo "verify: type mismatch at token ${_vi}: input=${_vo_n_type[$_vi]} output=${_vm_n_type[$_vi]}" >&2
            return 1
        fi
        local _ov="${_vo_n_val[$_vi]}" _nv="${_vm_n_val[$_vi]}"
        if [[ "$_ov" != "$_nv" ]]; then
            echo "verify: value mismatch at token ${_vi} (${_vo_n_type[$_vi]}): input='${_ov}' output='${_nv}'" >&2
            return 1
        fi
    done
    return 0
}

# ==============================================================================
# CLI
# ==============================================================================
_cli() {
    local check=0
    local input_file="" output_file=""

    # Reset module-level flags
    _minify_dump_tokens=0
    _minify_backtick_to_dollar=0
    _minify_drop_locale=0
    _minify_verify=0
    _minify_stats=0
    _minify_source_map=""

    while (( $# )); do
        case "$1" in
            --check)                check=1 ;;
            --verbose)              [[ -z "$_minify_log_mode" ]] && _minify_log_mode=verbose ;;
            --quiet)                [[ -z "$_minify_log_mode" ]] && _minify_log_mode=quiet ;;
            --dump-tokens)          _minify_dump_tokens=1 ;;
            --backtick-to-dollar)   _minify_backtick_to_dollar=1 ;;
            --drop-locale-strings)  _minify_drop_locale=1 ;;
            --verify)               _minify_verify=1 ;;
            --stats)                _minify_stats=1 ;;
            --source-map=*)         _minify_source_map="${1#--source-map=}" ;;
            --)         shift; break ;;
            -)
                if [[ -z "$input_file" ]]; then input_file="-"
                elif [[ -z "$output_file" ]]; then output_file="-"
                else echo "minify.sh: unexpected argument: $1" >&2; return 1
                fi ;;
            -*)  echo "minify.sh: unknown option: $1" >&2; return 1 ;;
            *)
                if [[ -z "$input_file" ]]; then input_file="$1"
                elif [[ -z "$output_file" ]]; then output_file="$1"
                else echo "minify.sh: unexpected argument: $1" >&2; return 1
                fi ;;
        esac
        shift
    done

    if [[ -z "$input_file" ]]; then
        echo "Usage: minify.sh [options] input.sh [output.sh]" >&2
        echo "       minify.sh [options] -" >&2
        echo "" >&2
        echo "Options:" >&2
        echo "  --check                  Validate output syntax only, do not write" >&2
        echo "  --dump-tokens            Print token stream to stderr before processing" >&2
        echo "  --backtick-to-dollar     Convert \`cmd\` to \$(cmd)" >&2
        echo "  --drop-locale-strings    Strip \$\"...\" locale wrappers" >&2
        echo "  --verify                 Re-tokenise output and compare against input" >&2
        echo "  --stats                  Print per-token-type byte counts to stderr" >&2
        echo "  --source-map=FILE        Write JSON source map to FILE" >&2
        echo "  --verbose                Log every decision to stderr" >&2
        echo "  --quiet                  Suppress all progress output" >&2
        return 1
    fi

    local content
    if [[ "$input_file" == "-" ]]; then
        content=$(cat)
    else
        [[ ! -f "$input_file" ]] && { echo "minify.sh: file not found: $input_file" >&2; return 1; }
        content=$(cat "$input_file")
    fi

    local input_bytes=${#content}

    # Validate input syntax
    local _sc_tmp
    _sc_tmp=$(mktemp /tmp/minify_sc.XXXXXX.sh)
    printf '%s\n' "$content" > "$_sc_tmp"
    if ! bash -n "$_sc_tmp" 2>/dev/null; then
        echo "minify.sh: input failed syntax check" >&2
        bash -n "$_sc_tmp" 2>&1 | head -5 >&2
        rm -f "$_sc_tmp"
        return 1
    fi
    rm -f "$_sc_tmp"

    local minified
    minified=$(minify "$content")
    _progress_done

    # Verify if requested
    if (( _minify_verify )); then
        if _verify_minified "$content" "$minified"; then
            _log_verbose "[Verify] OK — output matches input token structure"
        else
            echo "verify: FAILED — see errors above" >&2
            return 1
        fi
    fi

    # Validate output syntax
    _sc_tmp=$(mktemp /tmp/minify_sc.XXXXXX.sh)
    printf '%s\n' "$minified" > "$_sc_tmp"
    if ! bash -n "$_sc_tmp" 2>/dev/null; then
        echo "minify.sh: output failed syntax check" >&2
        bash -n "$_sc_tmp" 2>&1 | head -5 >&2
        rm -f "$_sc_tmp"
        return 1
    fi
    rm -f "$_sc_tmp"

    local output_bytes=${#minified}
    local reduction=$(( (input_bytes - output_bytes) * 100 / (input_bytes > 0 ? input_bytes : 1) ))

    (( check )) && { echo "minify.sh: syntax OK (${output_bytes} bytes, ${reduction}% reduction)" >&2; return 0; }

    if [[ -z "$output_file" || "$output_file" == "-" ]]; then
        printf '%s\n' "$minified"
    else
        printf '%s\n' "$minified" > "$output_file"
        chmod +x "$output_file"
        [[ "$_minify_log_mode" != quiet ]] && \
            echo "Minified ${input_file} -> ${output_file} (${input_bytes} -> ${output_bytes} bytes, ${reduction}%)" >&2
    fi
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _cli "$@"
    exit $?
fi
