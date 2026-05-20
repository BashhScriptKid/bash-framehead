# `string::pad_right`

Pad string on the right to a given width

## Usage

```bash
string::pad_right str width [char]
```

## Source

```bash
string::pad_right() {
  local s="$1" width="$2" char="${3:- }"
  local len="${#s}"
  if ((len >= width)); then
    echo "$s"
    return
  fi
  local pad
  pad=$(string::repeat "$char" $((width - len)))
  echo "${s}${pad}"
}
```

## Module

[`string`](../string.md)
