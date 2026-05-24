# ext/ini/ini.sh — Pure Bash INI parser
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
# Internal: _ini_strip <value>
#
# Trim whitespace, remove inline comments, strip surrounding quotes.
# ============================================================================
_ini_strip() {
    local _v="$1"

    # Strip inline comment — find first unquoted ; or #
    local _out="" _i=0 _ch _in_sq=0 _in_dq=0
    while (( _i < ${#_v} )); do
        _ch="${_v:_i:1}"
        if (( _in_sq )); then
            [[ "$_ch" == "'" ]] && _in_sq=0
            _out+="$_ch"
        elif (( _in_dq )); then
            [[ "$_ch" == '"' ]] && _in_dq=0
            _out+="$_ch"
        elif [[ "$_ch" == "'" ]]; then
            _in_sq=1
            _out+="$_ch"
        elif [[ "$_ch" == '"' ]]; then
            _in_dq=1
            _out+="$_ch"
        elif [[ "$_ch" == ';' || "$_ch" == '#' ]]; then
            break
        else
            _out+="$_ch"
        fi
        ((_i++))
    done

    # Trim leading/trailing whitespace
    _v="${_out#"${_out%%[![:space:]]*}"}"
    _v="${_v%"${_v##*[![:space:]]}"}"

    # Strip one layer of surrounding quotes (matching)
    if [[ "$_v" =~ ^\".*\"$ && ${#_v} -ge 2 ]]; then
        _v="${_v:1:-1}"
    elif [[ "$_v" =~ ^\'.*\'$ && ${#_v} -ge 2 ]]; then
        _v="${_v:1:-1}"
    fi

    echo "$_v"
}

# ============================================================================
# Internal: _ini_normalise_section <name>
#
# Strip whitespace and optional brackets from a section name.
# "[ database ]" → "database"
# ============================================================================
_ini_normalise_section() {
    local _s="$1"
    _s="${_s#[}"   # strip leading [
    _s="${_s%]}"   # strip trailing ]
    _s="${_s#"${_s%%[![:space:]]*}"}"  # trim leading ws
    _s="${_s%"${_s##*[![:space:]]}"}"  # trim trailing ws
    echo "$_s"
}

# ============================================================================
# ini::get <ini> <key> [section]
#
# Return the value for <key>.  If <section> is given, search only that section;
# otherwise search the global scope (before the first [section]).
# ============================================================================
ini::get() {
    local _ini="$1" _key="$2" _section="${3:-}"
    local _in_target=0 _global_done=0
    local _line _k _v _sec_name

    # No section requested → only scan global scope (before any [section])
    [[ -z "$_section" ]] && _in_target=1

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"

        # Blank line
        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        # Comment line
        [[ "$_line" =~ ^[[:space:]]*[#\;] ]] && continue

        # Section header
        if [[ "$_line" =~ ^[[:space:]]*\[ ]]; then
            [[ -n "$_section" ]] || { _in_target=0; continue; }  # no section requested, stop
            _global_done=1
            _sec_name="$(_ini_normalise_section "$_line")"
            if [[ "$_sec_name" == "$_section" ]]; then
                _in_target=1
            else
                _in_target=0
            fi
            continue
        fi

        # Key-value pair
        if (( _in_target )) && [[ "$_line" =~ = ]]; then
            _k="${_line%%=*}"
            _v="${_line#*=}"
            _k="$(_ini_strip "$_k")"
            [[ "$_k" == "$_key" ]] && { _ini_strip "$_v"; return 0; }
        fi
    done <<< "$_ini"

    return 1
}

# ============================================================================
# ini::get_file <file> <key> [section]
# ============================================================================
ini::get_file() {
    local _file="$1" _ini
    _ini="$(< "$_file")" || {
        echo "ini::get_file: cannot read '$_file'" >&2
        return 1
    }
    ini::get "$_ini" "$2" "$3"
}

# ============================================================================
# ini::sections <ini>
#
# List all section names, one per line.
# ============================================================================
ini::sections() {
    local _ini="$1" _line
    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        [[ "$_line" =~ ^[[:space:]]*\[ ]] || continue
        _ini_normalise_section "$_line"
    done <<< "$_ini"
}

# ============================================================================
# ini::keys <ini> [section]
#
# List keys.  If <section> is given, list keys from that section; otherwise
# list keys from the global scope (before the first [section]).
# ============================================================================
ini::keys() {
    local _ini="$1" _section="${2:-}"
    local _in_target=0 _line _k

    [[ -n "$_section" ]] && _section="$(_ini_normalise_section "$_section")"
    [[ -z "$_section" ]] && _in_target=1

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*[#\;] ]] && continue

        if [[ "$_line" =~ ^[[:space:]]*\[ ]]; then
            [[ -n "$_section" ]] || { _in_target=0; continue; }
            local _sec_name
            _sec_name="$(_ini_normalise_section "$_line")"
            _in_target=$([[ "$_sec_name" == "$_section" ]] && echo 1 || echo 0)
            continue
        fi

        if (( _in_target )) && [[ "$_line" =~ = ]]; then
            _k="$(_ini_strip "${_line%%=*}")"
            echo "$_k"
        fi
    done <<< "$_ini"
}

# ============================================================================
# ini::to_json <ini>
#
# Convert INI to JSON.  Global keys become top-level entries; sections become
# nested objects.
# ============================================================================
ini::to_json() {
    local _ini="$1"
    local _line _section="__global__" _k _v _escaped
    local -A _data          # "section|key" → escaped JSON value
    local -a _sections=()   # section insertion order
    local -A _section_keys  # "section" → newline-separated key list (insertion order)

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$_line" =~ ^[[:space:]]*[#\;] ]] && continue

        if [[ "$_line" =~ ^[[:space:]]*\[ ]]; then
            _section="$(_ini_normalise_section "$_line")"
            # Track section insertion order
            if [[ -z "${_section_keys["$_section"]+set}" ]]; then
                _sections+=("$_section")
                _section_keys["$_section"]=""
            fi
            continue
        fi

        if [[ "$_line" =~ = ]]; then
            _k="$(_ini_strip "${_line%%=*}")"
            _v="$(_ini_strip "${_line#*=}")"

            # JSON-escape the value
            _escaped=""
            local _i=0 _ch
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

            _data["${_section}|${_k}"]="$_escaped"
            # Track key insertion order per section
            if [[ -n "${_section_keys["$_section"]}" ]]; then
                _section_keys["$_section"]+=$'\n'"$_k"
            else
                _section_keys["$_section"]="$_k"
            fi
        fi
    done <<< "$_ini"

    # --- Emit JSON ---
    local _json="{" _first_global=1 _s _key

    # Emit global keys
    if [[ -n "${_section_keys["__global__"]}" ]]; then
        while IFS= read -r _key; do
            (( _first_global )) && _first_global=0 || _json+=","
            _json+="\"$_key\":\"${_data["__global__|${_key}"]}\""
        done <<< "${_section_keys["__global__"]}"
    fi

    # Emit sections
    for _s in "${_sections[@]}"; do
        (( _first_global )) && _first_global=0 || _json+=","
        _json+="\"$_s\":{"
        local _first_key=1
        while IFS= read -r _key; do
            (( _first_key )) && _first_key=0 || _json+=","
            _json+="\"$_key\":\"${_data["${_s}|${_key}"]}\""
        done <<< "${_section_keys["$_s"]}"
        _json+="}"
    done

    _json+="}"
    echo "$_json"
}

# ============================================================================
# ini::set <ini> <key> <value> [section]
#
# Insert or update a key-value pair.  Returns the modified INI on stdout.
# If <section> is given and doesn't exist, it is appended at the end.
# ============================================================================
ini::set() {
    local _ini="$1" _key="$2" _val="$3" _section="${4:-}"
    local _in_target=0 _found=0 _out="" _line _k _v _sec_name
    local _after_target=0  # set when we've passed the target without finding key

    # No section → act on global scope (before first section header)
    [[ -z "$_section" ]] && _in_target=1

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        local _original="$_line"

        # Blank or comment — pass through
        if [[ "$_line" =~ ^[[:space:]]*$ || "$_line" =~ ^[[:space:]]*[#\;] ]]; then
            _out+="$_original"$'\n'
            continue
        fi

        # Section header
        if [[ "$_line" =~ ^[[:space:]]*\[ ]]; then
            if [[ -n "$_section" ]]; then
                if (( _in_target && ! _found )); then
                    # Left the target section without finding key — inject before this header
                    _out+="${_key} = ${_val}"$'\n'
                    _found=1
                fi
                _sec_name="$(_ini_normalise_section "$_line")"
                _in_target=$([[ "$_sec_name" == "$_section" ]] && echo 1 || echo 0)
            else
                # Global scope: hit first section — inject key before it if not found
                if (( _in_target && ! _found )); then
                    _out+="${_key} = ${_val}"$'\n'
                    _found=1
                fi
                _in_target=0
            fi
            _out+="$_original"$'\n'
            continue
        fi

        # Key-value pair
        if [[ "$_line" =~ = ]]; then
            _k="$(_ini_strip "${_line%%=*}")"
            if (( _in_target )) && [[ "$_k" == "$_key" ]]; then
                _out+="${_key} = ${_val}"$'\n'
                _found=1
                continue
            fi
        fi

        _out+="$_original"$'\n'
    done <<< "$_ini"

    # Key not found — inject at appropriate position
    if (( ! _found )); then
        _out="${_out%"${_out##*[!$'\n']}"}"  # strip trailing newlines
        if [[ -n "$_section" ]]; then
            if [[ -z "$_section" ]] || (( _in_target )); then
                # Inside target section at EOF — append directly
                _out+=$'\n'"${_key} = ${_val}"$'\n'
            else
                # Section not found at all — create it
                _out+=$'\n'"[$_section]"$'\n'"${_key} = ${_val}"$'\n'
            fi
        else
            _out+=$'\n'"${_key} = ${_val}"$'\n'
        fi
    fi

    printf '%s' "$_out"
}

# ============================================================================
# ini::remove <ini> <key> [section]
#
# Delete a key-value pair.  Returns the modified INI on stdout.
# ============================================================================
ini::remove() {
    local _ini="$1" _key="$2" _section="${3:-}"
    local _in_target=0 _found=0 _out="" _line _k

    [[ -z "$_section" ]] && _in_target=1

    while IFS= read -r _line; do
        _line="${_line%$'\r'}"
        local _original="$_line"

        [[ "$_line" =~ ^[[:space:]]*$ || "$_line" =~ ^[[:space:]]*[#\;] ]] && {
            _out+="$_original"$'\n'; continue; }

        if [[ "$_line" =~ ^[[:space:]]*\[ ]]; then
            [[ -n "$_section" ]] || { _in_target=0; _out+="$_original"$'\n'; continue; }
            local _sec_name
            _sec_name="$(_ini_normalise_section "$_line")"
            _in_target=$([[ "$_sec_name" == "$_section" ]] && echo 1 || echo 0)
            _out+="$_original"$'\n'
            continue
        fi

        if (( _in_target )) && [[ "$_line" =~ = ]]; then
            _k="$(_ini_strip "${_line%%=*}")"
            [[ "$_k" == "$_key" ]] && { _found=1; continue; }
        fi

        _out+="$_original"$'\n'
    done <<< "$_ini"

    (( _found )) || { echo "ini::remove: key '$_key' not found" >&2; return 1; }
    printf '%s' "$_out"
}
