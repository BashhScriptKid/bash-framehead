# `fs::find::smaller_than`

**Signature:** `fs::find::smaller_than()`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Find files smaller than n bytes


## Source

```bash
fs::find::smaller_than() {
		find "${1:-.}" -type f -size "-${2}c" 2>/dev/null
}
```

