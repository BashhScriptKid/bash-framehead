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

# Pure-Bash \uXXXX → UTF-8 encoder.  Takes 4 hex digits, echoes the UTF-8 bytes.
# Uses two-stage printf: first build the \xHH format string, then emit it.
_json::_decode_unicode() {
    local _hex="$1" _cp _fmt
    [[ "$_hex" =~ ^[0-9a-fA-F]{4}$ ]] || { printf '\\u%s' "$_hex"; return; }
    _cp=$(( 16#$_hex ))
    if (( _cp < 0x80 )); then
        printf -v _fmt "\\x%02x" "$_cp"
    elif (( _cp < 0x800 )); then
        printf -v _fmt "\\x%02x\\x%02x" "$(( 0xC0 | (_cp >> 6) ))" "$(( 0x80 | (_cp & 0x3F) ))"
    else
        printf -v _fmt "\\x%02x\\x%02x\\x%02x" \
            "$(( 0xE0 | (_cp >> 12) ))" \
            "$(( 0x80 | ((_cp >> 6) & 0x3F) ))" \
            "$(( 0x80 | (_cp & 0x3F) ))"
    fi
    printf "$_fmt"
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
                            _out+="$(_json::_decode_unicode "$hex")"
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
                        _out+="$(_json::_decode_unicode "$hex")"
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
        _json::_skip_value       # skip value inline
        _json::_skip_ws
        local _had_comma=0
        if [[ "${_json_buf:_json_pos:1}" == ',' ]]; then
            ((_json_pos++)); _had_comma=1
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == '}' ]] && { echo "json::get: trailing comma in object" >&2; return 1; }
        fi
        (( ! _had_comma )) && _json::_skip_ws
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
        _json::_skip_value
        ((i++))
        _json::_skip_ws
        local _had_comma=0
        if [[ "${_json_buf:_json_pos:1}" == ',' ]]; then
            ((_json_pos++)); _had_comma=1
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == ']' ]] && { echo "json::get: trailing comma in array" >&2; return 1; }
        fi
        (( ! _had_comma )) && _json::_skip_ws
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
                    [-0-9]) local _num_start=$_json_pos
                        _json::_scan_number
                        _json::_validate_number "${_json_buf:_num_start:$((_json_pos - _num_start))}" || return 1
                        ;;
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
        [-0-9]) local _num_start=$_json_pos
            _json::_scan_number
            _json::_validate_number "${_json_buf:_num_start:$((_json_pos - _num_start))}" || return 1
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
            _json::_read_raw_span || return 1
            printf '%s' "${_json_buf:_json_raw_start:$(( _json_raw_end - _json_raw_start + 1 ))}"
            ;;
        '"') _json::_read_string _json_val; printf '%s' "$_json_val" ;;
        [0-9\-])
            _json::_read_raw_span || return 1
            printf '%s' "${_json_buf:_json_raw_start:$(( _json_raw_end - _json_raw_start + 1 ))}"
            ;;
        t)  # true
            _json::_read_raw_span || return 1
            printf '%s' "${_json_buf:_json_raw_start:$(( _json_raw_end - _json_raw_start + 1 ))}"
            ;;
        f)  # false
            _json::_read_raw_span || return 1
            printf '%s' "${_json_buf:_json_raw_start:$(( _json_raw_end - _json_raw_start + 1 ))}"
            ;;
        n)  # null
            _json::_read_raw_span || return 1
            printf '%s' "${_json_buf:_json_raw_start:$(( _json_raw_end - _json_raw_start + 1 ))}"
            ;;
        *)  echo "json::get: unexpected character '${_json_buf:_json_pos:1}' at position $_json_pos" >&2
            return 1
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

# After reading a value: peek ahead for trailing comma (syntax error in JSON).
# Returns 0 if OK, 1 with stderr message if trailing comma detected.
_json::_check_trailing_comma() {
    local _saved=$_json_pos
    _json::_skip_ws
    if [[ "${_json_buf:_json_pos:1}" == ',' ]]; then
        ((_json_pos++))
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == [}\]] ]] && { echo "json::get: trailing comma" >&2; return 1; }
    fi
    _json_pos=$_saved
    return 0
}

