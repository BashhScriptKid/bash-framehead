# `fs::find::larger_than`

**Signature:** `fs::find::larger_than()`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Find files larger than n bytes


## Source

```bash
fs::find::larger_than() {
		find "${1:-.}" -type f -size "+${2}c" 2>/dev/null
}
```

