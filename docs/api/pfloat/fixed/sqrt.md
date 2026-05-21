# `pfloat::fixed::sqrt`

**Signature:** `pfloat::fixed::sqrt(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::fixed::sqrt() {
  local num="$1" iterations="${2:-20}"
  local guess prev_guess i

  if pfloat::fixed::is_negative "$num"; then
    echo "pfloat::fixed::sqrt: negative input" >&2
    return 1
  fi

  if pfloat::fixed::is_zero "$num"; then
    echo "0"
    return
  fi

  if pfloat::fixed::gt "$num" "1"; then
    guess=$(pfloat::fixed::div "$num" "2")
  else
    guess="1"
  fi

  for ((i = 0; i < iterations; i++)); do
    prev_guess="$guess"
    guess=$(pfloat::fixed::div $(pfloat::fixed::add "$guess" $(pfloat::fixed::div "$num" "$guess")) "2")

    if pfloat::fixed::eq "$guess" "$prev_guess"; then
      break
    fi
  done

  echo "$guess"
}
```

