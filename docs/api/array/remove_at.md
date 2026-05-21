# `array::remove_at`

**Signature:** `array::remove_at(index, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Remove element at index

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `index` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::remove_at() {
    local idx="$1" i=0; shift
    for el in "$@"; do
        [[ "$i" -ne "$idx" ]] && echo "$el"
        (( i++ ))
    done
}
```

