# ext/json.sh — Pure Bash JSON parser
#
# Dependencies:
#   core: runtime string

# --- guard ---
declare -f 'runtime::bash_version' &>/dev/null || {
    echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
    return 1
}

_guard_core_deps=(string::is_integer string::split::fast)
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
_json_buf=""        # original string (for raw-span extraction)
_json_pos=0
_json_len=0
_json_use_array=0    # set after _json::_index builds the char array
_json_chars=()       # indexed char array for O(1) access on large strings

# Populate _json_chars from _json_buf.  Idempotent — call freely.
# Checks array length matches buffer length to guard against stale
# state inherited from a parent shell that indexed a different JSON.
_json::_index() {
    if (( _json_use_array && ${#_json_chars[@]} == _json_len )); then
        return 0
    fi
    _json_use_array=0
    _json_chars=()
    if (( _json_len == 0 )); then
        _json_chars=()
    else
        local _ch
        while IFS= read -r -N 1 _ch; do _json_chars+=("$_ch"); done <<< "$_json_buf"
        # <<< adds a trailing newline — drop the extra element
        unset '_json_chars[-1]'
    fi
    _json_use_array=1
}

# Index only if the container at _json_pos doesn't close within 64 bytes.
# Small objects/arrays (config, API responses) skip the 21s indexing cost.
_json::_maybe_index() {
    if (( _json_use_array && ${#_json_chars[@]} == _json_len )); then
        return 0
    fi
    _json_use_array=0
    local _opener="${_json_buf:_json_pos:1}"
    local _closer="${_JSON_CLOSER[$_opener]}"
    local _scan=$(( _json_pos + 1 )) _depth=1 _c
    while (( _scan < _json_len && _scan < _json_pos + 64 && _depth > 0 )); do
        _c="${_json_buf:_scan:1}"
        case "$_c" in
            "$_opener") ((_depth++)) ;;
            "$_closer") ((_depth--)) ;;
            '"')  # skip string to avoid false closer match
                ((_scan++))
                while (( _scan < _json_len )); do
                    _c="${_json_buf:_scan:1}"
                    ((_scan++))
                    [[ "$_c" == '\' ]] && { ((_scan++)); continue; }
                    [[ "$_c" == '"' ]] && break
                done
                continue ;;
        esac
        ((_scan++))
    done
    (( _depth == 0 )) && return 0  # closed within 64 bytes — too small, skip
    _json::_index
}

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

# Advance _json_pos past a JSON number (starts at first digit or '-').
_json::_scan_number() {
    if (( _json_use_array )); then
        local ch
        while (( _json_pos < _json_len )); do
            ch="${_json_chars[_json_pos]}"
            [[ "$ch" == [-+0-9.eE] ]] || break
            ((_json_pos++))
        done
        return
    fi
    local ch
    while (( _json_pos < _json_len )); do
        ch="${_json_buf:_json_pos:1}"
        [[ "$ch" == [-+0-9.eE] ]] || break
        ((_json_pos++))
    done
}

_json::_skip_ws() {
    if (( _json_use_array )); then
        local ch
        while (( _json_pos < _json_len )); do
            ch="${_json_chars[_json_pos]}"
            [[ "$ch" == [[:space:]] ]] || return 0
            ((_json_pos++))
        done
        return
    fi
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
    if (( _json_use_array )); then
        ((_json_pos++))
        local ch
        while (( _json_pos < _json_len )); do
            ch="${_json_chars[_json_pos]}"
            ((_json_pos++))
            if [[ "$ch" == '\' ]]; then
                ((_json_pos++))
            elif [[ "$ch" == '"' ]]; then
                return 0
            fi
        done
        return 2
    fi
    ((_json_pos++))
    local ch
    while (( _json_pos < _json_len )); do
        ch="${_json_buf:_json_pos:1}"
        ((_json_pos++))
        if [[ "$ch" == '\' ]]; then
            ((_json_pos++))
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
    _out=""
    if (( _json_use_array )); then
        local ch hex
        ((_json_pos++))
        while (( _json_pos < _json_len )); do
            ch="${_json_chars[_json_pos]}"
            ((_json_pos++))
            case "$ch" in
                '"') return 0 ;;
                '\')
                    ch="${_json_chars[_json_pos]}"
                    ((_json_pos++))
                    case "$ch" in
                        '"'|'\'|'/') _out+="$ch" ;;
                        'b') _out+=$'\b' ;;
                        'f') _out+=$'\f' ;;
                        'n') _out+=$'\n' ;;
                        'r') _out+=$'\r' ;;
                        't') _out+=$'\t' ;;
                        'u')
                            hex="${_json_chars[_json_pos]}${_json_chars[_json_pos+1]}${_json_chars[_json_pos+2]}${_json_chars[_json_pos+3]}"
                            ((_json_pos += 4))
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
    fi
    local ch hex
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
    local ch
    ch="${_json_buf:_json_pos:1}"
    case "$ch" in
        '{'|'[')
            # Quick-scan: if container doesn't close within 64 bytes, use grep
            local _qs_closer="${_JSON_CLOSER[$ch]}" _qs_scan=$(( _json_pos + 1 )) _qs_depth=1 _qs_c
            while (( _qs_scan < _json_len && _qs_scan < _json_pos + 64 && _qs_depth > 0 )); do
                _qs_c="${_json_buf:_qs_scan:1}"
                case "$_qs_c" in
                    "$ch") ((_qs_depth++)) ;;
                    "$_qs_closer") ((_qs_depth--)) ;;
                    '"')
                        ((_qs_scan++))
                        while (( _qs_scan < _json_len )); do
                            _qs_c="${_json_buf:_qs_scan:1}"
                            ((_qs_scan++))
                            [[ "$_qs_c" == '\' ]] && { ((_qs_scan++)); continue; }
                            [[ "$_qs_c" == '"' ]] && break
                        done
                        continue ;;
                esac
                ((_qs_scan++))
            done
            if (( _qs_depth > 0 )); then
                _json::_grep_skip_container
                return
            fi
            # Small container — index and use bash walker
            _json::_maybe_index
            local _arr=$_json_use_array _closer="${_JSON_CLOSER[$ch]}"
            local -a _stack=("$_closer")
            ((_json_pos++))
            while (( ${#_stack[@]} > 0 && _json_pos < _json_len )); do
                if (( _arr )); then ch="${_json_chars[_json_pos]}"; else ch="${_json_buf:_json_pos:1}"; fi
                case "$ch" in
                    '{'|'[') _stack+=("${_JSON_CLOSER[$ch]}"); ((_json_pos++)) ;;
                    '}'|']')
                        [[ "$ch" == "${_stack[-1]}" ]] && unset '_stack[-1]'
                        ((_json_pos++))
                        ;;
                    '"') _json::_skip_string ;;
                    [tfn])
                        case "${_json_buf:_json_pos:4}" in
                            fals) ((_json_pos += 5)) ;;
                            true|null) ((_json_pos += 4)) ;;
                        esac
                        ;;
                    [-0-9]) _json::_scan_number ;;
                    *)
                        while (( _json_pos < _json_len )); do
                            if (( _arr )); then ch="${_json_chars[_json_pos]}"; else ch="${_json_buf:_json_pos:1}"; fi
                            [[ "$ch" == [[:space:]] || "$ch" == ',' || "$ch" == ':' ]] || break
                            ((_json_pos++))
                        done
                        ;;
                esac
            done
            ;;
        '"') _json::_skip_string ;;
        [tfn])
            case "${_json_buf:_json_pos:4}" in
                fals) ((_json_pos += 5)) ;;
                true|null) ((_json_pos += 4)) ;;
            esac
            ;;
        [-0-9]) _json::_scan_number ;;
    esac
}

