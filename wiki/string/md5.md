# `string::md5`

MD5 hash of a string

**Requires:** md5sum (Linux) or md5 (macOS)

## Source

```bash
string::md5() {
  if command -v md5sum >/dev/null 2>&1; then
    echo -n "$1" | md5sum | cut -d' ' -f1
  elif command -v md5 >/dev/null 2>&1; then
    echo -n "$1" | md5
  else
    echo "string::md5: requires md5sum or md5" >&2
    return 1
  fi
}
```

## Module

[`string`](../string.md)
