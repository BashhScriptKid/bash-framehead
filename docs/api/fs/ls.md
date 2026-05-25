# `fs::ls`

**Signature:** `fs::ls()`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- DIRECTORY OPERATIONS ---


## Source

```bash
fs::ls() {
		ls -1 "${1:-.}"
}
```