# Validate a scanned number span against the JSON spec.
# Rejects: leading zeros (01), leading +, multiple dots, incomplete exponents,
# bare minus, and other malformed numeric patterns.
_json::_validate_number() {
    local _num="$1"
    [[ "$_num" =~ ^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] && return 0
    echo "json: invalid number '$_num'" >&2
    return 1
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
        _json::_read_value || return 1
        _json::_check_trailing_comma || return 1
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
                    _json::_read_value || return 1
                    _json::_check_trailing_comma || return 1
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
                    _json::_read_value || return 1
                    _json::_check_trailing_comma || return 1
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
    local _depth=0 _in_str=0 _count=0 _first=1 _pos _chr

    while IFS= read -r _gline; do
        _pos="${_gline%%:*}"; _chr="${_gline#*:}"
        if (( _first )); then _first=0; continue; fi  # skip opener
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
    local _depth=1 _in_str=0 _first=1 _pos _chr _gline

    while IFS= read -r _gline; do
        _pos="${_gline%%:*}"; _chr="${_gline#*:}"
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
    local _depth=1 _in_str=0 _first=1 _pos _chr _gline _key_start=0 _abs _k _raw

    if [[ "$_opener" == '[' ]]; then
        local _idx=0
        while IFS= read -r _gline; do
            _pos="${_gline%%:*}"; _chr="${_gline#*:}"
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
    while IFS= read -r _gline; do
        _pos="${_gline%%:*}"; _chr="${_gline#*:}"
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

# ============================================================================
# json::kv — Stateful container context (read + write)
# ============================================================================

# Context state
_json_kv_root=""
_json_kv_path=""
_json_kv_cstart=0
_json_kv_cend=0
_json_kv_ctype=""    # object | array

# Error guard: bail if no kv context is active.
_json::_kv_require() {
    [[ -n "$_json_kv_root" ]] && return 0
    echo "json::kv: no context — call json::kv <json> [path] first" >&2
    return 1
}

# Load kv context into the main parser state (_json_buf, _json_pos, _json_len)
# and navigate to the container.  Called by json::kv and ::at / ::parent / ::root.
_json::_kv_enter() {
    _json_buf="$_json_kv_root"
    _json_len="${#_json_buf}"
    _json_pos=0
    _json_use_array=0
    _json_chars=()

    if [[ -n "$_json_kv_path" ]]; then
        local norm_path segments segment i
        norm_path="$(_json::_normalise_path "$_json_kv_path")"
        string::split::fast segments '.' "$norm_path"

        for (( i = 0; i < ${#segments[@]}; i++ )); do
            segment="${segments[$i]}"
            _json::_skip_ws
            local type_ch="${_json_buf:_json_pos:1}"

            case "$type_ch" in
                '{')
                    _json::_find_key "$segment" || {
                        echo "json::kv: key '$segment' not found" >&2; return 1; }
                    ;;
                '[')
                    string::is_integer "$segment" || {
                        echo "json::kv: array index '$segment' must be an integer" >&2; return 1; }
                    _json::_find_index "$segment" || {
                        echo "json::kv: index $segment out of bounds" >&2; return 1; }
                    ;;
                *)
                    echo "json::kv: cannot navigate into scalar at '$segment'" >&2; return 1 ;;
            esac
        done
    fi

    # Set container start position and type
    _json::_skip_ws
    _json_kv_cstart=$_json_pos
    _json_kv_ctype="object"
    [[ "${_json_buf:_json_pos:1}" == '[' ]] && _json_kv_ctype="array"

    local _opener="${_json_buf:_json_pos:1}"
    [[ "$_opener" == '{' || "$_opener" == '[' ]] || return 1

    # Scan to find the matching close brace
    _json::_maybe_index
    if (( _json_use_array && ${#_json_chars[@]} == _json_len )); then
        local _d=0 _closer="${_JSON_CLOSER[$_opener]}" _c
        while (( _json_pos < _json_len )); do
            _c="${_json_chars[_json_pos]}"
            case "$_c" in
                '{'|'[') ((_d++)) ;;
                '}'|']')
                    if (( _d == 0 )); then _json_kv_cend=$_json_pos; return 0; fi
                    ((_d--))
                    ;;
                '"') _json::_skip_string; continue ;;
            esac
            ((_json_pos++))
        done
    else
        local _d=0 _closer="${_JSON_CLOSER[$_opener]}" _c
        ((_json_pos++))
        while (( _json_pos < _json_len )); do
            _c="${_json_buf:_json_pos:1}"
            case "$_c" in
                "$_opener") ((_d++)) ;;
                "$_closer")
                    if (( _d == 0 )); then _json_kv_cend=$_json_pos; return 0; fi
                    ((_d--))
                    ;;
                '"') _json::_skip_string; continue ;;
            esac
            ((_json_pos++))
        done
    fi
    return 1
}