# Walk past the value at the current position.  No subshell, no recursion.
# Skips strings, numbers, literals, and brace-matched containers inline.
_json::_walk_past() {
    _json::_skip_ws
    local ch
    ch="${_json_buf:_json_pos:1}"
    case "$ch" in
        '{'|'[')
            # Quick-scan: if container doesn't close within 64 bytes, use grep
            local _qs_closer="${_JSON_CLOSER[$ch]}" _qs_scan=$(( _json_pos + 1 )) _qs_depth=1 _qs_c
            while (( _qs_scan < _json_len && _qs_scan < _json_pos + 64 && _qs_depth > 0 )); do
                _qs_c="${_json_buf:_qs_scan:1}"
                case "$_qs_c" in
                    "$ch") ((_qs_depth++)) ;;
                    "$_qs_closer") ((_qs_depth--)) ;;
                    '"')
                        ((_qs_scan++))
                        while (( _qs_scan < _json_len )); do
                            _qs_c="${_json_buf:_qs_scan:1}"
                            ((_qs_scan++))
                            [[ "$_qs_c" == '\' ]] && { ((_qs_scan++)); continue; }
                            [[ "$_qs_c" == '"' ]] && break
                        done
                        continue ;;
                esac
                ((_qs_scan++))
            done
            if (( _qs_depth > 0 )); then
                _json::_grep_skip_container
                return
            fi
            # Small container — index and use bash walker
            _json::_maybe_index
            local _arr=$_json_use_array _closer="${_JSON_CLOSER[$ch]}"
            local -a _st=("$_closer")
            ((_json_pos++))
            while (( ${#_st[@]} > 0 && _json_pos < _json_len )); do
                if (( _arr )); then ch="${_json_chars[_json_pos]}"; else ch="${_json_buf:_json_pos:1}"; fi
                case "$ch" in
                    '{'|'[') _st+=("${_JSON_CLOSER[$ch]}"); ((_json_pos++)) ;;
                    '}'|']')
                        [[ "$ch" == "${_st[-1]}" ]] && unset '_st[-1]'
                        ((_json_pos++))
                        ;;
                    '"') _json::_skip_string ;;
                    [-0-9]) _json::_scan_number ;;
                    [tfn])
                        case "${_json_buf:_json_pos:4}" in
                            fals) ((_json_pos += 5)) ;;
                            true|null) ((_json_pos += 4)) ;;
                        esac
                        ;;
                    *)
                        while (( _json_pos < _json_len )); do
                            if (( _arr )); then ch="${_json_chars[_json_pos]}"; else ch="${_json_buf:_json_pos:1}"; fi
                            [[ "$ch" == [[:space:]] || "$ch" == ',' || "$ch" == ':' ]] || break
                            ((_json_pos++))
                        done
                        ;;
                esac
            done
            ;;
        '"') _json::_skip_string ;;
        [-0-9]) _json::_scan_number ;;
        [tfn])
            case "${_json_buf:_json_pos:4}" in
                fals) ((_json_pos += 5)) ;;
                true|null) ((_json_pos += 4)) ;;
            esac
            ;;
    esac
}

