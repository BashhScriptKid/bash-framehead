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
# Requires: bash 4.3+ (namerefs), base32 (GNU coreutils, build-time only),
#           tools/tokeniser.sh, tools/minify.sh

_tools_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# minify.sh sources tokeniser.sh transitively — sourcing it here too would
# re-run tokeniser.sh's `readonly _B32D_HELPER` and emit a spurious warning.
source "${_tools_dir}/minify.sh"
obfuscate() {
    # ---- Subfunctions ----
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
    #   arith              — rename vars inside $(( )) and (( )) expressions
    #   globs              — rename vars inside EXTGLOB patterns
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
    local skip_minifier="${3:-0}"

    local -a tokens_type=() tokens_val=()
    local -A _pe_table=()
    local token_count=0

    _log_verbose "[Obfuscator] Starting tokenisation with PARSE_PE=1..."
    PARSE_PE=1 tokenise "$src" tokens token_count _pe_table
    _log_verbose "[Obfuscator] Tokenisation complete: ${token_count} tokens"

    # Dump tokens if requested
    (( _minify_dump_tokens )) && _dump_tokens tokens "$token_count"

    local _do_privfn=0  _do_fns=0  _do_lvar=0  _do_vars=0  _do_strings=0
    local _do_arith=0   _do_globs=0
    [[ "${_passes[private_functions]:-0}" == 1 ]] && _do_privfn=1
    [[ "${_passes[functions]:-0}"         == 1 ]] && _do_fns=1
    [[ "${_passes[local_variables]:-0}"   == 1 ]] && _do_lvar=1
    [[ "${_passes[variables]:-0}"         == 1 ]] && _do_vars=1
    [[ "${_passes[strings]:-0}"           == 1 ]] && _do_strings=1
    [[ "${_passes[arith]:-0}"             == 1 ]] && _do_arith=1
    [[ "${_passes[globs]:-0}"             == 1 ]] && _do_globs=1

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
                local _var_key="${_cur_fn_idx}:${_vname}"
                # If not inside a function, use -1 as scope key
                (( _cur_fn_idx < 0 )) && _var_key="-1:${_vname}"
                if [[ -z "${_var_map[$_var_key]+x}" ]]; then
                    _var_map[$_var_key]="$(_vn_name $_local_counter)"
                    _log_verbose "[Obfuscator] Mapping local: ${_vname} → ${_var_map[$_var_key]}"
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
    local -A _arith_original=()  # __arith_N__ → original ARITH/ARITH_STMT val

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
        ARITH|ARITH_STMT)
            # Bare var names inside (( )) / $(( )) — rename in token val directly
            if (( _do_arith && _do_lvar && ${#_var_map[@]} > 0 )); then
                local _av="$_p2v" _ak _aon _arn
                for _ak in "${!_var_map[@]}"; do
                    _aon="${_ak#*:}"
                    _arn="${_var_map[$_ak]}"
                    _av="${_av//${_aon}/${_arn}}"
                done
                if [[ "$_av" != "$_p2v" ]]; then
                    # Use token index as unique key to avoid special-char issues
                    local _replacement_key="__arith_${_p2i}__"
                    _replacements[$_replacement_key]="$_av"
                    _repl_order+=("$_replacement_key")
                    # Store original value for the apply phase
                    _arith_original[$_replacement_key]="$_p2v"
                fi
            fi
            ;;
        EXTGLOB)
            # EXTGLOB patterns rarely contain variable refs, but scan for safety
            if (( _do_globs && _do_lvar && ${#_var_map[@]} > 0 )); then
                local _gv="$_p2v" _gk _gon _grn
                for _gk in "${!_var_map[@]}"; do
                    _gon="${_gk#*:}"
                    _grn="${_var_map[$_gk]}"
                    _gv="${_gv//${_gon}/${_grn}}"
                done
                if [[ "$_gv" != "$_p2v" ]]; then
                    if [[ -z "${_replacements[$_p2v]+x}" ]]; then
                        _replacements[$_p2v]="$_gv"
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
    # Sort by length descending using bash
    local -a _sorted_keys=()
    local _sk
    for _sk in "${_repl_order[@]}"; do
        local _sk_len=${#_sk}
        local _inserted=0
        local _si
        for (( _si=0; _si<${#_sorted_keys[@]}; _si++ )); do
            if (( ${#_sorted_keys[$_si]} < _sk_len )); then
                _sorted_keys=("$_sk" "${_sorted_keys[@]:$_si}")
                _inserted=1
                break
            fi
        done
        (( ! _inserted )) && _sorted_keys+=("$_sk")
    done

    for _rk in "${_sorted_keys[@]}"; do
        _rv="${_replacements[$_rk]}"
        # __arith_N__ keys: use original ARITH/ARITH_STMT value as search pattern
        if [[ "$_rk" == __arith_* ]]; then
            local _orig="${_arith_original[$_rk]}"
            result="${result//"${_orig}"/"${_rv}"}"
        else
            result="${result//"${_rk}"/"${_rv}"}"
        fi
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



# ==============================================================================
# CLI
# ==============================================================================
_cli() {
    local check=0 skip_minifier=0
    local input_file="" output_file=""
    local -A passes=([private_functions]=1 [local_variables]=1
                     [functions]=0 [variables]=0 [strings]=0
                     [arith]=0 [globs]=0)

    while (( $# )); do
        case "$1" in
            --check)          check=1 ;;
            --verbose)        [[ -z "$_minify_log_mode" ]] && _minify_log_mode=verbose ;;
            --quiet)          [[ -z "$_minify_log_mode" ]] && _minify_log_mode=quiet ;;
            --skip-minifier)  skip_minifier=1 ;;
            --dump-tokens)    _minify_dump_tokens=1 ;;
            --obfuscate=*)
                local _ob_val="${1#--obfuscate=}"
                for k in "${!passes[@]}"; do passes[$k]=0; done
                local _ob_pass
                IFS=',' read -ra _ob_passes <<< "$_ob_val"
                for _ob_pass in "${_ob_passes[@]}"; do
                    _ob_pass="${_ob_pass// /}"
                    case "$_ob_pass" in
                        all)
                            for k in "${!passes[@]}"; do passes[$k]=1; done
                            ;;
                        private_functions|functions|local_variables|variables|strings|arith|globs)
                            passes[$_ob_pass]=1
                            ;;
                        *)
                            echo "obfuscate.sh: unknown pass: ${_ob_pass}" >&2
                            echo "  valid passes: all, private_functions, functions, local_variables, variables, strings, arith, globs" >&2
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
        echo "                      local_variables,variables,strings,arith,globs" >&2
        echo "                      (default: private_functions,local_variables)" >&2
        echo "  --skip-minifier     Obfuscate raw source without minifying first" >&2
        echo "  --dump-tokens       Print token stream to stderr before processing" >&2
        echo "  --check             Validate output syntax only, do not write" >&2
        echo "  --verbose           Log every decision to stderr" >&2
        echo "  --quiet             Suppress all progress output" >&2
        return 1
    fi

    local content
    if [[ "$input_file" == "-" ]]; then
        content=$(cat)
    else
        [[ ! -f "$input_file" ]] && { echo "obfuscate.sh: file not found: $input_file" >&2; return 1; }
        content=$(cat "$input_file")
    fi

    local input_bytes=${#content}

    # Validate input syntax
    local _sc_tmp
    _sc_tmp=$(mktemp /tmp/obfuscate_sc.XXXXXX.sh)
    printf '%s\n' "$content" > "$_sc_tmp"
    if ! bash -n "$_sc_tmp" 2>/dev/null; then
        echo "obfuscate.sh: input failed syntax check" >&2
        bash -n "$_sc_tmp" 2>&1 | head -5 >&2
        rm -f "$_sc_tmp"
        return 1
    fi
    rm -f "$_sc_tmp"

    # Step 1: minify (unless skipped)
    local to_obfuscate="$content"
    if (( !skip_minifier )); then
        _log_verbose "[Pipeline] Minifying..."
        to_obfuscate=$(minify "$content")
        _progress_done
        _log_verbose "[Pipeline] Minification done (${#to_obfuscate} bytes)"
    fi

    # Step 2: obfuscate
    local obfuscated
    obfuscated=$(obfuscate "$to_obfuscate" passes "$skip_minifier")
    _progress_done

    # Validate output syntax
    _sc_tmp=$(mktemp /tmp/obfuscate_sc.XXXXXX.sh)
    printf '%s\n' "$obfuscated" > "$_sc_tmp"
    if ! bash -n "$_sc_tmp" 2>/dev/null; then
        echo "obfuscate.sh: output failed syntax check" >&2
        bash -n "$_sc_tmp" 2>&1 | head -5 >&2
        if [[ -n "$output_file" && "$output_file" != "-" ]]; then
            printf '%s\n' "$obfuscated" > "${output_file}.broken"
            echo "obfuscate.sh: broken output written to ${output_file}.broken" >&2
        fi
        rm -f "$_sc_tmp"
        return 1
    fi
    rm -f "$_sc_tmp"

    local output_bytes=${#obfuscated}
    local reduction=$(( (input_bytes - output_bytes) * 100 / (input_bytes > 0 ? input_bytes : 1) ))

    (( check )) && { echo "obfuscate.sh: syntax OK (${output_bytes} bytes)" >&2; return 0; }

    if [[ -z "$output_file" || "$output_file" == "-" ]]; then
        printf '%s\n' "$obfuscated"
    else
        printf '%s\n' "$obfuscated" > "$output_file"
        chmod +x "$output_file"
        [[ "$_minify_log_mode" != quiet ]] && {
            local _op_label="Obfuscated"
            echo "${_op_label} ${input_file} -> ${output_file} (${input_bytes} -> ${output_bytes} bytes, ${reduction}%)" >&2
        }
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _cli "$@"
fi