# ============================================================================
# json::kv <json> [path] — initialise kv context
# ============================================================================
json::kv() {
    _json_kv_root="$1"
    _json_kv_path="${2:-}"
    _json_kv_cstart=0
    _json_kv_cend=0
    _json_kv_ctype=""

    _json::_kv_enter || { _json_kv_root=""; return 1; }

    if [[ "$_json_kv_ctype" != "object" && "$_json_kv_ctype" != "array" ]]; then
        echo "json::kv: path does not point to a container (object or array)" >&2
        _json_kv_root=""
        return 1
    fi
}

# ============================================================================
# ::keys — list keys (object) or indices (array), newline-separated
# ============================================================================
json::kv::keys() {
    _json::_kv_require || return 1
    _json::_kv_enter || return 1

    local _opener="${_json_buf:_json_kv_cstart:1}"
    _json_pos=$(( _json_kv_cstart + 1 ))

    if [[ "$_opener" == '{' ]]; then
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == '}' ]] && return 0
        while true; do
            local _key
            _json::_read_string _key
            printf '%s\n' "$_key"
            _json::_skip_ws
            ((_json_pos++))       # colon
            _json::_skip_value
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
            [[ "${_json_buf:_json_pos:1}" == '}' ]] && break
        done
    else
        local _idx=0
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == ']' ]] && return 0
        while true; do
            printf '%d\n' "$_idx"
            ((_idx++))
            _json::_skip_value
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
            [[ "${_json_buf:_json_pos:1}" == ']' ]] && break
        done
    fi
}

# ============================================================================
# ::keys::exists <key> — return 0 if key/index exists in container
# ============================================================================
json::kv::keys::exists() {
    _json::_kv_require || return 1
    [[ "$_json_kv_ctype" != "object" ]] && {
        echo "json::kv::keys::exists: container is not an object" >&2; return 1; }
    _json::_kv_enter || return 1
    _json_pos=$_json_kv_cstart
    _json::_find_key "$1"
}

# ============================================================================
# ::value::get <key> — decoded value from container
# ============================================================================
json::kv::value::get() {
    _json::_kv_require || return 1
    _json::_kv_enter || return 1
    _json_pos=$_json_kv_cstart
    if [[ "$_json_kv_ctype" == "object" ]]; then
        _json::_find_key "$1" || { echo "json::kv::value::get: key '$1' not found" >&2; return 1; }
    else
        string::is_integer "$1" || { echo "json::kv::value::get: array index '$1' must be an integer" >&2; return 1; }
        _json::_find_index "$1" || { echo "json::kv::value::get: index $1 out of bounds" >&2; return 1; }
    fi
    _json::_read_value
}