# Find the value for a given object key.
# Assumes _json_pos is at the opening '{'.
# On success, leaves _json_pos at the start of the matched value.
_json::_find_key() {
    local target="$1" cur_key
    ((_json_pos++))  # opening brace
    _json::_skip_ws
    [[ "${_json_buf:_json_pos:1}" == '}' ]] && { ((_json_pos++)); return 1; }
    while (( _json_pos < _json_len )); do
        _json::_read_string cur_key
        _json::_skip_ws
        ((_json_pos++))  # colon
        if [[ "$cur_key" == "$target" ]]; then
            return 0
        fi
        _json::_walk_past       # skip value inline
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == ',' ]] && ((_json_pos++))
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == '}' ]] && { ((_json_pos++)); return 1; }
    done
    return 1
}

# Find the nth element in an array.  Walks the array in a single pass,
# skipping elements inline — no per-element function call overhead.
# Assumes _json_pos is at the opening '['.
# On success, leaves _json_pos at the start of the matched element.
_json::_find_index() {
    local target="$1" i=0 ch
    ((_json_pos++))  # opening bracket
    _json::_skip_ws
    [[ "${_json_buf:_json_pos:1}" == ']' ]] && { ((_json_pos++)); return 1; }
    while (( _json_pos < _json_len )); do
        _json::_skip_ws
        if (( i == target )); then
            return 0
        fi
        _json::_walk_past
        ((i++))
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == ',' ]] && ((_json_pos++))
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == ']' ]] && { ((_json_pos++)); return 1; }
    done
    return 1
}

