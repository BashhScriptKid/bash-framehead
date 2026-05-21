# `array::rotate`

**Signature:** `array::rotate(n, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Rotate array left by n positions

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n` | integer | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::rotate() {
    local n="$1"; shift
    local -a arr=("$@")
    local len="${#arr[@]}"
    n=$(( n % len ))
    printf '%s\n' "${arr[@]:$n}" "${arr[@]:0:$n}"
}
```

