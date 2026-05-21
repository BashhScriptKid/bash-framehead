#!/usr/bin/env bash
# api-gen.sh — generate structured API reference pages from source modules
# Usage: ./tools/api-gen.sh [src_dir] [output_dir]
# Default: src_dir=src, output_dir=docs/api

set -uo pipefail

SRC="${1:-src}"
OUT="${2:-docs/api}"

[[ -d "$SRC" ]] || { echo "Error: src dir not found: $SRC" >&2; exit 1; }
mkdir -p "$OUT"

# ==============================================================================
# Extract comment block above a function definition
# ==============================================================================
_extract_comments() {
    local funcname="$1" file="$2"
    local lineno
    lineno=$(grep -n "^${funcname}()" "$file" | head -1 | cut -d: -f1)
    [[ -z "$lineno" ]] && return

    local i=$(( lineno - 1 ))
    local -a lines=()
    [[ $i -lt 1 ]] && return

    while (( i >= 1 )); do
        local line prev
        line=$(sed -n "${i}p" "$file")
        prev=""
        (( i > 1 )) && prev=$(sed -n "$(( i - 1 ))p" "$file")

        if [[ "$line" =~ ^#[[:space:]]*[=\-]{4,}[[:space:]]*$ ]]; then
            break
        fi

        if [[ "$line" =~ ^#[[:space:]]?(.*) ]]; then
            local content="${BASH_REMATCH[1]}"
            [[ "$content" =~ ^[=\-]{4,}$ ]] && break
            lines=("$content" "${lines[@]}")
            (( i-- ))
        elif [[ -z "$line" ]]; then
            if [[ ! "$prev" =~ ^# ]]; then
                break
            fi
            (( i-- ))
        else
            break
        fi
    done

    printf '%s\n' "${lines[@]}"
}

# ==============================================================================
# Extract function body from source
# ==============================================================================
_extract_body() {
    local funcname="$1" file="$2"
    local lineno
    lineno=$(grep -n "^${funcname}()" "$file" | head -1 | cut -d: -f1)
    [[ -z "$lineno" ]] && return

    local depth=0 started=false
    local -a body=()

    while IFS= read -r line; do
        started=true
        body+=("$line")
        local opens closes
        opens=$(grep -o '{' <<< "$line" | wc -l)
        closes=$(grep -o '}' <<< "$line" | wc -l)
        depth=$(( depth + opens - closes ))
        $started && (( depth == 0 )) && break
    done < <(tail -n "+${lineno}" "$file")

    printf '%s\n' "${body[@]}"
}

# ==============================================================================
# Parse signature from Usage: line
# ==============================================================================
_parse_signature() {
    local usage="$1" funcname="$2"
    local sig="${usage#Usage: }"
    sig="${sig#usage: }"
    sig="${sig#$funcname }"
    sig="${sig#$funcname}"
    sig=$(echo "$sig" | sed 's|\\"||g; s|"||g')
    sig=$(echo "$sig" | sed -e 's|^[[:space:]]*||' -e 's|[[:space:]]*$||')
    # Convert to comma-separated if space-separated
    if [[ "$sig" != *,* && "$sig" == *\ * ]]; then
        sig=$(echo "$sig" | sed 's| |, |g')
    fi
    if [[ -n "$sig" ]]; then
        echo "${funcname}(${sig})"
    else
        echo "${funcname}()"
    fi
}

# ==============================================================================
# Infer signature from function body
# ==============================================================================
_infer_signature() {
    local funcname="$1" body="$2"
    local -a params=()

    if echo "$body" | head -5 | grep -q 'local -n'; then
        params+=("result_var")
    fi

    echo "$body" | grep -q '\$1' && params+=("arg1")
    echo "$body" | grep -q '\$2' && params+=("arg2")
    echo "$body" | grep -q '\$3' && params+=("arg3")
    echo "$body" | grep -q '\$4' && params+=("arg4")
    echo "$body" | grep -q '\$5' && params+=("arg5")
    echo "$body" | grep -q 'shift' && params+=("...")

    local sig="${funcname}("
    local first=true
    for p in "${params[@]}"; do
        if $first; then first=false; else sig+=", "; fi
        sig+="$p"
    done
    sig+=")"
    [[ "${#params[@]}" -gt 0 ]] && echo "$sig" || echo "${funcname}()"
}

# ==============================================================================
# Determine return convention
# ==============================================================================
_determine_return() {
    local funcname="$1" body="$2"

    if [[ "$funcname" == *::fast ]]; then
        echo "**Return:** writes to nameref variable (first argument)"
        return
    fi

    local last_lines
    last_lines=$(echo "$body" | tail -20)

    if echo "$last_lines" | grep -qE '^\s*(echo|printf)'; then
        echo "**Return:** stdout — prints result"
    elif echo "$last_lines" | grep -qE '^\s*\[\[|^\s*\[ '; then
        echo "**Return:** exit code — 0 (true) or 1 (false)"
    elif echo "$last_lines" | grep -qE '^\s*return'; then
        echo "**Return:** exit code"
    else
        echo "**Return:** exit code — 0 (true) or 1 (false)"
    fi
}

# ==============================================================================
# Build parameter table from signature
# ==============================================================================
_build_param_table() {
    local signature="$1"

    local args="${signature#*\(}"
    args="${args%\)}"
    [[ -z "$args" ]] && return

    echo "## Parameters"
    echo ""
    echo "| Name | Type | Required | Description |"
    echo "|------|------|----------|-------------|"

    # Split on commas if present, otherwise on spaces
    local separator=' '
    if [[ "$args" == *,* ]]; then
        separator=','
    fi

    local -a arglist=()
    if [[ "$separator" == ',' ]]; then
        IFS=',' read -ra arglist <<< "$args"
    else
        IFS=' ' read -ra arglist <<< "$args"
    fi
    for arg in "${arglist[@]}"; do
        arg=$(echo "$arg" | xargs)
        [[ -z "$arg" ]] && continue

        local name="$arg" type="string" required="Yes"

        if [[ "$name" == \[*\] ]]; then
            name="${name#[}"; name="${name%]}"
            required="No"
        elif [[ "$name" == *...* ]]; then
            required="—"
        fi

        case "$name" in
            pid|*_pid|*_count|*_index|*_length|*_width|*_height|*_size|*_bytes|*_seconds|*_timeout|*_scale|*_n|*_start|*_end|*_code|*_port|n|bits|*_ms|*_ns) type="integer" ;;
            path|*_file|*_dir|*_path|target|src|dst|*_target|mountpoint) type="path" ;;
            callback) type="function" ;;
            pattern|regex|*_regex|*_pattern) type="regex" ;;
            command|*_command) type="command" ;;
            *var*|*_name|*_arr|varname) type="variable" ;;
            host|hostname|url) type="string" ;;
        esac

        if [[ "$name" == "..." ]]; then
            name="..." ; type="any" ; required="—"
        fi

        echo "| \`${name}\` | ${type} | ${required} | |"
    done
}

