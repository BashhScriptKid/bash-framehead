# `array::count_of`

**Signature:** `array::count_of(needle, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Count occurrences of a value

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `needle` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::count_of() {
    local needle="$1" count=0; shift
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && (( count++ ))
    done
    echo "$count"
}
```

