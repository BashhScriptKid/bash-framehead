# `random::well512`

**Signature:** `random::well512(index, s0, s1, ..., s15)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns: "result new_index s0 ... s15"

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `index` | string | Yes | |
| `s0` | string | Yes | |
| `s1` | string | Yes | |
| `...` | any | — | |
| `s15` | string | Yes | |

## Example

```bash
Example:
```

## Source

```bash
random::well512() {
    local index="$1"; shift
    local -a s=("$@")

    local a="${s[$index]}"
    local c="${s[$(( (index + 13) & 15 ))]}"
    local b
    b=$(_random::mask32 $(( (a ^ (a << 16)) ^ (c ^ (c << 15)) )))
    local d="${s[$(( (index + 9) & 15 ))]}"
    d=$(( d ^ (d >> 11) ))
    s[$index]=$(_random::mask32 $(( b ^ d )))
    local e="${s[$index]}"
    local result
    result=$(_random::mask32 $(( e ^ ((e << 5) & 0xDA442D24) )))
    index=$(( (index + 15) & 15 ))
    a="${s[$index]}"
    s[$index]=$(_random::mask32 $(( a ^ b ^ d ^ (a << 2) ^ (b << 18) ^ (c << 28) )))
    result=$(_random::mask32 $(( result ^ s[$index] )))

    echo "$result $index ${s[*]}"
}
```

