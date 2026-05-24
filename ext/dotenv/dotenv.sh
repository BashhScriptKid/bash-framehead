# shellcheck shell=bash
# ext/dotenv/dotenv.sh — Pure Bash dotenv parser
#
# Parses KEY=value files (.env).  Handles quoting, comments, blank lines,
# and optional `export` prefix.
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

# Parse one line: strip export prefix, inline comment, quotes, whitespace.
# Output: KEY=DECODED_VALUE (key and value separated by the first =)
_dotenv_parse_line() {
    local _line="$1" _key _val

    # Strip leading `export `
    _line="${_line#export }"
    _line="${_line#export$'\t'}"

    # Must contain =
    [[ "$_line" =~ = ]] || return 1

    _key="${_line%%=*}"
    _val="${_line#*=}"

    # Trim key whitespace
    _key="${_key#"${_key%%[![:space:]]*}"}"
    _key="${_key%"${_key##*[![:space:]]}"}"

    # Skip invalid keys (empty, or contain whitespace)
    [[ -n "$_key" && ! "$_key" =~ [[:space:]] ]] || return 1

    # Strip inline comment from value (respecting quotes)
    local _out="" _i=0 _ch _in_sq=0 _in_dq=0
    while (( _i < ${#_val} )); do
        _ch="${_val:_i:1}"
        if (( _in_sq )); then
            [[ "$_ch" == "'" ]] && _in_sq=0
            _out+="$_ch"
        elif (( _in_dq )); then
            [[ "$_ch" == '"' ]] && _in_dq=0
            _out+="$_ch"
        elif [[ "$_ch" == "'" ]]; then
            _in_sq=1; _out+="$_ch"
        elif [[ "$_ch" == '"' ]]; then
            _in_dq=1; _out+="$_ch"
        elif [[ "$_ch" == '#' ]]; then
            break
        else
            _out+="$_ch"
        fi
        ((_i++))
    done
    _val="$_out"

    # Trim value whitespace
    _val="${_val#"${_val%%[![:space:]]*}"}"
    _val="${_val%"${_val##*[![:space:]]}"}"

    # Strip one layer of matching quotes
    if [[ "$_val" =~ ^\".*\"$ && ${#_val} -ge 2 ]]; then
        _val="${_val:1:-1}"
        # Process escape sequences in double-quoted values
        local _esc="" _j=0 _c
        while (( _j < ${#_val} )); do
            _c="${_val:_j:1}"
            if [[ "$_c" == '\' ]] && (( _j + 1 < ${#_val} )); then
                case "${_val:_j+1:1}" in
                    n)  _esc+=$'\n'; ((_j+=2)); continue ;;
                    r)  _esc+=$'\r'; ((_j+=2)); continue ;;
                    t)  _esc+=$'\t'; ((_j+=2)); continue ;;
                    '\') _esc+='\'; ((_j+=2)); continue ;;
                    '"') _esc+='"'; ((_j+=2)); continue ;;
                    '$') _esc+='$'; ((_j+=2)); continue ;;
                    *)  _esc+="${_val:_j+1:1}"; ((_j+=2)); continue ;;
                esac
            fi
            _esc+="$_c"
            ((_j++))
        done
        _val="$_esc"
    elif [[ "$_val" =~ ^\'.*\'$ && ${#_val} -ge 2 ]]; then
        _val="${_val:1:-1}"
    fi

    echo "${_key}=${_val}"
}

# ============================================================================
# dotenv::get <env> <key>
# ============================================================================
dotenv::get() {
    local _env="$1" _target="$2" _line _kv _k _v

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*# ]] && continue

        _kv="$(_dotenv_parse_line "$_line")" || continue
        _k="${_kv%%=*}"
        _v="${_kv#*=}"

        [[ "$_k" == "$_target" ]] && { printf '%s' "$_v"; return 0; }
    done <<< "$_env"

    return 1
}

# ============================================================================
# dotenv::get_file <file> <key>
# ============================================================================
dotenv::get_file() {
    local _file="$1" _env
    _env="$(< "$_file")" || {
        echo "dotenv::get_file: cannot read '$_file'" >&2
        return 1
    }
    dotenv::get "$_env" "$2"
}

# ============================================================================
# dotenv::keys <env>
# ============================================================================
dotenv::keys() {
    local _env="$1" _line _kv _k

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*# ]] && continue

        _kv="$(_dotenv_parse_line "$_line")" || continue
        _k="${_kv%%=*}"
        echo "$_k"
    done <<< "$_env"
}

# ============================================================================
# dotenv::to_json <env>
# ============================================================================
dotenv::to_json() {
    local _env="$1" _line _kv _k _v _json="{" _first=1

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*# ]] && continue

        _kv="$(_dotenv_parse_line "$_line")" || continue
        _k="${_kv%%=*}"
        _v="${_kv#*=}"

        # JSON-encode the value
        local _escaped="" _i=0 _ch
        while (( _i < ${#_v} )); do
            _ch="${_v:_i:1}"
            case "$_ch" in
                '"')  _escaped+='\"' ;;
                '\')  _escaped+='\\' ;;
                $'\n') _escaped+='\n' ;;
                $'\r') _escaped+='\r' ;;
                $'\t') _escaped+='\t' ;;
                *)    _escaped+="$_ch" ;;
            esac
            ((_i++))
        done

        (( _first )) && _first=0 || _json+=","
        _json+="\"$_k\":\"$_escaped\""
    done <<< "$_env"

    echo "${_json}}"
}

# ============================================================================
# dotenv::load <file>
#
# Source a .env file into the current shell.  Parses each line and evals
# the KEY=VALUE pair.  Only keys matching [A-Za-z_][A-Za-z0-9_]* are loaded.
# ============================================================================
dotenv::load() {
    local _file="$1" _line _kv _k _v

    [[ -f "$_file" ]] || { echo "dotenv::load: '$_file' not found" >&2; return 1; }

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*# ]] && continue

        _kv="$(_dotenv_parse_line "$_line")" || continue
        _k="${_kv%%=*}"
        _v="${_kv#*=}"

        # Only load safe key names
        [[ "$_k" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue

        printf -v _exported '%q=%q' "$_k" "$_v"
        eval "export $_exported"
    done < "$_file"
}

# ============================================================================
# dotenv::load_assoc <file> <varname>
#
# Load a .env file into a named associative array.  Safer than dotenv::load
# because it doesn't pollute the global shell environment.
#
# Usage: dotenv::load_assoc .env my_config
#        echo "${my_config[HOST]}"  # → localhost
# ============================================================================
dotenv::load_assoc() {
    local _file="$1" _varname="$2"
    [[ -f "$_file" ]] || { echo "dotenv::load_assoc: '$_file' not found" >&2; return 1; }

    # Declare a global associative array with the given name
    declare -A -g "$_varname" 2>/dev/null || {
        echo "dotenv::load_assoc: cannot declare associative array '$_varname'" >&2
        return 1
    }

    local _line _kv _k _v _ref
    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*# ]] && continue

        _kv="$(_dotenv_parse_line "$_line")" || continue
        _k="${_kv%%=*}"
        _v="${_kv#*=}"

        # Safe indirect assignment via printf -v into the named array
        printf -v "${_varname}[${_k@Q}]" '%s' "$_v"
    done < "$_file"
}
