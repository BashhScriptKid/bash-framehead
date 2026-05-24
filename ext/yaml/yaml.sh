# ext/yaml/yaml.sh — Pure Bash YAML parser (pragmatic subset)
#
# Converts YAML to JSON using indentation tracking.  Supports maps, sequences,
# nesting, flow style, quoted strings, comments, and YAML boolean/null types.
#
# Dependencies:
#   core: runtime
#   external: none

# --- guard ---
declare -f 'runtime::bash_version' &>/dev/null || {
    echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
    return 1
}

_guard_core_deps=()
_guard_ext_deps=()

for _guard_dep in "${_guard_core_deps[@]}"; do
    declare -f "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing core function '$_guard_dep'" >&2
        return 1
    }
done

for _guard_dep in "${_guard_ext_deps[@]}"; do
    command -v "$_guard_dep" &>/dev/null || {
        echo "${BASH_SOURCE[0]}: missing external tool '$_guard_dep'" >&2
        return 1
    }
done

unset _guard_core_deps _guard_ext_deps _guard_dep
# --- end guard ---

# ============================================================================
# Internal helpers
# ============================================================================

_yaml_json_escape() {
    local _s="$1" _out="" _i=0 _ch
    while (( _i < ${#_s} )); do
        _ch="${_s:_i:1}"
        case "$_ch" in
            '"')  _out+='\"' ;;
            '\')  _out+='\\' ;;
            $'\n') _out+='\n' ;;
            $'\r') _out+='\r' ;;
            $'\t') _out+='\t' ;;
            *)    _out+="$_ch" ;;
        esac
        ((_i++))
    done
    echo "$_out"
}

_yaml_unquote() {
    local _s="$1"
    if [[ "$_s" =~ ^\".*\"$ && ${#_s} -ge 2 ]]; then
        _s="${_s:1:-1}"
        _s="$(_yaml_parse_escapes "$_s")"
    elif [[ "$_s" =~ ^\'.*\'$ && ${#_s} -ge 2 ]]; then
        _s="${_s:1:-1}"
    fi
    echo "$_s"
}

_yaml_strip_tag() {
    local _s="$1"
    # Strip leading YAML tags: !!str, !t, !<urn:foo>, etc.
    while [[ "$_s" =~ ^[[:space:]]*!(!?[^[:space:]]+[[:space:]]+)+ ]]; do
        _s="${_s#* }"; _s="${_s# }"
    done
    echo "$_s"
}

_yaml_parse_escapes() {
    local _s="$1" _out="" _i=0 _ch
    while (( _i < ${#_s} )); do
        _ch="${_s:_i:1}"
        if [[ "$_ch" == '\' ]] && (( _i + 1 < ${#_s} )); then
            case "${_s:_i+1:1}" in
                n)  _out+=$'\n'; ((_i+=2)); continue ;;
                r)  _out+=$'\r'; ((_i+=2)); continue ;;
                t)  _out+=$'\t'; ((_i+=2)); continue ;;
                '\') _out+='\'; ((_i+=2)); continue ;;
                '"') _out+='"'; ((_i+=2)); continue ;;
                /)  _out+='/'; ((_i+=2)); continue ;;
                b)  _out+=$'\b'; ((_i+=2)); continue ;;
                f)  _out+=$'\f'; ((_i+=2)); continue ;;
                a)  _out+=$'\a'; ((_i+=2)); continue ;;
                v)  _out+=$'\v'; ((_i+=2)); continue ;;
                e)  _out+=$'\e'; ((_i+=2)); continue ;;
                ' ') _out+=' '; ((_i+=2)); continue ;;  # escaped space
                *)  _out+="$_ch"; ((_i++)); continue ;; # unknown: keep as-is
            esac
        fi
        _out+="$_ch"
        ((_i++))
    done
    echo "$_out"
}

