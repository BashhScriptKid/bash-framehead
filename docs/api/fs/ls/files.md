# `fs::ls::files`

**Signature:** `fs::ls::files()`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List only files


## Source

```bash
fs::ls::files() {
    find "${1:-.}" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null || \
    ls -1p "${1:-.}" | grep -v '/$'
}
```

