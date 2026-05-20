# `array::join`

Join elements with a delimiter

## Usage

```bash
array::join delimiter el1 el2 ...
```

## Source

```bash
array::join() {
    local delim="$1" result="" first=true; shift
    for el in "$@"; do
        if $first; then result="$el"; first=false
        else result+="${delim}${el}"; fi
    done
    echo "$result"
}
```

## Module

[`array`](../array.md)
