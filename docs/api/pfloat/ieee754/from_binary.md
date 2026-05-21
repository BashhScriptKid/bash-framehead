# `pfloat::ieee754::from_binary`

**Signature:** `pfloat::ieee754::from_binary(0011111111111000..., , , , , , , , , , #, flat, (64, chars))`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Convert from binary string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `0011111111111000...` | string | — | |
| `#` | string | Yes | |
| `flat` | string | Yes | |
| `(64` | string | Yes | |
| `chars)` | string | Yes | |

## Source

```bash
pfloat::ieee754::from_binary() {
  local raw
  if (( $# == 1 )); then
    raw="${1//_/}"
    if ((${#raw} != 64)); then
      echo "pfloat::ieee754::from_binary: expected 64-bit flat binary, got ${#raw}" >&2
      return 1
    fi
  elif (( $# == 3 )); then
    local s="${1//_/}" e="${2//_/}" m="${3//_/}"
    if ((${#s} != 1)); then
      echo "pfloat::ieee754::from_binary: sign must be 1 bit, got ${#s}" >&2
      return 1
    fi
    if ((${#e} != 11)); then
      echo "pfloat::ieee754::from_binary: exponent must be 11 bits, got ${#e}" >&2
      return 1
    fi
    if ((${#m} != 52)); then
      echo "pfloat::ieee754::from_binary: mantissa must be 52 bits, got ${#m}" >&2
      return 1
    fi
    raw="${s}${e}${m}"
  else
    echo "pfloat::ieee754::from_binary: expected 1 arg (flat 64-bit) or 3 args (sign exp mant)" >&2
    return 1
  fi

  # Convert binary string to integer
  local result=0 i
  for ((i=0; i<64; i++)); do
    result=$(( (result << 1) | ${raw:$i:1} ))
  done
  echo "$result"
}
```

