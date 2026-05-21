# `string::truncate`

**Signature:** `string::truncate(str, max, [suffix])`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Truncate a string to max length, appending suffix if truncated

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `max` | string | Yes | |
| `suffix` | string | No | |

## Source

```bash
string::truncate() {
  local input max
  if [[ ! -t 0 ]]; then
    input=$(cat); max="$1"
  else
    input="$1"; max="$2"
  fi
  local suffix

  if ((${#input} <= max)); then
    echo "$input"
    return 0
  fi

  # Handle very small max values
  if ((max <= 1)); then
    # Can only show suffix
    echo "…"
    return 0
  elif ((max == 2)); then
    # Can show 1 char + single ellipsis
    echo "${input:0:1}…"
    return 0
  fi

  # Determine which suffix to use based on available space
  local available_chars=$((max - 3))  # Try with 3-dot suffix first

  if ((available_chars < 3)); then
    # If we'd have less than 3 chars from original with 3-dot suffix,
    # use single ellipsis instead
    suffix="…"
    available_chars=$((max - 1))
  else
    suffix="..."
  fi

  echo "${input:0:$available_chars}${suffix}"
}
```