# ============================================================================
# ::value::type <key> — type of a value in the container
# ============================================================================
json::kv::value::type() {
    _json::_kv_require || return 1
    _json::_kv_enter || return 1
    _json_pos=$_json_kv_cstart
    if [[ "$_json_kv_ctype" == "object" ]]; then
        _json::_find_key "$1" || { echo "json::kv::value::type: key '$1' not found" >&2; return 1; }
    else
        string::is_integer "$1" || { echo "json::kv::value::type: array index '$1' must be an integer" >&2; return 1; }
        _json::_find_index "$1" || { echo "json::kv::value::type: index $1 out of bounds" >&2; return 1; }
    fi
    _json::_skip_ws
    case "${_json_buf:_json_pos:1}" in
        '{') echo "object" ;;
        '[') echo "array" ;;
        '"') echo "string" ;;
        [0-9\-]) echo "number" ;;
        t|f) echo "boolean" ;;
        n) echo "null" ;;
    esac
}

# ============================================================================
# ::list [format] — dump entries
#   (no arg) tab-separated key\tvalue
#   json     JSON object string
#   csv      CSV row (comma-separated values, keys as headers)
# ============================================================================
json::kv::list() {
    _json::_kv_require || return 1
    local _fmt="${1:-}"
    _json::_kv_enter || return 1

    local _opener="${_json_buf:_json_kv_cstart:1}"
    _json_pos=$(( _json_kv_cstart + 1 ))

    # --- json format: raw container slice ---
    if [[ "$_fmt" == "json" ]]; then
        printf '%s\n' "${_json_buf:_json_kv_cstart:$(( _json_kv_cend - _json_kv_cstart + 1 ))}"
        return
    fi

    # --- csv format: comma-separated values ---
    if [[ "$_fmt" == "csv" ]]; then
        local _first=1
        if [[ "$_opener" == '{' ]]; then
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == '}' ]] && { echo; return; }
            while true; do
                _json::_skip_string     # skip key
                _json::_skip_ws
                ((_json_pos++))          # colon
                _json::_read_raw_span    # value span
                ((_first)) && _first=0 || printf ','
                printf '%s' "${_json_buf:_json_raw_start:$((_json_raw_end - _json_raw_start + 1))}"
                _json_pos=$(( _json_raw_end + 1 ))
                _json::_skip_ws
                [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
                [[ "${_json_buf:_json_pos:1}" == '}' ]] && break
            done
        else
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == ']' ]] && { echo; return; }
            while true; do
                _json::_read_raw_span
                ((_first)) && _first=0 || printf ','
                printf '%s' "${_json_buf:_json_raw_start:$((_json_raw_end - _json_raw_start + 1))}"
                _json_pos=$(( _json_raw_end + 1 ))
                _json::_skip_ws
                [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
                [[ "${_json_buf:_json_pos:1}" == ']' ]] && break
            done
        fi
        echo
        return
    fi

    # --- Default: tab-separated key\tvalue\n ---
    if [[ "$_opener" == '{' ]]; then
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == '}' ]] && return
        while true; do
            local _key
            _json::_read_string _key
            _json::_skip_ws
            ((_json_pos++))       # colon
            printf '%s\t' "$_key"
            _json::_read_value
            echo
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
            [[ "${_json_buf:_json_pos:1}" == '}' ]] && break
        done
    else
        local _idx=0
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == ']' ]] && return
        while true; do
            printf '%d\t' "$_idx"
            ((_idx++))
            _json::_read_value
            echo
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
            [[ "${_json_buf:_json_pos:1}" == ']' ]] && break
        done
    fi
}

# ============================================================================
# ::count — number of entries in container
# ============================================================================
json::kv::count() {
    _json::_kv_require || return 1
    _json::_kv_enter || return 1
    _json_pos=$_json_kv_cstart
    json::len "$_json_kv_root" "$_json_kv_path"
}

