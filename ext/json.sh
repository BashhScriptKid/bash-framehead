# ext/json.sh — Pure Bash JSON parser
#
# Dependencies:
#   core: runtime string

# --- guard ---
declare -f 'runtime::bash_version' &>/dev/null || {
    echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
    return 1
}

_guard_core_deps=(string::trim string::is_integer string::split)
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
# Internal parser state
# ============================================================================
_json_buf=""
_json_pos=0
_json_len=0

# ============================================================================
# Internal helpers
# ============================================================================

# Run "$@" under set -e, restore errexit afterward.
# The &&/|| chain is load-bearing — || suppresses errexit for the left side,
# so a failing "$@" never triggers shell exit before we can restore.
_json::_with_errexit() {
    local _rc
    set -e
    "$@" && _rc=0 || _rc=$?
    set +e
    return $_rc
}

# Brace dictionary: opener → closer.  Used by the stack-based skip_value.
declare -A _JSON_CLOSER=(["{"]="}" ["["]="]")

_json::_skip_ws() {
    local ch
    while (( _json_pos < _json_len )); do
        ch="${_json_buf:_json_pos:1}"
        [[ "$ch" == [[:space:]] ]] || return 0
        ((_json_pos++))
    done
}

# Scan past a JSON string (assumes _json_pos is at the opening quote).
# Leaves _json_pos one past the closing quote.
_json::_skip_string() {
    ((_json_pos++))  # opening quote
    local ch
    while (( _json_pos < _json_len )); do
        ch="${_json_buf:_json_pos:1}"
        ((_json_pos++))
        if [[ "$ch" == '\' ]]; then
            ((_json_pos++))  # skip escaped char
        elif [[ "$ch" == '"' ]]; then
            return 0
        fi
    done
    return 2
}

# Decode a JSON string into the named variable.
# Assumes _json_pos is at the opening quote.
# Leaves _json_pos one past the closing quote.
# Usage: _json::_read_string varname   (writes decoded string to $varname)
_json::_read_string() {
    local -n _out="$1"
    local ch hex
    _out=""
    ((_json_pos++))  # opening quote
    while (( _json_pos < _json_len )); do
        ch="${_json_buf:_json_pos:1}"
        ((_json_pos++))
        case "$ch" in
            '"')
                return 0
                ;;
            '\')
                ch="${_json_buf:_json_pos:1}"
                ((_json_pos++))
                case "$ch" in
                    '"'|'\'|'/') _out+="$ch" ;;
                    'b') _out+=$'\b' ;;
                    'f') _out+=$'\f' ;;
                    'n') _out+=$'\n' ;;
                    'r') _out+=$'\r' ;;
                    't') _out+=$'\t' ;;
                    'u')
                        hex="${_json_buf:_json_pos:4}"
                        ((_json_pos += 4))
                        # shellcheck disable=SC2059
                        printf -v _json_uchr "\\u$hex" 2>/dev/null \
                            && _out+="$_json_uchr" \
                            || _out+="\\u$hex"
                        ;;
                    *) _out+="\\$ch" ;;
                esac
                ;;
            *) _out+="$ch" ;;
        esac
    done
    return 2
}

# Skip a complete JSON value of any type.
# Uses a stack (indexed array) to track nested braces — single linear pass,
# no recursion.  _JSON_CLOSER dict maps opener→closer for push/pop.
_json::_skip_value() {
    _json::_skip_ws
    local ch="${_json_buf:_json_pos:1}" closer
    case "$ch" in
        '{'|'[')
            closer="${_JSON_CLOSER[$ch]}"
            local -a _stack=("$closer")
            ((_json_pos++))
            while (( ${#_stack[@]} > 0 && _json_pos < _json_len )); do
                ch="${_json_buf:_json_pos:1}"
                case "$ch" in
                    '{'|'[') _stack+=("${_JSON_CLOSER[$ch]}"); ((_json_pos++)) ;;
                    '}'|']')
                        [[ "$ch" == "${_stack[-1]}" ]] && unset '_stack[-1]'
                        ((_json_pos++))
                        ;;
                    '"') _json::_skip_string ;;
                    *) ((_json_pos++)) ;;
                esac
            done
            ;;
        '"') _json::_skip_string ;;
        [0-9tfn\-])
            while (( _json_pos < _json_len )); do
                ch="${_json_buf:_json_pos:1}"
                [[ "$ch" == [-+0-9.eEiItrufalsn] ]] || break
                ((_json_pos++))
            done
            ;;
    esac
}