# Read the raw text span of a complete JSON value.
# On return, _json_raw_start and _json_raw_end bracket the value (inclusive:end).
_json::_read_raw_span() {
    _json::_skip_ws
    _json_raw_start=$_json_pos
    local ch closer
    ch="${_json_buf:_json_pos:1}"
    case "$ch" in '{'|'[') _json::_maybe_index ;; esac
    local _arr=$_json_use_array
    if (( _arr )); then ch="${_json_chars[_json_pos]}"; fi
    case "$ch" in
        '{'|'[')
            closer="${_JSON_CLOSER[$ch]}"
            local -a _stack=("$closer")
            ((_json_pos++))
            while (( ${#_stack[@]} > 0 && _json_pos < _json_len )); do
                if (( _arr )); then ch="${_json_chars[_json_pos]}"; else ch="${_json_buf:_json_pos:1}"; fi
                case "$ch" in
                    '{'|'[') _stack+=("${_JSON_CLOSER[$ch]}"); ((_json_pos++)) ;;
                    '}'|']')
                        [[ "$ch" == "${_stack[-1]}" ]] && unset '_stack[-1]'
                        ((_json_pos++))
                        ;;
                    '"') _json::_skip_string ;;
                    [tfn])
                        case "${_json_buf:_json_pos:4}" in
                            fals) ((_json_pos += 5)) ;;
                            true|null) ((_json_pos += 4)) ;;
                        esac
                        ;;
                    [-0-9]) _json::_scan_number ;;
                    *)  # batch-advance past whitespace/commas/colons
                        while (( _json_pos < _json_len )); do
                            if (( _arr )); then ch="${_json_chars[_json_pos]}"; else ch="${_json_buf:_json_pos:1}"; fi
                            [[ "$ch" == [[:space:]] || "$ch" == ',' || "$ch" == ':' ]] || break
                            ((_json_pos++))
                        done
                        ;;
                esac
            done
            _json_raw_end=$(( _json_pos - 1 ))
            ;;
        '"')
            _json::_skip_string
            ;;  # _json_raw_end set below
        [tfn])
            case "${_json_buf:_json_pos:4}" in
                fals) ((_json_pos += 5)) ;;
                true|null) ((_json_pos += 4)) ;;
            esac
            ;;
        [-0-9]) _json::_scan_number ;;
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
    local LC_ALL=C
    local json="$1" path="$2"
    _json_buf="$json"
    _json_len="${#_json_buf}"
    _json_pos=0

    if [[ -z "$path" ]]; then
        _json::_read_value
        return
    fi

    path="$(_json::_normalise_path "$path")"
    local segments segment
    string::split::fast segments '.' "$path"

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
    local LC_ALL=C
    local json="$1" path="${2:-}"
    _json_buf="$json"
    _json_len="${#_json_buf}"
    _json_pos=0

    local segments segment i

    if [[ -n "$path" ]]; then
        path="$(_json::_normalise_path "$path")"
        string::split::fast segments '.' "$path"

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
    local _opener="${_json_buf:_json_pos:1}"

    # Quick-scan: if container closes within 64 bytes, use bash walker.
    # Otherwise delegate to grep for C-speed structure walking.
    local _closer="${_JSON_CLOSER[$_opener]}"
    local _scan=$(( _json_pos + 1 )) _depth=1 _c _small=0
    while (( _scan < _json_len && _scan < _json_pos + 64 && _depth > 0 )); do
        _c="${_json_buf:_scan:1}"
        case "$_c" in
            "$_opener") ((_depth++)) ;;
            "$_closer") ((_depth--)) ;;
            '"')
                ((_scan++))
                while (( _scan < _json_len )); do
                    _c="${_json_buf:_scan:1}"
                    ((_scan++))
                    [[ "$_c" == '\' ]] && { ((_scan++)); continue; }
                    [[ "$_c" == '"' ]] && break
                done
                continue ;;
        esac
        ((_scan++))
    done
    (( _depth == 0 )) && _small=1

    if (( _small )); then
        case "$_opener" in
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
        esac
    else
        case "$_opener" in
            '{'|'[') _json::_grep_keys "$_opener" ;;
            *) echo "json::keys: value at path is not a container" >&2; return 1 ;;
        esac
    fi
}

