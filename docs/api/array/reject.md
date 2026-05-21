# `array::reject`

**Signature:** `array::reject(regex, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Filter elements NOT matching a regex

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `regex` | regex | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::reject() {
    local regex="$1"; shift
    for el in "$@"; do
        [[ ! "$el" =~ $regex ]] && echo "$el"
    done
}
```

