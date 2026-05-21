# `array::join`

**Signature:** `array::join(delimiter, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Join elements with a delimiter

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `delimiter` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

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

