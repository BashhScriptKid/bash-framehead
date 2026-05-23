# ext/csv/csv.sh — Pure Bash CSV parser (RFC 4180)
#
# Dependencies:
#   core: runtime
#   external: grep tr

# --- guard ---
declare -f 'runtime::bash_version' &>/dev/null || {
    echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
    return 1
}

_guard_core_deps=()
_guard_ext_deps=(grep tr)

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

# Global config:
#   CSV_NOHEADER=1  — first row is data, not a header row
#   CSV_DELIMITER   — field delimiter character (default: ',')

# ============================================================================
# Internal state
# ============================================================================
_csv_buf=""
_csv_pos=0
_csv_len=0
_csv_field=""
_csv_indexed=0
_csv_row_starts=()

# ============================================================================
# Internal: _csv_parse_field
#
# Parse one field starting at _csv_pos. Handles RFC 4180 quoting:
#   - Quoted fields absorb commas, newlines, and doubled-quote escapes
#   - Unquoted fields end at comma, newline, or EOF
#
# Sets _csv_field to the decoded value and advances _csv_pos past the
# field and its separator.
#
# Returns: 0 = separator was comma (more fields in this row)
#          1 = separator was newline or EOF (end of row)
# ============================================================================
_csv_parse_field() {
    _csv_field=""
    local _ch _delim="${CSV_DELIMITER:-,}"
    local _in_quote=0

    while (( _csv_pos < _csv_len )); do
        _ch="${_csv_buf:_csv_pos:1}"

        if (( _in_quote )); then
            if [[ "$_ch" == '"' ]]; then
                # Doubled quote → literal quote
                if (( _csv_pos + 1 < _csv_len )) && [[ "${_csv_buf:$((_csv_pos + 1)):1}" == '"' ]]; then
                    _csv_field+='"'
                    ((_csv_pos++))
                else
                    _in_quote=0
                fi
            else
                _csv_field+="$_ch"
            fi
        else
            if [[ "$_ch" == '"' ]]; then
                _in_quote=1
            elif [[ "$_ch" == "$_delim" ]]; then
                ((_csv_pos++))
                return 0
            elif [[ "$_ch" == $'\n' ]]; then
                ((_csv_pos++))
                return 1
            elif [[ "$_ch" == $'\r' ]]; then
                # Skip CR only when followed by LF (CRLF); preserve bare CR
                if (( _csv_pos + 1 < _csv_len )) && [[ "${_csv_buf:$((_csv_pos + 1)):1}" == $'\n' ]]; then
                    :
                else
                    _csv_field+="$_ch"
                fi
            else
                _csv_field+="$_ch"
            fi
        fi
        ((_csv_pos++))
    done
    return 1  # EOF acts like end of row
}

# ============================================================================
# Internal: _csv_reset <csv>
# ============================================================================
_csv_reset() {
    if [[ "$_csv_buf" != "$1" ]]; then
        _csv_indexed=0
        _csv_row_starts=()
    fi
    _csv_buf="$1"
    _csv_len="${#_csv_buf}"
    _csv_pos=0
}

# ============================================================================
# Internal: _csv_skip_row
#
# Consume fields from _csv_pos until end of row (newline or EOF).
# After return, _csv_pos is at the start of the next row.
# ============================================================================
_csv_skip_row() {
    local _rc
    while true; do
        _csv_parse_field
        _rc=$?
        (( _rc != 0 )) && return 0
        (( _csv_pos >= _csv_len )) && return 0
    done
}

# ============================================================================
# Internal: _csv_skip_rows <n>
# ============================================================================
_csv_skip_rows() {
    local _n="$1" _i
    for (( _i = 0; _i < _n; _i++ )); do
        _csv_skip_row
        (( _csv_pos >= _csv_len )) && return 1
    done
    return 0
}

