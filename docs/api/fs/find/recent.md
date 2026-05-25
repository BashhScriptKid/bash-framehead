# `fs::find::recent`

**Signature:** `fs::find::recent()`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Find files modified within n minutes


## Source

```bash
fs::find::recent() {
		find "${1:-.}" -type f -mmin "-${2:-60}" 2>/dev/null
}
```

