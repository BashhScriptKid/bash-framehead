# `fs::ls::all`

**Signature:** `fs::ls::all()`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List with hidden files


## Source

```bash
fs::ls::all() {
    ls -1A "${1:-.}"
}
```

