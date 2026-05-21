# `timedate::date::month_start`

**Signature:** `timedate::date::month_start()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get start of current month


## Source

```bash
timedate::date::month_start() {
    date +%Y-%m-01
}
```

