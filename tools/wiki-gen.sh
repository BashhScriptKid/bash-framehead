#!/usr/bin/env bash
# gen_wiki.sh — generate wiki docs from bash-framehead compiled output
# Dogfoods the framework for string manipulation, fs operations, and path handling
#
# Usage: ./gen_wiki.sh <framework_file> [wiki_dir]
# Example: ./gen_wiki.sh ./bash-framehead.sh ./wiki
#
# Behaviour:
#   - Function pages: skipped if already exist (preserves manual edits)
#   - Module indexes: new entries appended, existing entries preserved
#   - Root index: new module rows appended, existing rows preserved


SRC="${1:?Usage: gen_wiki.sh <framework_file> [wiki_dir]}"
WIKI="${2:-./wiki}"

[[ -f "$SRC" ]] || { echo "Error: source file not found: $SRC" >&2; exit 1; }

# Load the framework — this is the whole point
# shellcheck source=/dev/null
source "$SRC"

# ==============================================================================
# INTROSPECTION HELPERS (using the framework)
# ==============================================================================

_wiki::all_functions() {
    declare -F | awk '{print $3}' | grep -v '^_' | grep '::' | sort
}

_wiki::module_of() {
    string::before "$1" "::"
}

_wiki::leaf_of() {
    string::after "$1" "::"
}

_wiki::to_path() {
    string::replace_all "$1" "::" "/"
}

