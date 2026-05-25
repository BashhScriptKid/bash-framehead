# `fs::dir::count`

**Signature:** `fs::dir::count()`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Count items in directory


## Source

```bash
fs::dir::count() {
		find "${1:-.}" -maxdepth 1 -not -path "${1:-.}" 2>/dev/null | wc -l
}
```