# ============================================================================
# ::at <relpath> — navigate deeper from current container
# ============================================================================
json::kv::at() {
    _json::_kv_require || return 1
    local _rel="$1"
    [[ -n "$_json_kv_path" ]] && _json_kv_path+=".$_rel" || _json_kv_path="$_rel"
    _json::_kv_enter || { _json_kv_path="${_json_kv_path%.*}"; return 1; }
    [[ "$_json_kv_ctype" == "object" || "$_json_kv_ctype" == "array" ]] && return 0
    _json_kv_path="${_json_kv_path%.*}"
    echo "json::kv::at: '$_rel' does not point to a container" >&2
    return 1
}

# ============================================================================
# ::parent — navigate up one level
# ============================================================================
json::kv::parent() {
    _json::_kv_require || return 1
    [[ -z "$_json_kv_path" ]] && { echo "json::kv::parent: already at root" >&2; return 1; }
    _json_kv_path="${_json_kv_path%.*}"
    [[ "$_json_kv_path" == "$_json_kv_path" ]] && _json_kv_path=""  # no dot → root
    _json::_kv_enter || return 1
}

# ============================================================================
# ::root — return to document root
# ============================================================================
json::kv::root() {
    _json::_kv_require || return 1
    _json_kv_path=""
    _json::_kv_enter || return 1
}

# ============================================================================
# Write helpers
# ============================================================================

# Scan container entries, recording each as: key_start key_end val_start val_end
# (space-separated).  Objects: key span is the quoted key string.
# Arrays: key_start/key_end = index (for ordering, not byte positions).
_json::_kv_scan_entries() {
    local _opener="${_json_buf:_json_kv_cstart:1}"
    _json_entries=()
    _json_pos=$(( _json_kv_cstart + 1 ))

    if [[ "$_opener" == '{' ]]; then
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == '}' ]] && return
        while true; do
            local _ks=$_json_pos
            _json::_skip_string
            local _ke=$(( _json_pos - 1 ))
            _json::_skip_ws
            ((_json_pos++))  # colon
            local _vs=$_json_pos
            _json::_skip_value
            local _ve=$(( _json_pos - 1 ))
            _json_entries+=("$_ks $_ke $_vs $_ve")
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
            [[ "${_json_buf:_json_pos:1}" == '}' ]] && break
        done
    else
        _json::_skip_ws
        [[ "${_json_buf:_json_pos:1}" == ']' ]] && return
        local _idx=0
        while true; do
            local _vs=$_json_pos
            _json::_skip_value
            local _ve=$(( _json_pos - 1 ))
            _json_entries+=("$_idx $_idx $_vs $_ve")
            ((_idx++))
            _json::_skip_ws
            [[ "${_json_buf:_json_pos:1}" == ',' ]] && { ((_json_pos++)); _json::_skip_ws; }
            [[ "${_json_buf:_json_pos:1}" == ']' ]] && break
        done
    fi
}

