# `timedate::time::now`

**Signature:** `timedate::time::now()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Current time in HH:MM:SS


## Source

```bash
timedate::time::now() {
    date +%H:%M:%S
}
```

