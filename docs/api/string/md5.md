# `string::md5`

**Signature:** `string::md5()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

MD5 hash of a string


## Source

```bash
string::md5() {
  local input; _string::read_input input "$@"
  if command -v md5sum >/dev/null 2>&1; then
    echo -n "$input" | md5sum | cut -d' ' -f1
  elif command -v md5 >/dev/null 2>&1; then
    echo -n "$input" | md5
  else
    echo "string::md5: requires md5sum or md5" >&2
    return 1
  fi
}
```