# ==============================================================================
# Find all public functions in a source file
# ==============================================================================
_list_functions() {
    local file="$1"
    # Match lines like "module::function()" or "module::function() {"
    # Extract just the function name before ()
    grep -oE '^[a-zA-Z_][a-zA-Z0-9_:]*::[a-zA-Z_][a-zA-Z0-9_:]*\(\)' "$file" \
        | grep -v '^_' \
        | sed 's/()$//' \
        | sort -u || true
}

# ==============================================================================
# Generate API page for a single function
# ==============================================================================
_gen_page() {
    local funcname="$1" module="$2" src_file="$3" mod_dir="$4"

    # Strip module prefix to get function path within module
    # e.g. net::port::is_open → port/is_open, string::upper → upper
    local rel_path="${funcname#${module}::}"
    # Convert remaining :: to / for namespace nesting
    rel_path="${rel_path//::/\/}"
    local out_file="${mod_dir}/${rel_path}.md"
    # Ensure subdirectories exist
    mkdir -p "$(dirname "$out_file")"

    local comments body signature return_info
    comments=$(_extract_comments "$funcname" "$src_file")
    body=$(_extract_body "$funcname" "$src_file")

    local usage_line
    usage_line=$(echo "$comments" | grep -i '^Usage:' | head -1 || true)
    if [[ -n "$usage_line" ]]; then
        signature=$(_parse_signature "$usage_line" "$funcname")
    else
        signature=$(_infer_signature "$funcname" "$body")
    fi

    return_info=$(_determine_return "$funcname" "$body")

    local description
    description=$(echo "$comments" | grep -iv '^Usage:\|^Example:\|^Internal:' | grep -v '^$' | head -1 || true)

    local example_lines
    example_lines=$(echo "$comments" | grep -i '^Example:' || true)

    {
        echo "# \`${funcname}\`"
        echo ""
        echo "**Signature:** \`${signature}\`"
        # Compute relative path back to api/ root
        local up=""
        local stripped="${rel_path//[!\/]/}"
        local depth=$(( ${#stripped} + 1 ))
        local ji
        for ((ji=0; ji<depth; ji++)); do up+="../"; done

        echo ""
        echo "**Module:** [\`${module}\`](${up}${module}.md) — [Guide](${up}guide/index.md)"
        echo ""
        echo "$return_info"
        echo ""
        echo "## Description"
        echo ""
        echo "${description:-_No description available._}"
        echo ""
        _build_param_table "$signature"
        echo ""
        if [[ -n "$example_lines" ]]; then
            echo "## Example"
            echo ""
            echo '```bash'
            echo "$example_lines" | sed 's/^Example: //'
            echo '```'
            echo ""
        fi
        echo "## Source"
        echo ""
        echo '```bash'
        printf '%s\n' "$body"
        echo '```'
        echo ""
    } > "$out_file"
}

# ==============================================================================
# Main
# ==============================================================================
main() {
    local total=0

    for src_file in "$SRC"/*.sh; do
        [[ -f "$src_file" ]] || continue
        local fname module
        fname=$(basename "$src_file" .sh)
        module="$fname"

        local mod_dir="${OUT}/${module}"
        mkdir -p "$mod_dir"

        local -a funcs=()
        while IFS= read -r fn; do
            [[ -n "$fn" ]] && funcs+=("$fn")
        done < <(_list_functions "$src_file")

        for funcname in "${funcs[@]}"; do
            _gen_page "$funcname" "$module" "$src_file" "$mod_dir"
            (( total++ ))
        done

        printf '  %s: %d functions\n' "$module" "${#funcs[@]}"
    done

    echo ""
    echo "Done — $total API pages generated in $OUT/"
}

main "$@"