# ============================================================================
# Internal: _csv_build_index
#
# Build a row-start index for O(1) row access.  Uses tr + grep -azob to find
# structural characters (newline, quote, delimiter) at C speed, then walks only
# those positions in Bash to track quote state and row boundaries.
#
# Skipped for CSVs under 4 KB — the scan overhead isn't worth the process spawn.
# ============================================================================
_csv_build_index() {
    (( _csv_indexed )) && return
    _csv_indexed=1

    (( _csv_len < 4096 )) && return

    local _saved_pos=$_csv_pos
    _csv_pos=0  # index the full CSV from position 0

    _csv_row_starts=(0)
    local _delim="${CSV_DELIMITER:-,}"
    local _row=0 _pos _ch _in_quote=0

    while IFS=: read -d '' -r _pos _ch; do
        if (( _in_quote )); then
            if [[ "$_ch" == '"' ]]; then
                # Peek at next byte to distinguish "" (escaped) from " (end quote)
                [[ "${_csv_buf:$((_pos + 1)):1}" == '"' ]] && continue
                _in_quote=0
            fi
        else
            case "$_ch" in
                '"') _in_quote=1 ;;
                "$_delim") ;;
                $'\x7F')  # originally a newline (remapped by tr)
                    ((_row++))
                    _csv_row_starts[_row]=$(( _pos + 1 ))
                    ;;
            esac
        fi
    done < <(printf '%s' "$_csv_buf" | tr '\n' $'\x7F' | grep -azob $'[\x7F",'"$_delim"$']')

    _csv_pos=$_saved_pos
}

