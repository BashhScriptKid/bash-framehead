# `string::pad_center`

Centre a string within a given width

## Usage

```bash
string::pad_center str width [char]
```

## Source

```bash
string::pad_center() {
  local s="$1" width="$2" char="${3:- }"
  local len="${#s}"
  if ((len >= width)); then
    echo "$s"
    return
  fi
  local total=$((width - len))
  local left=$((total / 2))
  local right=$((total - left))
  local lpad rpad
  lpad=$(string::repeat "$char" $left)
  rpad=$(string::repeat "$char" $right)
  echo "${lpad}${s}${rpad}"
}
```

## Module

[`string`](../string.md)