# ============================================================================
# ::value::set <key> <raw_json> — insert or update a key-value pair
# ============================================================================
json::kv::value::set() {
    _json::_kv_require || return 1
    local _key="$1" _val="$2"
    _json::_kv_enter || return 1
    _json::_kv_scan_entries

    local _opener _closer _new _first _e _ks _ke _vs _ve _found_key
    _opener="${_json_buf:_json_kv_cstart:1}"
    _closer="${_JSON_CLOSER[$_opener]}"
    _new="$_opener"; _first=1; _found_key=0

    if [[ "$_opener" == '{' ]]; then
        for _e in "${_json_entries[@]}"; do
            read -r _ks _ke _vs _ve <<< "$_e"
            local _ek="${_json_buf:_ks:$(( _ke - _ks + 1 ))}"
            (( _first )) && _first=0 || _new+=","
            if [[ "${_ek:1:-1}" == "$_key" ]]; then
                _new+="\"$_key\":$_val"
                _found_key=1
            else
                _new+="${_json_buf:_ks:$(( _ke - _ks + 1 ))}:${_json_buf:_vs:$(( _ve - _vs + 1 ))}"
            fi
        done
        if (( ! _found_key )); then
            [[ ${#_json_entries[@]} -gt 0 ]] && _new+=","
            _new+="\"$_key\":$_val"
        fi
    else
        for _e in "${_json_entries[@]}"; do
            read -r _ks _ke _vs _ve <<< "$_e"
            (( _first )) && _first=0 || _new+=","
            _new+="${_json_buf:_vs:$(( _ve - _vs + 1 ))}"
        done
    fi
    _new+="$_closer"

    local _pre="${_json_kv_root:0:_json_kv_cstart}"
    local _post="${_json_kv_root:$(( _json_kv_cend + 1 ))}"
    _json_kv_root="$_pre$_new$_post"
    _json_kv_cend=$(( _json_kv_cstart + ${#_new} - 1 ))
    _json_buf="$_json_kv_root"
    _json_len="${#_json_buf}"
}

# ============================================================================
# ::keys::remove <key> — delete a key-value pair from an object
# ============================================================================
json::kv::keys::remove() {
    _json::_kv_require || return 1
    [[ "$_json_kv_ctype" != "object" ]] && {
        echo "json::kv::keys::remove: container is not an object" >&2; return 1; }
    _json::_kv_enter || return 1
    _json::_kv_scan_entries

    local _new="{" _first=1 _found=0 _e _ks _ke _vs _ve
    for _e in "${_json_entries[@]}"; do
        read -r _ks _ke _vs _ve <<< "$_e"
        local _ek="${_json_buf:_ks:$(( _ke - _ks + 1 ))}"
        if [[ "${_ek:1:-1}" == "$1" ]]; then
            _found=1
            continue
        fi
        (( _first )) && _first=0 || _new+=","
        _new+="${_json_buf:_ks:$(( _ke - _ks + 1 ))}:${_json_buf:_vs:$(( _ve - _vs + 1 ))}"
    done
    _new+="}"

    (( _found )) || { echo "json::kv::keys::remove: key '$1' not found" >&2; return 1; }

    local _pre="${_json_kv_root:0:_json_kv_cstart}"
    local _post="${_json_kv_root:$(( _json_kv_cend + 1 ))}"
    _json_kv_root="$_pre$_new$_post"
    _json_kv_cend=$(( _json_kv_cstart + ${#_new} - 1 ))
    _json_buf="$_json_kv_root"
    _json_len="${#_json_buf}"
}

# ============================================================================
# ::keys::rename <old> <new> — rename a key, preserving value
# ============================================================================
json::kv::keys::rename() {
    _json::_kv_require || return 1
    [[ "$_json_kv_ctype" != "object" ]] && {
        echo "json::kv::keys::rename: container is not an object" >&2; return 1; }
    _json::_kv_enter || return 1
    _json::_kv_scan_entries

    local _new="{" _first=1 _found=0 _e _ks _ke _vs _ve
    for _e in "${_json_entries[@]}"; do
        read -r _ks _ke _vs _ve <<< "$_e"
        local _ek="${_json_buf:_ks:$(( _ke - _ks + 1 ))}"
        (( _first )) && _first=0 || _new+=","
        if [[ "${_ek:1:-1}" == "$1" ]]; then
            _new+="\"$2\":${_json_buf:_vs:$(( _ve - _vs + 1 ))}"
            _found=1
        else
            _new+="${_json_buf:_ks:$(( _ke - _ks + 1 ))}:${_json_buf:_vs:$(( _ve - _vs + 1 ))}"
        fi
    done
    _new+="}"

    (( _found )) || { echo "json::kv::keys::rename: key '$1' not found" >&2; return 1; }

    local _pre="${_json_kv_root:0:_json_kv_cstart}"
    local _post="${_json_kv_root:$(( _json_kv_cend + 1 ))}"
    _json_kv_root="$_pre$_new$_post"
    _json_kv_cend=$(( _json_kv_cstart + ${#_new} - 1 ))
    _json_buf="$_json_kv_root"
    _json_len="${#_json_buf}"
}