# Find the value for a given object key.
# Assumes _json_pos is at the opening '{'.
# On success, leaves _json_pos at the start of the matched value and returns 0.
# On failure (key not found), returns 1.
_json::_find_key() {
    local target="$1" cur_key
    ((_json_pos++))  # opening brace
    _json::_skip_ws
    [[ "${_json_buf:_json_pos:1}" == '}' ]] && { ((_json_pos++)); return 1; }
    while (( _json_pos < _json_len )); do
        _json::_with_errexit _json::_read_string cur_key
        _json::_skip_ws
        ((_json_pos++))  # colon
        if [[ "$cur_key" == "$target" ]]; then
            return 0
        fi
        _json::_with_errexit _json::_skip_value
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == ',' ]] && ((_json_pos++))
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == '}' ]] && { ((_json_pos++)); return 1; }
    done
    return 1
}

# Find the nth element in an array.
# Assumes _json_pos is at the opening '['.
# On success, leaves _json_pos at the start of the matched element and returns 0.
# On failure (index out of bounds), returns 1.
_json::_find_index() {
    local target="$1" i=0
    ((_json_pos++))  # opening bracket
    _json::_skip_ws
    [[ "${_json_buf:_json_pos:1}" == ']' ]] && { ((_json_pos++)); return 1; }
    while (( _json_pos < _json_len )); do
        if (( i == target )); then
            return 0
        fi
        _json::_with_errexit _json::_skip_value
        ((i++))
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
        [[ "${_json_buf:_json_pos:1}" == ']' ]] && { ((_json_pos++)); return 1; }
    done
    return 1
}

# Read the raw text span of a complete JSON value.
# On return, _json_raw_start and _json_raw_end bracket the value (inclusive:end).
_json::_read_raw_span() {
    _json::_skip_ws
    _json_raw_start=$_json_pos
    local ch="${_json_buf:_json_pos:1}" closer
    case "$ch" in
        '{'|'[')
            closer="${_JSON_CLOSER[$ch]}"
            local -a _stack=("$closer")
            ((_json_pos++))
            while (( ${#_stack[@]} > 0 && _json_pos < _json_len )); do
                ch="${_json_buf:_json_pos:1}"
                case "$ch" in
                    '{'|'[') _stack+=("${_JSON_CLOSER[$ch]}"); ((_json_pos++)) ;;
                    '}'|']')
                        [[ "$ch" == "${_stack[-1]}" ]] && unset '_stack[-1]'
                        ((_json_pos++))
                        ;;
                    '"') _json::_skip_string ;;
                    *) ((_json_pos++)) ;;
                esac
            done
            _json_raw_end=$(( _json_pos - 1 ))
            ;;
        '"')
            _json::_skip_string
            ;;  # _json_raw_end set below
        [0-9tfn\-])
            while (( _json_pos < _json_len )); do
                ch="${_json_buf:_json_pos:1}"
                [[ "$ch" == [-+0-9.eEiItrufalsn] ]] || break
                ((_json_pos++))
            done
            ;;
    esac
    _json_raw_end=$(( _json_pos - 1 ))
}

# Read a decoded value at the current position to stdout.
# Objects and arrays are returned as raw JSON; strings are decoded.
_json::_read_value() {
    _json::_skip_ws
    local ch="${_json_buf:_json_pos:1}"
    case "$ch" in
        '{' | '[')
            _json::_read_raw_span
            printf '%s' "${_json_buf:_json_raw_start:$(( _json_raw_end - _json_raw_start + 1 ))}"
            ;;
        '"') _json::_read_string _json_val; printf '%s' "$_json_val" ;;
        [0-9tfn\-])
            _json::_read_raw_span
            printf '%s' "${_json_buf:_json_raw_start:$(( _json_raw_end - _json_raw_start + 1 ))}"
            ;;
    esac
}

# ============================================================================
# Path parsing
# ============================================================================

# Normalise bracket notation in a path: foo[0].bar → foo.0.bar
_json::_normalise_path() {
    local path="$1"
    # Replace [N] with .N, strip leading/trailing brackets, collapse ..
    path="${path//\[/.}"
    path="${path//\]/}"
    path="${path#.}"
    printf '%s' "$path"
}

