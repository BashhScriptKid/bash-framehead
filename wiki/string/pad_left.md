# `string::pad_left`

Pad string on the left to a given width

## Usage

```bash
string::pad_left str width [char]
```

## Source

```bash
string::pad_left() {
  local s="$1" width="$2" char="${3:- }"
  local len="${#s}"
  if ((len >= width)); then
    echo "$s"
    return
  fi
  local pad
  pad=$(string::repeat "$char" $((width - len)))
  echo "${pad}${s}"
}
```

## Module

[`string`](../string.md)