# Return the JSON type of the value at a given path.
# Usage: json::type <json_string> <path>
#
# Output: object | array | string | number | boolean | null
json::type() {
    local LC_ALL=C
    local json="$1" path="$2"
    _json_buf="$json"
    _json_len="${#_json_buf}"
    _json_pos=0

    local segments segment i

    if [[ -n "$path" ]]; then
        path="$(_json::_normalise_path "$path")"
        string::split::fast segments '.' "$path"

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
# Uses grep -ob on large containers for C-speed counting (see _grep_len).
json::len() {
    local LC_ALL=C
    local json="$1" path="${2:-}"
    _json_buf="$json"
    _json_len="${#_json_buf}"
    _json_pos=0

    local segments segment i

    if [[ -n "$path" ]]; then
        path="$(_json::_normalise_path "$path")"
        string::split::fast segments '.' "$path"

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

    # Quick-scan: if container closes within 64 bytes, use bash walker.
    # Otherwise delegate to grep for C-speed structure walking.
    local _opener="$container"
    local _closer="${_JSON_CLOSER[$_opener]}"
    local _scan=$(( _json_pos + 1 )) _depth=1 _c _small=0
    while (( _scan < _json_len && _scan < _json_pos + 64 && _depth > 0 )); do
        _c="${_json_buf:_scan:1}"
        case "$_c" in
            "$_opener") ((_depth++)) ;;
            "$_closer") ((_depth--)) ;;
            '"')
                ((_scan++))
                while (( _scan < _json_len )); do
                    _c="${_json_buf:_scan:1}"
                    ((_scan++))
                    [[ "$_c" == '\' ]] && { ((_scan++)); continue; }
                    [[ "$_c" == '"' ]] && break
                done
                continue ;;
        esac
        ((_scan++))
    done
    (( _depth == 0 )) && _small=1

    if (( _small )); then
        # Small container — bash walker is fine
        local count=0
        case "$container" in
            '{')
                ((_json_pos++))
                _json::_skip_ws
                [[ "${_json_buf:_json_pos:1}" == '}' ]] && { ((_json_pos++)); echo 0; return 0; }
                while true; do
                    _json::_skip_string; _json::_skip_ws
                    ((_json_pos++))
                    _json::_skip_value; ((count++))
                    _json::_skip_ws
                    [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
                    [[ "${_json_buf:_json_pos:1}" == '}' ]] && { ((_json_pos++)); break; }
                done
                echo "$count"
                ;;
            '[')
                ((_json_pos++))
                _json::_skip_ws
                [[ "${_json_buf:_json_pos:1}" == ']' ]] && { ((_json_pos++)); echo 0; return 0; }
                while true; do
                    _json::_skip_value; ((count++))
                    _json::_skip_ws
                    [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
                    [[ "${_json_buf:_json_pos:1}" == ']' ]] && { ((_json_pos++)); break; }
                done
                echo "$count"
                ;;
        esac
    else
        # Large container — use grep for C-speed structure walking
        case "$container" in
            '{'|'[') _json::_grep_len "$container" ;;
            *) echo "json::len: value at path is not a container" >&2; return 1 ;;
        esac
    fi
}

# Count elements of a large container using grep -ob.
# grep scans the container interior at C speed (~10 ms for 2.2 MB);
# bash only iterates over the ~10 % of chars that are structural.
_json::_grep_len() {
    local _opener="$1" _closer="${_JSON_CLOSER[$1]}"
    local _depth=0 _in_str=0 _count=0 _pos _chr

    while IFS=: read -r _pos _chr; do
        if (( _in_str )); then
            [[ "$_chr" == '"' ]] && _in_str=0
            continue
        fi
        case "$_chr" in
            '"') _in_str=1 ;;
            '{'|'[') ((_depth++)) ;;
            '}'|']')
                if (( _depth == 0 )); then
                    [[ "$_opener" == '[' ]] && echo "$(( _count + 1 ))" || echo "$_count"
                    return 0
                fi
                ((_depth--))
                ;;
            ',') (( _depth == 0 )) && [[ "$_opener" == '[' ]] && ((_count++)) ;;
            ':') (( _depth == 0 )) && [[ "$_opener" == '{' ]] && ((_count++)) ;;
        esac
    done < <(printf '%s' "${_json_buf:_json_pos}" | grep -ob '[][{}",:]')
}

