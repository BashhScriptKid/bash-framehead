# `array::remove`

**Signature:** `array::remove(value, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Remove all occurrences of a value

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `value` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::remove() {
    local target="$1"; shift
    for el in "$@"; do
        [[ "$el" != "$target" ]] && echo "$el"
    done
}
```

