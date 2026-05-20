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

# Shared tokeniser — logging cluster + tokenise()
source "$(dirname "${BASH_SOURCE[0]}")/tokeniser.sh"

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
