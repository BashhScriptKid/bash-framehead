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
		local _rot="$1"; shift
		local -a arr=("$@")
		local len="${#arr[@]}"
		_rot=$(( _rot % len ))
		printf '%s\n' "${arr[@]:$_rot}" "${arr[@]:0:$_rot}"
}
```

