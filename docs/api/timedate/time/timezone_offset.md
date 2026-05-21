# `timedate::time::timezone_offset`

**Signature:** `timedate::time::timezone_offset()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get timezone offset from UTC (e.g. +0800)


## Source

```bash
timedate::time::timezone_offset() {
    date +%z
}
```