# ============================================================================
# Internal: _csv_seek_row <n>
#
# Position _csv_pos at the start of data row <n> (0-based).
# Uses the row-start index when available; falls back to sequential scan.
# ============================================================================
_csv_seek_row() {
    local _target="$1"
    _csv_build_index
    if (( _csv_indexed && ${#_csv_row_starts[@]} > 0 )); then
        if (( _target < ${#_csv_row_starts[@]} )); then
            _csv_pos=${_csv_row_starts[_target]}
            (( _csv_pos >= _csv_len )) && return 1
            return 0
        fi
        return 1
    fi
    _csv_skip_rows "$_target"
}

# ============================================================================
# csv::get <csv> <row> <col>
#
# Return a single cell value.  <row> is 0-based (after the header row, if
# headers are enabled).  <col> is either a 0-based index or a header name.
# ============================================================================
csv::get() {
    local _csv="$1" _row="$2" _col="$3"
    local _has_hdr=$(( CSV_NOHEADER ? 0 : 1 ))
    local _col_idx _rc

    _csv_reset "$_csv"

    # Resolve column: if the column specifier is not a plain integer, or if we
    # have headers and it might be a header name, scan the header row.
    if (( _has_hdr )) && ! [[ "$_col" =~ ^[0-9]+$ ]]; then
        local _c=0 _found=0
        while true; do
            _csv_parse_field; _rc=$?
            if [[ "$_csv_field" == "$_col" ]]; then
                _col_idx=$_c
                _found=1
                break
            fi
            ((_c++))
            (( _rc != 0 )) && break
        done
        (( _found )) || {
            echo "csv::get: unknown column '$_col'" >&2
            return 1
        }
        _csv_reset "$_csv"
    else
        _col_idx=$_col
    fi

    # Build index (lazy, only for CSVs > 4KB) then seek to the absolute row
    _csv_build_index
    local _abs_row=$(( _has_hdr ? _row + 1 : _row ))
    _csv_seek_row "$_abs_row" || {
        echo "csv::get: row $_row out of range" >&2
        return 1
    }

    # Walk fields until the target column
    local _c=0
    while true; do
        _csv_parse_field; _rc=$?
        if (( _c == _col_idx )); then
            echo "$_csv_field"
            return 0
        fi
        ((_c++))
        (( _rc != 0 )) && break
    done

    echo "csv::get: column $_col_idx out of range" >&2
    return 1
}

# ============================================================================
# csv::get_file <file> <row> <col>
# ============================================================================
csv::get_file() {
    local _file="$1" _csv
    _csv="$(< "$_file")" || {
        echo "csv::get_file: cannot read '$_file'" >&2
        return 1
    }
    csv::get "$_csv" "$2" "$3"
}

# ============================================================================
# csv::row <csv> <row>
#
# Print all fields of a single row, tab-separated.
# ============================================================================
csv::row() {
    local _csv="$1" _row="$2"
    local _has_hdr=$(( CSV_NOHEADER ? 0 : 1 ))
    local _rc _first=1

    _csv_reset "$_csv"
    _csv_build_index
    local _abs_row=$(( _has_hdr ? _row + 1 : _row ))
    _csv_seek_row "$_abs_row" || {
        echo "csv::row: row $_row out of range" >&2
        return 1
    }

    while true; do
        _csv_parse_field; _rc=$?
        (( _first )) && _first=0 || printf '\t'
        printf '%s' "$_csv_field"
        (( _rc != 0 )) && { printf '\n'; return 0; }
    done
}

# ============================================================================
# csv::headers <csv>
#
# Print header field names, one per line.  Always reads the first row
# regardless of CSV_NOHEADER.
# ============================================================================
csv::headers() {
    local _csv="$1" _rc
    _csv_reset "$_csv"

    while true; do
        _csv_parse_field; _rc=$?
        printf '%s\n' "$_csv_field"
        (( _rc != 0 )) && return 0
    done
}

# ============================================================================
# csv::numrows <csv>
#
# Count data rows (excludes header when CSV_NOHEADER is not set).
# ============================================================================
csv::numrows() {
    local _csv="$1" _count=0 _i=0 _ch _in_quote=0
    local _len="${#_csv}"

    if (( _len == 0 )); then
        echo 0
        return 0
    fi

    while (( _i < _len )); do
        _ch="${_csv:_i:1}"
        if (( _in_quote )); then
            if [[ "$_ch" == '"' ]]; then
                if (( _i + 1 < _len )) && [[ "${_csv:$((_i + 1)):1}" == '"' ]]; then
                    ((_i++))
                else
                    _in_quote=0
                fi
            fi
        else
            case "$_ch" in
                '"') _in_quote=1 ;;
                $'\n') ((_count++)) ;;
            esac
        fi
        ((_i++))
    done

    # Trailing newline terminates the last row; no trailing newline means the
    # last row is unterminated and still counts.
    [[ "${_csv: -1}" != $'\n' ]] && ((_count++))

    # Exclude header row
    (( ! CSV_NOHEADER )) && (( _count > 0 )) && ((_count--))

    echo "$_count"
}

# ============================================================================
# csv::numcols <csv>
#
# Count columns from the first row.
# ============================================================================
csv::numcols() {
    local _csv="$1" _rc _count=0
    _csv_reset "$_csv"

    while true; do
        _csv_parse_field; _rc=$?
        ((_count++))
        (( _rc != 0 )) && break
    done
    echo "$_count"
}

# ============================================================================
# csv::to_json <csv>
#
# Convert CSV to JSON.  With headers (default): array of objects.
# With CSV_NOHEADER=1: array of arrays.
# ============================================================================
csv::to_json() {
    local _csv="$1"
    local _has_hdr=$(( CSV_NOHEADER ? 0 : 1 ))
    local _json="[" _first_row=1 _first_field _rc _val _escaped _i _ch

    _csv_reset "$_csv"

    # Collect headers
    local -a _headers=()
    if (( _has_hdr )); then
        while true; do
            _csv_parse_field; _rc=$?
            _headers+=("$_csv_field")
            (( _rc != 0 )) && break
        done
    fi

    # Emit data rows
    while (( _csv_pos < _csv_len )); do
        (( _first_row )) && _first_row=0 || _json+=","
        if (( _has_hdr )); then
            _json+="{"
        else
            _json+="["
        fi
        _first_field=1
        local _col=0
        while true; do
            _csv_parse_field; _rc=$?
            _val="$_csv_field"

            # JSON-escape
            _escaped=""
            for (( _i = 0; _i < ${#_val}; _i++ )); do
                _ch="${_val:_i:1}"
                case "$_ch" in
                    '"')  _escaped+='\"' ;;
                    '\')  _escaped+='\\' ;;
                    $'\n') _escaped+='\n' ;;
                    $'\r') _escaped+='\r' ;;
                    $'\t') _escaped+='\t' ;;
                    *)    _escaped+="$_ch" ;;
                esac
            done

            (( _first_field )) && _first_field=0 || _json+=","
            if (( _has_hdr )); then
                _json+="\"${_headers[_col]}\":\"$_escaped\""
            else
                _json+="\"$_escaped\""
            fi
            ((_col++))
            (( _rc != 0 )) && break
        done
        if (( _has_hdr )); then
            _json+="}"
        else
            _json+="]"
        fi
        # If the last row had no trailing newline, _csv_pos == _csv_len and we stop
        (( _rc != 0 && _csv_pos >= _csv_len )) && break
    done

    _json+="]"
    echo "$_json"
}
