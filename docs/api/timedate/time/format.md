# `timedate::time::format`

**Signature:** `timedate::time::format()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Current time in a custom format


## Source

```bash
timedate::time::format() {
    local fmt="${1:-%H:%M:%S}"
    date +"$fmt"
}
```

