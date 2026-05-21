# `string::pascal_to_plain`

**Signature:** `string::pascal_to_plain()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

PascalCase → plain


## Source

```bash
string::pascal_to_plain() {
  local input; _string::read_input input "$@"
  _string::to_words "$input"
}
```

