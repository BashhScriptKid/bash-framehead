# `string::truncate::fast`

**Signature:** `string::truncate::fast(result_var, str, max, [suffix])`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |
| `max` | string | Yes | |
| `suffix` | string | No | |

## Source

```bash
string::truncate::fast() {
  local -n _string_truncate_result="$1"
  local s="$2" max="$3"
  local suffix

  if ((${#s} <= max)); then
    _string_truncate_result="$s"
    return 0
  fi

  # Handle very small max values
  if ((max <= 1)); then
    _string_truncate_result="…"
    return 0
  elif ((max == 2)); then
    _string_truncate_result="${s:0:1}…"
    return 0
  fi

  # Determine which suffix to use based on available space
  local available_chars=$((max - 3))

  if ((available_chars < 3)); then
    suffix="…"
    available_chars=$((max - 1))
  else
    suffix="..."
  fi

  _string_truncate_result="${s:0:$available_chars}${suffix}"
}
```

