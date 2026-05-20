# `array::from_string`

Build an array from a delimited string

## Usage

```bash
array::from_string delimiter string
```

## Example

```bash
array::from_string "," "a,b,c" → prints one element per line
```

## Source

```bash
array::from_string() {
    [[ $# -lt 2 ]] && { echo "Usage: array::from_string <delimiter> <string> [array_name]" >&2; return 1; }

    local delim="$1" s="$2"
    local array_name="$3"

    # Use awk to split properly
    local elements
    elements=$(echo "$s" | awk -v d="$delim" 'BEGIN {ORS="\n"} {
        gsub(d, "\n")
        print
    }')

    if [[ -n "$array_name" ]]; then
        # Populate named array using readarray
        readarray -t "$array_name" <<< "$elements"
    else
        # Output elements
        echo "$elements"
    fi
}
```

## Module

[`array`](../array.md)