# Extract comment block above a function definition
# Stops at blank lines (with no comment on the other side),
# non-comment lines, and divider lines (# ===...)
_wiki::extract_comments() {
    local funcname="$1"
    local lineno
    lineno=$(grep -n "^${funcname}()" "$SRC" | head -1 | cut -d: -f1)
    [[ -z "$lineno" ]] && return

    local i=$(( lineno - 1 ))
    local -a lines=()

    while (( i >= 1 )); do
        local line
        line=$(sed -n "${i}p" "$SRC")

        # Stop at divider lines: # ===... or # ---...
        if [[ "$line" =~ ^#[[:space:]]*[=\-]{4,}[[:space:]]*$ ]]; then
            break
        fi

        if [[ "$line" =~ ^#[[:space:]]?(.*) ]]; then
            local content="${BASH_REMATCH[1]}"
            # Skip if content is itself just dashes/equals (belt and braces)
            [[ "$content" =~ ^[=\-]{4,}$ ]] && break
            lines=("$content" "${lines[@]}")
            (( i-- ))
        elif [[ -z "$line" ]]; then
            local prev
            prev=$(sed -n "$(( i - 1 ))p" "$SRC")
            [[ "$prev" =~ ^# ]] && { (( i-- )); continue; }
            break
        else
            break
        fi
    done

    printf '%s\n' "${lines[@]}"
}

# Extract function body from source
_wiki::extract_body() {
    local funcname="$1"
    local lineno
    lineno=$(grep -n "^${funcname}()" "$SRC" | head -1 | cut -d: -f1)
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
    done < <(tail -n "+${lineno}" "$SRC")

    printf '%s\n' "${body[@]}"
}

# ==============================================================================
# WIKI PAGE GENERATION
# ==============================================================================

_wiki::write_function_page() {
    local funcname="$1"
    local module leaf leaf_path out_file out_dir
    module=$(_wiki::module_of "$funcname")
    leaf=$(_wiki::leaf_of "$funcname")
    leaf_path=$(_wiki::to_path "$leaf")
    out_file="${WIKI}/${module}/${leaf_path}.md"
    out_dir=$(fs::path::dirname "$out_file")

    fs::mkdir "$out_dir"

    # Skip if already exists — preserve manual edits
    if [[ -f "$out_file" ]]; then
        return
    fi

    local comments usage description example
    comments=$(_wiki::extract_comments "$funcname")
    usage=$(grep -i    '^Usage:'   <<< "$comments" | string::after_last "Usage: " || true)
    example=$(grep -i  '^Example:' <<< "$comments" | string::after_last "Example: " || true)
    description=$(grep -iv '^Usage:\|^Example:' <<< "$comments" | grep -v '^$' | head -1 || true)

    local body
    body=$(_wiki::extract_body "$funcname")

    local example_block=""
    if [[ -n "$example" ]]; then
        example_block="$(printf '\n## Example\n\n```bash\n%s\n```\n' "$example")"
    fi

    fs::write "$out_file" "# \`${funcname}\`

${description:-_No description available._}

## Usage

\`\`\`bash
${usage:-${funcname} ...}
\`\`\`
${example_block}
## Source

\`\`\`bash
${body}
\`\`\`

## Module

[\`${module}\`](../${module}.md)
"
}

_wiki::write_module_index() {
    local module="$1"
    shift
    local -a funcs=("$@")
    local index_file="${WIKI}/${module}.md"

    # Create with header if it doesn't exist yet
    if [[ ! -f "$index_file" ]]; then
        {
            echo "# \`${module}\`"
            echo ""
            echo "| Function | Description |"
            echo "|----------|-------------|"
        } > "$index_file"
    fi

    local existing
    existing=$(cat "$index_file")

    local fn comments desc leaf leaf_path
    for fn in "${funcs[@]}"; do
        # Skip if this function already has an entry
        string::contains "$existing" "\`${fn}\`" && continue

        leaf=$(_wiki::leaf_of "$fn")
        leaf_path=$(_wiki::to_path "$leaf")
        comments=$(_wiki::extract_comments "$fn")
        desc=$(grep -iv '^Usage:\|^Example:' <<< "$comments" | grep -v '^$' | head -1 || true)
        echo "| [\`${fn}\`](./${module}/${leaf_path}.md) | ${desc:-—} |" >> "$index_file"
    done
}

_wiki::write_root_index() {
    local -a modules=("$@")
    local index_file="${WIKI}/README.md"

    # Create with header if it doesn't exist yet
    if [[ ! -f "$index_file" ]]; then
        {
            echo "# bash-framehead"
            echo ""
            echo "## Modules"
            echo ""
            echo "| Module | Functions |"
            echo "|--------|-----------|"
        } > "$index_file"
    fi

    local existing
    existing=$(cat "$index_file")

    local m count
    for m in $(printf '%s\n' "${modules[@]}" | sort -u); do
        # Skip if module already has an entry
        string::contains "$existing" "\`${m}\`" && continue

        count=$(grep -c '^| `' "${WIKI}/${m}.md" 2>/dev/null || echo 0)
        echo "| [\`${m}\`](./${m}.md) | ${count} |" >> "$index_file"
    done
}

# ==============================================================================
# MAIN
# ==============================================================================

fs::mkdir "$WIKI"

echo "bash-framehead wiki generator"
echo "Source:  $SRC"
echo "Output:  $WIKI"
echo ""

# Collect all functions grouped by module
declare -A module_funcs=()
declare -a all_funcs=()

while IFS= read -r fn; do
    module=$(_wiki::module_of "$fn")
    if [[ -z "${module_funcs[$module]+x}" ]]; then
        module_funcs["$module"]="$fn"
    else
        module_funcs["$module"]+=" $fn"
    fi
    all_funcs+=("$fn")
done < <(_wiki::all_functions)

total=${#all_funcs[@]}
module_count=${#module_funcs[@]}

echo "Found $total functions across $module_count modules"
echo ""

# Generate function pages
created=0
skipped=0
for fn in "${all_funcs[@]}"; do
    module=$(_wiki::module_of "$fn")
    leaf=$(_wiki::leaf_of "$fn")
    leaf_path=$(_wiki::to_path "$leaf")
    out_file="${WIKI}/${module}/${leaf_path}.md"

    if [[ -f "$out_file" ]]; then
        (( skipped++ ))
    else
        _wiki::write_function_page "$fn"
        (( created++ ))
    fi
    printf '\r  %d created, %d skipped / %d total' "$created" "$skipped" "$total"
done
echo ""

# Generate module index pages
echo ""
echo "Generating module indexes..."
for module in "${!module_funcs[@]}"; do
    read -ra funcs <<< "${module_funcs[$module]}"
    _wiki::write_module_index "$module" "${funcs[@]}"
    echo "  ${module}.md"
done

# Generate root index
echo ""
echo "Generating root index..."
_wiki::write_root_index "${!module_funcs[@]}"

echo ""
echo "Done — ${created} created, ${skipped} skipped, ${WIKI}/README.md updated"
