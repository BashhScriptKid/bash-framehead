# `pfloat::fixed::cbrt`

**Signature:** `pfloat::fixed::cbrt(arg1)`

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
pfloat::fixed::cbrt() {
  local num="$1" iterations="${2:-30}"
  local guess i sign=""

  if pfloat::fixed::is_negative "$num"; then
    sign="-"
    num=$(pfloat::fixed::neg "$num")
  fi

  if pfloat::fixed::is_zero "$num"; then
    echo "0"
    return
  fi

  guess=$(pfloat::fixed::div "$num" "3")
  [[ "$guess" == "0" ]] && guess="1"

  for ((i = 0; i < iterations; i++)); do
    local x2
    x2=$(pfloat::fixed::mul "$guess" "$guess")
    guess=$(pfloat::fixed::div $(pfloat::fixed::add $(pfloat::fixed::mul "2" "$guess") $(pfloat::fixed::div "$num" "$x2")) "3")
  done

  if [[ -n "$sign" ]]; then
    echo "-${guess}"
  else
    echo "$guess"
  fi
}
```

