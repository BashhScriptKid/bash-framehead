# `string::pad_left`

**Signature:** `string::pad_left(str, width, [char])`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Pad string on the left to a given width

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `width` | string | Yes | |
| `char` | string | No | |

## Source

```bash
string::pad_left() {
  local input width char
  if [[ ! -t 0 ]]; then
    input=$(cat); width="$1"; char="${2:- }"
  else
    input="$1"; width="$2"; char="${3:- }"
  fi
  local len="${#input}"
  if ((len >= width)); then echo "$input"; return; fi
  local pad
  pad=$(string::repeat "$char" $((width - len)))
  echo "${pad}${input}"
}
```