# ============================================================================
# Public API
# ============================================================================

# Extract a value from a JSON string by dot-notation path.
# Usage: json::get <json_string> <path>
#
# Path segments separated by '.' navigate objects (by key) and arrays (by
# numeric index).  Bracket notation 'foo[0].bar' is normalised to the
# equivalent 'foo.0.bar'.  An empty path returns the entire input.
#
# Output: decoded value (strings unescaped, everything else raw JSON).
json::get() {
    local json="$1" path="$2"
    json="$(string::trim <<< "$json")"
    _json_buf="$json"
    _json_len="${#_json_buf}"
    _json_pos=0

    if [[ -z "$path" ]]; then
        _json::_read_value
        return
    fi

    path="$(_json::_normalise_path "$path")"
    local segments segment
    readarray -t segments <<< "$(string::split '.' <<< "$path")"

    local last_idx=$((${#segments[@]} - 1))
    local i
    for (( i = 0; i < ${#segments[@]}; i++ )); do
        segment="${segments[$i]}"
        _json::_skip_ws
        local type_ch="${_json_buf:_json_pos:1}"

        case "$type_ch" in
            '{')
                if ! _json::_find_key "$segment"; then
                    echo "json::get: key '$segment' not found" >&2
                    return 1
                fi
                # _find_key leaves _json_pos at the start of the value
                if (( i == last_idx )); then
                    _json::_read_value
                    return
                fi
                ;;
            '[')
                if ! string::is_integer "$segment"; then
                    echo "json::get: array index '$segment' must be an integer" >&2
                    return 1
                fi
                if ! _json::_find_index "$segment"; then
                    echo "json::get: index $segment out of bounds" >&2
                    return 1
                fi
                if (( i == last_idx )); then
                    _json::_read_value
                    return
                fi
                ;;
            *)
                echo "json::get: cannot navigate into scalar at '$segment' (path prefix: ${segments[*]:0:i})" >&2
                return 1
                ;;
        esac
    done

    # If we exit the loop without returning, something went wrong
    echo "json::get: path exhausted before reaching a value" >&2
    return 1
}

# Extract a value from a JSON file by dot-notation path.
# Usage: json::get_file <file> <path>
json::get_file() {
    local file="$1" path="$2"
    local json
    json="$(<"$file")" || { echo "json::get_file: cannot read '$file'" >&2; return 1; }
    json::get "$json" "$path"
}

# List keys (object) or indices (array) at a given path.
# Usage: json::keys <json_string> [path]
#
# If path is omitted or empty, lists top-level keys.
json::keys() {
    local json="$1" path="${2:-}"
    json="$(string::trim <<< "$json")"
    _json_buf="$json"
    _json_len="${#_json_buf}"
    _json_pos=0

    local segments segment i

    if [[ -n "$path" ]]; then
        path="$(_json::_normalise_path "$path")"
        readarray -t segments <<< "$(string::split '.' <<< "$path")"

        for (( i = 0; i < ${#segments[@]}; i++ )); do
            segment="${segments[$i]}"
            _json::_skip_ws
            local type_ch="${_json_buf:_json_pos:1}"
            case "$type_ch" in
                '{') _json::_find_key "$segment" || { echo "json::keys: key '$segment' not found" >&2; return 1; } ;;
                '[')
                    string::is_integer "$segment" || { echo "json::keys: array index '$segment' must be an integer" >&2; return 1; }
                    _json::_find_index "$segment" || { echo "json::keys: index $segment out of bounds" >&2; return 1; }
                    ;;
                *) echo "json::keys: cannot navigate into scalar at '$segment'" >&2; return 1 ;;
            esac
        done
    fi

    _json::_skip_ws
    local container="${_json_buf:_json_pos:1}"

    case "$container" in
        '{')
            ((_json_pos++))
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == '}' ]] && { ((_json_pos++)); return 0; }
            while true; do
                _json::_read_string _json_key
                printf '%s\n' "$_json_key"
                _json::_skip_ws
                ((_json_pos++))       # colon
                _json::_skip_value
                _json::_skip_ws
                [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
                [[ "${_json_buf:_json_pos:1}" == '}' ]] && { ((_json_pos++)); break; }
            done
            ;;
        '[')
            local idx=0
            ((_json_pos++))
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == ']' ]] && { ((_json_pos++)); return 0; }
            while true; do
                printf '%d\n' "$idx"
                ((idx++))
                _json::_skip_value
                _json::_skip_ws
                [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
                [[ "${_json_buf:_json_pos:1}" == ']' ]] && { ((_json_pos++)); break; }
            done
            ;;
        *) echo "json::keys: value at path is not a container" >&2; return 1 ;;
    esac
}

