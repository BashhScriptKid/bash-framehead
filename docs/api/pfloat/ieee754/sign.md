# `pfloat::ieee754::sign`

**Signature:** `pfloat::ieee754::sign(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Sign (-1, 0, or 1)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::ieee754::sign() {
  local bits="$1"
  if _ieee754::is_zero "$bits"; then
    echo 0
  elif [[ $(_ieee754::get_sign "$bits") -eq 1 ]]; then
    echo -1
  else
    echo 1
  fi
}
```