_yaml_scalar_to_json() {
    local _v="$1"
    _v="$(_yaml_strip_tag "$_v")"
    # Alias: *name → substitute stored anchor JSON
    if [[ "$_v" =~ ^\*([a-zA-Z0-9_]+)$ ]]; then
        local _aname="${BASH_REMATCH[1]}"
        if [[ -n "${_YAML_ANCHORS["$_aname"]+set}" ]]; then
            echo "${_YAML_ANCHORS["$_aname"]}"
            return
        fi
    fi
    case "$_v" in
        '~'|'null'|'Null'|'NULL')  echo 'null'; return ;;
    esac
    case "$_v" in
        'true'|'True'|'TRUE'|'yes'|'Yes'|'YES'|'on'|'On'|'ON')
            echo 'true'; return ;;
        'false'|'False'|'FALSE'|'no'|'No'|'NO'|'off'|'Off'|'OFF')
            echo 'false'; return ;;
    esac
    [[ "$_v" =~ ^-?[0-9]+$ ]] && { echo "$_v"; return; }
    [[ "$_v" =~ ^-?[0-9]+\.[0-9]+$ ]] && { echo "$_v"; return; }
    echo "\"$(_yaml_json_escape "$_v")\""
}

# Check whether a string has all quotes closed.  Returns 0 (success) if all
# single and double quotes are balanced; 1 if a quote is unclosed.
_yaml_quote_closed() {
    local _s="$1" _sq=0 _dq=0 _i=0 _ch
    while (( _i < ${#_s} )); do
        _ch="${_s:_i:1}"
        if [[ "$_ch" == '\' ]] && (( _i + 1 < ${#_s} )); then ((_i+=2)); continue; fi
        [[ "$_ch" == "'" ]] && (( _sq ^= 1 ))
        [[ "$_ch" == '"' ]] && (( _dq ^= 1 ))
        ((_i++))
    done
    (( _sq == 0 && _dq == 0 ))
}

_yaml_count_indent() {
    local _n=0 _c
    while (( _n < ${#1} )); do
        _c="${1:_n:1}"
        [[ "$_c" == ' ' || "$_c" == $'\t' ]] || break
        ((_n++))
    done
    echo "$_n"
}

_yaml_strip_comment() {
    local _s="$1" _out="" _i=0 _ch _in_sq=0 _in_dq=0
    while (( _i < ${#_s} )); do
        _ch="${_s:_i:1}"
        if (( _in_sq )); then
            [[ "$_ch" == "'" ]] && _in_sq=0; _out+="$_ch"
        elif (( _in_dq )); then
            [[ "$_ch" == '"' ]] && _in_dq=0; _out+="$_ch"
        elif [[ "$_ch" == "'" ]]; then
            _in_sq=1; _out+="$_ch"
        elif [[ "$_ch" == '"' ]]; then
            _in_dq=1; _out+="$_ch"
        elif [[ "$_ch" == '#' ]] && { [[ -z "$_out" ]] || [[ "${_out: -1}" =~ [[:space:]] ]]; }; then
            break
        else
            _out+="$_ch"
        fi
        ((_i++))
    done
    echo "${_out%"${_out##*[![:space:]]}"}"
}

# ============================================================================
# Anchor / alias resolution
# ============================================================================

# Global anchor symbol table — populated by pre-pass, used during parsing.
# Keys are anchor names; values are the JSON representation of the anchored node.
declare -A _YAML_ANCHORS=()

# Pre-scan YAML for &anchor definitions.  Extracts each anchored subtree,
# parses it via yaml::to_json, and stores the result in _YAML_ANCHORS[name].
# Recursive anchors within subtrees are handled naturally by re-entrant calls.
_yaml_collect_anchors() {
    local _yaml="$1" _line _name _indent _base_indent _buf _in=0 _next

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        _indent=$(_yaml_count_indent "$_line")

        if (( _in )); then
            if (( _indent > _base_indent )); then
                if [[ -z "$_buf" ]]; then _buf="$_line"; else _buf+=$'\n'"$_line"; fi
                continue
            fi
            # Subtree ended — parse and store
            _YAML_ANCHORS["$_name"]="$(yaml::to_json "$_buf" 2>/dev/null)"
            _in=0
        fi

        if [[ "$_line" =~ \&([a-zA-Z0-9_]+) ]]; then
            _name="${BASH_REMATCH[1]}"
            _base_indent=$_indent
            # Extract the value part (after colon or dash, if any)
            local _anchor_line="${_line//\&$_name/}"
            local _inline_val=""
            if [[ "$_anchor_line" =~ :[[:space:]]*$ ]]; then
                _buf=""  # empty value after colon, subtree follows
            elif [[ "$_anchor_line" =~ :[[:space:]]+ ]]; then
                _inline_val="${_anchor_line#*:}"; _inline_val="${_inline_val# }"
            elif [[ "$_anchor_line" =~ ^[[:space:]]*-[[:space:]]+[^[:space:]] ]]; then
                # - &name value → extract value after the dash+space
                _inline_val="${_anchor_line#*-}"; _inline_val="${_inline_val#"${_inline_val%%[![:space:]]*}"}"
            else
                _buf=""  # no inline value, subtree follows
            fi
            if [[ -n "$_inline_val" ]]; then
                _YAML_ANCHORS["$_name"]="$(_yaml_scalar_to_json "$_inline_val")"
                continue  # inline scalar anchor
            fi
            _in=1
        fi
    done <<< "$_yaml"

    # Flush last anchor
    if (( _in )); then
        _YAML_ANCHORS["$_name"]="$(yaml::to_json "$_buf" 2>/dev/null)"
    fi
}

# Flush accumulated block scalar lines into a JSON-escaped string.
# Reads _block_type, _block_lines, _block_chomp; echoes the JSON value.
_yaml_flush_block_scalar() {
    local _joined=""
    if [[ "$_block_type" == '|' ]]; then
        printf -v _joined '%s\n' "${_block_lines[@]}"
        _joined="${_joined%$'\n'}"
    else  # >
        local _b
        for _b in "${_block_lines[@]}"; do
            [[ -z "${_b##*[![:space:]]*}" ]] && _joined+="$_b " || _joined+=$'\n'
        done
        _joined="${_joined% }"
    fi
    case "$_block_chomp" in
        *-) _joined="${_joined%"${_joined##*[!$'\n']}"}" ;;      # strip
        *+) ;;                                                    # keep
        *)  _joined="${_joined%$'\n'}" ;;                         # clip one
    esac
    printf '%s' "\"$(_yaml_json_escape "$_joined")\""
}
yaml::to_json() {
    local _yaml="${1:-$(cat)}"
    # Collect anchors before parsing (only top-level clears the dict)
    _YAML_ANCHORS=()
    _yaml_collect_anchors "$_yaml"

    local _line _stripped _indent _key _val _item
    local _json="" _needs_value=0 _pending_key_indent=0
    local -a _s_ind=() _s_typ=() _s_cnt=()
    local _dp=0
    local _in_multiline=0 _multiline_buf=""
    local _in_block=0 _block_indent=0 _block_content_indent=0 _block_type="" _block_chomp="" _block_lines=()
    local _in_continuation=0

    while IFS= read -r _line; do
        # Multi-line quoted string: accumulate until quotes close
        if (( _in_multiline )); then
            _multiline_buf+=$'\n'"$_line"
            if _yaml_quote_closed "$_multiline_buf"; then
                _line="$_multiline_buf"
                _in_multiline=0
            else
                continue
            fi
        fi

        _line="${_line%$'\r'}"

        # Detect unclosed quotes — buffer and enter multi-line mode
        if ! _yaml_quote_closed "$_line"; then
            _multiline_buf="$_line"
            _in_multiline=1
            continue
        fi

        # Block scalar accumulation: collect indented lines after | or >
        if (( _in_block )); then
            local _bline_indent
            _bline_indent=$(_yaml_count_indent "$_line")
            # First content line sets the minimum content indent
            if (( ${#_block_lines[@]} == 0 )); then
                _block_content_indent=$_bline_indent
            fi
            if (( _bline_indent >= _block_content_indent )) && ! [[ "$_line" =~ ^[[:space:]]*# ]]; then
                _block_lines+=("${_line:$_block_content_indent}")
                continue
            fi
            # Embedded blank line inside block (indent may be 0, but we have content)
            if [[ "$_line" =~ ^[[:space:]]*$ ]] && (( ${#_block_lines[@]} > 0 )); then
                _block_lines+=("")
                continue
            fi
            # Block ended — process and emit
            _json+="$(_yaml_flush_block_scalar)"
            _in_block=0
            _needs_value=0
            if (( _dp > 0 )); then _s_cnt[_dp-1]=1; fi
            # Fall through to process this line normally
        fi

        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*# ]] && continue
        # Skip YAML document markers
        [[ "$_line" =~ ^[[:space:]]*---[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*\.\.\.[[:space:]]*$ ]] && continue

        _indent=$(_yaml_count_indent "$_line")
        _stripped="${_line:_indent}"
        _stripped="$(_yaml_strip_comment "$_stripped")"
        [[ -z "$_stripped" ]] && continue
        # Strip leading YAML tags (!tag or !!tag) so flow containers and
        # scalars are recognised without the tag prefix.
        _stripped="$(_yaml_strip_tag "$_stripped")"
        # Strip anchor markers: &name (definition, value parsed normally)
        if [[ "$_stripped" =~ \&([a-zA-Z0-9_]+) ]]; then
            local _aname="${BASH_REMATCH[1]}"
            _stripped="${_stripped//\&${_aname} /}"  # &name followed by space
            _stripped="${_stripped//\&${_aname}/}"   # &name at end of line
            # Trim any leading space left behind (e.g. "&name [" → " [")
            _stripped="${_stripped#"${_stripped%%[![:space:]]*}"}"
        fi
        [[ -z "$_stripped" ]] && continue

        # --- Pop: close containers whose indent is strictly less than current ---
        while (( _dp > 0 )) && (( _indent < _s_ind[_dp-1] )); do
            _json+=$([[ "${_s_typ[_dp-1]}" == 'M' ]] && echo '}' || echo ']')
            ((_dp--))
        done

        # --- Close map at same indent when we return to parent level ---
        # _dp > 1 guards the root map.
        if (( _dp > 1 )) && (( _indent == _s_ind[_dp-1] )) \
                         && [[ "${_s_typ[_dp-1]}" == 'M' ]] \
                         && (( ! _needs_value )); then
            _json+="}"
            ((_dp--))
        fi

        # --- Comma: if current container has content, add separator ---
        if (( _dp > 0 )) && (( _s_cnt[_dp-1] > 0 )) && (( ! _needs_value )); then
            _json+=","
        fi

        # --- Flow containers: {key: val} or [item, ...] at current level ---
        if [[ "$_stripped" =~ ^\{.*\}$ ]] || [[ "$_stripped" =~ ^\[.*\]$ ]]; then
            _json+="$(_yaml_inline_flow "$_stripped")"
            _needs_value=0
            if (( _dp > 0 )); then _s_cnt[_dp-1]=1; fi
            continue
        fi

        # --- Sequence item: - value ---
        if [[ "$_stripped" == '-' ]] || [[ "$_stripped" =~ ^-\  ]]; then
            _item="${_stripped#-}"
            [[ -n "$_item" ]] && _item="${_item#"${_item%%[![:space:]]*}"}"

            # Block scalar in sequence: - | or - >
            if [[ "$_item" =~ ^[\|\>] ]]; then
                _block_type="${_item:0:1}"
                _block_chomp="${_item:1}"
                _block_indent=$_indent
                _block_lines=()
                _block_content_indent=0
                _in_block=1
                # Push array container if needed (simplified — emits scalar string)
                if (( _dp == 0 )) || [[ "${_s_ind[_dp-1]}" -ne "$_indent" ]] \
                                  || [[ "${_s_typ[_dp-1]}" != 'A' ]]; then
                    _json+="["
                    _s_ind[_dp]=$_indent
                    _s_typ[_dp]='A'
                    _s_cnt[_dp]=0
                    ((_dp++))
                fi
                _s_cnt[_dp-1]=1
                _needs_value=0
                continue
            fi

            # Push array container if we're not already in one at this indent
            if (( _dp == 0 )) || [[ "${_s_ind[_dp-1]}" -ne "$_indent" ]] \
                              || [[ "${_s_typ[_dp-1]}" != 'A' ]]; then
                _json+="["
                _s_ind[_dp]=$_indent
                _s_typ[_dp]='A'
                _s_cnt[_dp]=0
                ((_dp++))
            fi
            _s_cnt[_dp-1]=1
            _needs_value=0

            if [[ -z "$_item" ]]; then
                # Bare dash — push map for subsequent indented keys
                _json+="{"
                _s_ind[_dp]=$_indent
                _s_typ[_dp]='M'
                _s_cnt[_dp]=0
                ((_dp++))
            elif [[ "$_item" =~ ^\{ ]]; then
                _json+="$(_yaml_inline_flow "$_item")"
            elif [[ "$_item" =~ ^\[ ]]; then
                _json+="$(_yaml_inline_flow "$_item")"
            elif [[ "$_item" =~ :[[:space:]] ]]; then
                # - key: value → push object, emit first entry, leave open
                _key="${_item%%:*}"
                _val="${_item#*:}"
                _key="${_key%"${_key##*[![:space:]]}"}"
                _key="$(_yaml_unquote "$_key")"
                _val="${_val#"${_val%%[![:space:]]*}"}"

                # Push the object
                _json+="{"
                _s_ind[_dp]=$_indent
                _s_typ[_dp]='M'
                _s_cnt[_dp]=1
                ((_dp++))

                # Check for block scalar in the value
                if [[ "$_val" =~ ^[\|\>] ]]; then
                    _block_type="${_val:0:1}"
                    _block_chomp="${_val:1}"
                    _block_indent=$_indent
                    _block_lines=()
                    _block_content_indent=0
                _in_block=1
                    _json+="\"$(_yaml_json_escape "$_key")\":"
                    _needs_value=1
                    _pending_key_indent=$_indent
                    continue
                fi

                _val="$(_yaml_unquote "$_val")"
                _json+="\"$(_yaml_json_escape "$_key")\":$(_yaml_scalar_to_json "$_val")"
            else
                _item="$(_yaml_unquote "$_item")"
                _json+="$(_yaml_scalar_to_json "$_item")"
            fi
            continue
        fi

        # --- Continuation: pending value resolved by plain scalar ---
        # Only fire for lines without colon (map entries go through the
        # normal map branch, which handles _needs_value there).
        if (( _needs_value )) && [[ ! "$_stripped" =~ : ]] && [[ ! "$_stripped" =~ ^- ]]; then
            _val="$(_yaml_unquote "$_stripped")"
            _json+="$(_yaml_scalar_to_json "$_val")"
            _needs_value=0
            _in_continuation=1
            continue
        fi

        # --- Additional plain scalar continuation lines ---
        if (( _in_continuation )) && [[ ! "$_stripped" =~ : ]] && [[ ! "$_stripped" =~ ^- ]]; then
            _val="$(_yaml_unquote "$_stripped")"
            # Replace last " in JSON string with space + continuation + "
            _json="${_json%\"}"
            _json+=" $(_yaml_json_escape "$_val")\""
            continue
        fi
        _in_continuation=0

        # --- Map entry: key: value ---
        if [[ "$_stripped" =~ : ]]; then
            _key="${_stripped%%:*}"
            _val="${_stripped#*:}"
            _key="${_key%"${_key##*[![:space:]]}"}"
            _key="$(_yaml_unquote "$_key")"
            _val="${_val#"${_val%%[![:space:]]*}"}"

            # Merge key: <<: *name → expand anchor's keys into current map
            if [[ "$_key" == '<<' ]] && [[ "$_val" =~ ^\*([a-zA-Z0-9_]+)$ ]]; then
                local _merge_anchor="${BASH_REMATCH[1]}"
                if [[ -n "${_YAML_ANCHORS["$_merge_anchor"]+set}" ]]; then
                    # If awaiting a value from a parent key, open the map first
                    if (( _needs_value )); then
                        _json+="{"
                        _s_ind[_dp]=$_pending_key_indent
                        _s_typ[_dp]='M'
                        _s_cnt[_dp]=0
                        ((_dp++))
                        _needs_value=0
                    fi
                    local _merge_json="${_YAML_ANCHORS["$_merge_anchor"]}"
                    if [[ "$_merge_json" =~ ^\{.*\}$ ]]; then
                        _merge_json="${_merge_json:1:-1}"
                        _merge_json="${_merge_json#"${_merge_json%%[![:space:]]*}"}"
                        _merge_json="${_merge_json%"${_merge_json##*[![:space:]]}"}"
                        if [[ -n "$_merge_json" ]]; then
                            _json+="$_merge_json"
                            if (( _dp > 0 )); then _s_cnt[_dp-1]=1; fi
                        fi
                    fi
                fi
                continue
            fi

            # Lazy root map (must open before block scalar below)
            if (( _dp == 0 )); then
                _json+="{"
                _s_ind[0]=$_indent
                _s_typ[0]='M'
                _s_cnt[0]=0
                _dp=1
            fi

            # Block scalar: | or > after colon (before any other value processing)
            if [[ "$_val" =~ ^[\|\>] ]]; then
                _block_type="${_val:0:1}"
                _block_chomp="${_val:1}"  # remainder: chomp/indent modifiers
                _block_indent=$_indent
                _block_lines=()
                _block_content_indent=0
                _in_block=1
                _json+="\"$(_yaml_json_escape "$_key")\":"
                _needs_value=1
                _pending_key_indent=$_indent
                _s_cnt[_dp-1]=1
                continue
            fi

            _s_cnt[_dp-1]=1

            if [[ -z "$_val" ]]; then
                # Empty value.  If we're already waiting for a value (nested
                # empty key), push the map container first.
                if (( _needs_value )); then
                    _json+="{"
                    _s_ind[_dp]=$_pending_key_indent
                    _s_typ[_dp]='M'
                    _s_cnt[_dp]=0
                    ((_dp++))
                    _needs_value=0
                fi
                _json+="\"$(_yaml_json_escape "$_key")\":"
                _needs_value=1
                _pending_key_indent=$_indent
            elif (( _needs_value )); then
                # Previous line was an empty key — this map entry at deeper
                # indent is the value, so push the map container first.
                _json+="{"
                _s_ind[_dp]=$_pending_key_indent
                _s_typ[_dp]='M'
                _s_cnt[_dp]=0
                ((_dp++))
                _needs_value=0
                _val="$(_yaml_unquote "$_val")"
                _json+="\"$(_yaml_json_escape "$_key")\":$(_yaml_scalar_to_json "$_val")"
                _s_cnt[_dp-1]=1
            elif [[ "$_val" =~ ^\{ ]]; then
                _json+="\"$(_yaml_json_escape "$_key")\":$(_yaml_inline_flow "$_val")"
                _needs_value=0
            elif [[ "$_val" =~ ^\[ ]]; then
                _json+="\"$(_yaml_json_escape "$_key")\":$(_yaml_inline_flow "$_val")"
                _needs_value=0
            else
                _val="$(_yaml_unquote "$_val")"
                _json+="\"$(_yaml_json_escape "$_key")\":$(_yaml_scalar_to_json "$_val")"
                _needs_value=0
            fi
            continue
        fi
    done <<< "$_yaml"

    # Flush pending block scalar
    if (( _in_block )); then
        _json+="$(_yaml_flush_block_scalar)"
        _in_block=0
        _needs_value=0
    fi

    # Resolve pending empty value (key: with no continuation)
    if (( _needs_value )); then
        _json+="null"
        _needs_value=0
    fi

    # Close remaining containers
    while (( _dp > 0 )); do
        _json+=$([[ "${_s_typ[_dp-1]}" == 'M' ]] && echo '}' || echo ']')
        ((_dp--))
    done

    [[ -z "$_json" ]] && _json="{}"
    echo "$_json"
}

# ============================================================================
# _yaml_inline_flow <expr>
# ============================================================================
_yaml_inline_flow() {
    local _expr="$1"
    _expr="${_expr#"${_expr%%[![:space:]]*}"}"
    _expr="${_expr%"${_expr##*[![:space:]]}"}"

    if [[ "$_expr" =~ ^\{.*\}$ ]]; then
        local _inner="${_expr:1:-1}"
        _inner="${_inner#"${_inner%%[![:space:]]*}"}"
        _inner="${_inner%"${_inner##*[![:space:]]}"}"
        local _result="{" _first=1 _pair _k _v
        local _depth=0 _in_sq=0 _in_dq=0 _i=0 _ch _start=0 _len="${#_inner}"

        while (( _i <= _len )); do
            _ch="${_inner:_i:1}"
            if (( _in_sq )); then
                [[ "$_ch" == "'" ]] && _in_sq=0
            elif (( _in_dq )); then
                [[ "$_ch" == '\' ]] && { ((_i+=2)); continue; }
                [[ "$_ch" == '"' ]] && _in_dq=0
            elif [[ "$_ch" == "'" ]]; then
                _in_sq=1
            elif [[ "$_ch" == '"' ]]; then
                _in_dq=1
            elif [[ "$_ch" == '{' || "$_ch" == '[' ]]; then
                ((_depth++))
            elif [[ "$_ch" == '}' || "$_ch" == ']' ]]; then
                ((_depth--))
            elif [[ "$_ch" == ',' && _depth -eq 0 ]] || (( _i == _len )); then
                # Emit the accumulated pair at depth 0
                _pair="${_inner:_start:_i-_start}"
                _pair="${_pair#"${_pair%%[![:space:]]*}"}"
                _pair="${_pair%"${_pair##*[![:space:]]}"}"
                # Strip anchor markers inside flow maps
                if [[ "$_pair" =~ \&([a-zA-Z0-9_]+) ]]; then
                    _pair="${_pair//\&${BASH_REMATCH[1]} /}"
                    _pair="${_pair//\&${BASH_REMATCH[1]}/}"
                fi
                if [[ -n "$_pair" && "$_pair" =~ : ]]; then
                    _k="${_pair%%:*}"
                    _v="${_pair#*:}"
                    _k="${_k%"${_k##*[![:space:]]}"}"
                    _k="$(_yaml_unquote "$_k")"
                    _v="${_v# }"
                    if [[ "$_v" =~ ^\{ ]] || [[ "$_v" =~ ^\[ ]]; then
                        local _flow_val="$(_yaml_inline_flow "$_v")"
                        (( _first )) && _first=0 || _result+=","
                        _result+="\"$(_yaml_json_escape "$_k")\":$_flow_val"
                    else
                        _v="$(_yaml_unquote "$_v")"
                        (( _first )) && _first=0 || _result+=","
                        _result+="\"$(_yaml_json_escape "$_k")\":$(_yaml_scalar_to_json "$_v")"
                    fi
                fi
                _start=$(( _i + 1 ))
            fi
            ((_i++))
        done
        echo "${_result}}"
        return
    fi

    if [[ "$_expr" =~ ^\[.*\]$ ]]; then
        local _inner="${_expr:1:-1}"
        _inner="${_inner#"${_inner%%[![:space:]]*}"}"
        _inner="${_inner%"${_inner##*[![:space:]]}"}"
        local _result="[" _first=1 _item
        local _depth=0 _in_sq=0 _in_dq=0 _i=0 _ch _start=0 _len="${#_inner}"

        while (( _i <= _len )); do
            _ch="${_inner:_i:1}"
            if (( _in_sq )); then
                [[ "$_ch" == "'" ]] && _in_sq=0
            elif (( _in_dq )); then
                [[ "$_ch" == '\' ]] && { ((_i+=2)); continue; }
                [[ "$_ch" == '"' ]] && _in_dq=0
            elif [[ "$_ch" == "'" ]]; then
                _in_sq=1
            elif [[ "$_ch" == '"' ]]; then
                _in_dq=1
            elif [[ "$_ch" == '{' || "$_ch" == '[' ]]; then
                ((_depth++))
            elif [[ "$_ch" == '}' || "$_ch" == ']' ]]; then
                ((_depth--))
            elif [[ "$_ch" == ',' && _depth -eq 0 ]] || (( _i == _len )); then
                _item="${_inner:_start:_i-_start}"
                _item="${_item#"${_item%%[![:space:]]*}"}"
                _item="${_item%"${_item##*[![:space:]]}"}"
                # Strip anchor markers inside flow sequences
                if [[ "$_item" =~ \&([a-zA-Z0-9_]+) ]]; then
                    _item="${_item//\&${BASH_REMATCH[1]} /}"
                    _item="${_item//\&${BASH_REMATCH[1]}/}"
                fi
                if [[ -n "$_item" ]]; then
                    if [[ "$_item" =~ ^\{ ]] || [[ "$_item" =~ ^\[ ]]; then
                        (( _first )) && _first=0 || _result+=","
                        _result+="$(_yaml_inline_flow "$_item")"
                    else
                        _item="$(_yaml_unquote "$_item")"
                        (( _first )) && _first=0 || _result+=","
                        _result+="$(_yaml_scalar_to_json "$_item")"
                    fi
                fi
                _start=$(( _i + 1 ))
            fi
            ((_i++))
        done
        echo "${_result}]"
        return
    fi

    echo "$_expr"
}

# ============================================================================
# yaml::get <yaml> <path>
# ============================================================================
yaml::get() {
    declare -f 'json::get' &>/dev/null || {
        echo "yaml::get: json extension required — source ext/json/json.sh first" >&2
        return 1
    }
    local _json
    _json="$(yaml::to_json "$1")" || return 1
    json::get "$_json" "$2"
}

# ============================================================================
# yaml::get_file <file> <path>
# ============================================================================
yaml::get_file() {
    local _yaml
    _yaml="$(< "$1")" || {
        echo "yaml::get_file: cannot read '$1'" >&2
        return 1
    }
    yaml::get "$_yaml" "$2"
}

# ============================================================================
# yaml::keys <yaml> [path]
#
# List keys (object) or indices (array) from a YAML container.  Converts to
# JSON internally then delegates to json::keys — the JSON extension must be
# sourced first.  Named identically to json::keys for drop-in substitution.
# ============================================================================
yaml::keys() {
    declare -f 'json::keys' &>/dev/null || {
        echo "yaml::keys: json extension required — source ext/json/json.sh first" >&2
        return 1
    }
    local _json
    _json="$(yaml::to_json "$1")" || return 1
    json::keys "$_json" "${2:-}"
}
