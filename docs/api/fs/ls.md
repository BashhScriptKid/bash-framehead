# `fs::ls`

**Signature:** `fs::ls()`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List directory contents (one per line)


## Source

```bash
fs::ls() {
    ls -1 "${1:-.}"
}
```

