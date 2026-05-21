# `process::job::list`

**Signature:** `process::job::list()`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List current shell's background jobs


## Source

```bash
process::job::list() {
    jobs -l
}
```

