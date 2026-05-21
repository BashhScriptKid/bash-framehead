# `fs::path::stem`

**Signature:** `fs::path::stem()`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Strip extension from filename


## Source

```bash
fs::path::stem() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base%.*}" || echo "$base"
}
```

