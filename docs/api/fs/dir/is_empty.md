# `fs::dir::is_empty`

**Signature:** `fs::dir::is_empty()`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if directory is empty


## Source

```bash
fs::dir::is_empty() {
    [[ -z "$(ls -A "${1:-.}" 2>/dev/null)" ]]
}
```