# Skip past a large container at _json_pos using grep (C-speed structure scan).
# Advances _json_pos past the matching closer. Assumes _json_pos is at '{' or '['.
# Uses correct depth handling: skips the opener at byte 0, starts depth at 1,
# checks for depth==0 after decrementing.
_json::_grep_skip_container() {
    local _opener="${_json_buf:_json_pos:1}"
    local _closer="${_JSON_CLOSER[$_opener]}"
    local _depth=1 _in_str=0 _first=1 _pos _chr

    while IFS=: read -r _pos _chr; do
        if (( _first )); then _first=0; continue; fi  # skip opener at pos 0
        if (( _in_str )); then
            [[ "$_chr" == '"' ]] && _in_str=0
            continue
        fi
        case "$_chr" in
            '"') _in_str=1 ;;
            '{'|'[') ((_depth++)) ;;
            '}'|']')
                ((_depth--))
                if (( _depth == 0 )); then
                    _json_pos=$(( _json_pos + _pos + 1 ))
                    return 0
                fi
                ;;
        esac
    done < <(printf '%s' "${_json_buf:_json_pos}" | grep -ob '[][{}",:]')
    return 1
}

# Emit keys of a large container at _json_pos using grep for C-speed scanning.
# For objects: emits key names (one per line). For arrays: emits indices.
# Advances _json_pos past the container. Assumes _json_pos is at '{' or '['.
_json::_grep_keys() {
    local _opener="${_json_buf:_json_pos:1}"
    local _closer="${_JSON_CLOSER[$_opener]}"
    local _depth=1 _in_str=0 _first=1 _pos _chr _key_start=0 _abs _k _raw

    if [[ "$_opener" == '[' ]]; then
        local _idx=0
        while IFS=: read -r _pos _chr; do
            if (( _first )); then _first=0; continue; fi
            if (( _in_str )); then
                [[ "$_chr" == '"' ]] && _in_str=0
                continue
            fi
            case "$_chr" in
                '"') _in_str=1 ;;
                '{'|'[') ((_depth++)) ;;
                '}'|']')
                    ((_depth--))
                    if (( _depth == 0 )); then
                        printf '%d\n' "$_idx"
                        _json_pos=$(( _json_pos + _pos + 1 ))
                        return 0
                    fi
                    ;;
                ',')
                    if (( _depth == 1 )); then
                        printf '%d\n' "$_idx"
                        ((_idx++))
                    fi
                    ;;
            esac
        done < <(printf '%s' "${_json_buf:_json_pos}" | grep -ob '[][{}",:]')
        return 0
    fi

    # Objects: find depth-1 strings followed by ':' (keys)
    while IFS=: read -r _pos _chr; do
        if (( _first )); then _first=0; continue; fi
        if (( _in_str )); then
            if [[ "$_chr" == '"' ]]; then
                _in_str=0
                if (( _depth == 1 )) && (( _key_start > 0 )); then
                    _abs=$(( _json_pos + _pos ))
                    _raw="${_json_buf:_key_start:_abs - _key_start}"
                    _k=$((_abs + 1))
                    while (( _k < _json_len )) && [[ "${_json_buf:_k:1}" == [[:space:]] ]]; do
                        ((_k++))
                    done
                    if (( _k < _json_len )) && [[ "${_json_buf:_k:1}" == ':' ]]; then
                        printf '%s\n' "$_raw"
                    fi
                    _key_start=0
                fi
            fi
            continue
        fi
        case "$_chr" in
            '"')
                _in_str=1
                if (( _depth == 1 )); then
                    _key_start=$((_json_pos + _pos + 1))  # after the opening "
                fi
                ;;
            '{'|'[') ((_depth++)) ;;
            '}'|']')
                ((_depth--))
                if (( _depth == 0 )); then
                    _json_pos=$(( _json_pos + _pos + 1 ))
                    return 0
                fi
                ;;
        esac
    done < <(printf '%s' "${_json_buf:_json_pos}" | grep -ob '[][{}",:]')
}