# Return the JSON type of the value at a given path.
# Usage: json::type <json_string> <path>
#
# Output: object | array | string | number | boolean | null
json::type() {
    local json="$1" path="$2"
    json="$(string::trim <<< "$json")"
    _json_buf="$json"
    _json_len="${#_json_buf}"
    _json_pos=0

    local segments segment i

    if [[ -n "$path" ]]; then
        path="$(_json::_normalise_path "$path")"
        readarray -t segments <<< "$(string::split '.' <<< "$path")"

        for (( i = 0; i < ${#segments[@]}; i++ )); do
            segment="${segments[$i]}"
            _json::_skip_ws
            case "${_json_buf:_json_pos:1}" in
                '{') _json::_find_key "$segment" || { echo "json::type: key '$segment' not found" >&2; return 1; } ;;
                '[')
                    string::is_integer "$segment" || { echo "json::type: array index '$segment' must be an integer" >&2; return 1; }
                    _json::_find_index "$segment" || { echo "json::type: index $segment out of bounds" >&2; return 1; }
                    ;;
                *) echo "json::type: cannot navigate into scalar at '$segment'" >&2; return 1 ;;
            esac
        done
    fi

    _json::_skip_ws
    case "${_json_buf:_json_pos:1}" in
        '{') echo "object" ;;
        '[') echo "array" ;;
        '"') echo "string" ;;
        [0-9\-]) echo "number" ;;
        t|f) echo "boolean" ;;
        n) echo "null" ;;
        *) echo "json::type: unknown type" >&2; return 1 ;;
    esac
}

# Return the number of entries at a given path.
# Usage: json::len <json_string> [path]
#
# For objects: number of keys.  For arrays: number of elements.
# Scalars: returns an error.
json::len() {
    local json="$1" path="${2:-}"
    json="$(string::trim <<< "$json")"
    _json_buf="$json"
    _json_len="${#_json_buf}"
    _json_pos=0

    local segments segment i

    if [[ -n "$path" ]]; then
        path="$(_json::_normalise_path "$path")"
        readarray -t segments <<< "$(string::split '.' <<< "$path")"

        for (( i = 0; i < ${#segments[@]}; i++ )); do
            segment="${segments[$i]}"
            _json::_skip_ws
            case "${_json_buf:_json_pos:1}" in
                '{') _json::_find_key "$segment" || { echo "json::len: key '$segment' not found" >&2; return 1; } ;;
                '[')
                    string::is_integer "$segment" || { echo "json::len: array index '$segment' must be an integer" >&2; return 1; }
                    _json::_find_index "$segment" || { echo "json::len: index $segment out of bounds" >&2; return 1; }
                    ;;
                *) echo "json::len: cannot navigate into scalar at '$segment'" >&2; return 1 ;;
            esac
        done
    fi

    _json::_skip_ws
    local container="${_json_buf:_json_pos:1}"
    local count=0

    case "$container" in
        '{')
            ((_json_pos++))
            _json::_skip_ws
            if [[ "${_json_buf:_json_pos:1}" == '}' ]]; then
                ((_json_pos++))
                echo 0
                return 0
            fi
            while true; do
                _json::_skip_string
                _json::_skip_ws
                ((_json_pos++))  # colon
                _json::_skip_value
                ((count++))
                _json::_skip_ws
                [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
                [[ "${_json_buf:_json_pos:1}" == '}' ]] && { ((_json_pos++)); break; }
            done
            echo "$count"
            ;;
        '[')
            ((_json_pos++))
            _json::_skip_ws
            if [[ "${_json_buf:_json_pos:1}" == ']' ]]; then
                ((_json_pos++))
                echo 0
                return 0
            fi
            while true; do
                _json::_skip_value
                ((count++))
                _json::_skip_ws
                [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
                [[ "${_json_buf:_json_pos:1}" == ']' ]] && { ((_json_pos++)); break; }
            done
            echo "$count"
            ;;
        *) echo "json::len: value at path is not a container" >&2; return 1 ;;
    esac
}
