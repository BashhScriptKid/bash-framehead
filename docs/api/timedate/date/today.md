# `timedate::date::today`

**Signature:** `timedate::date::today()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Current date in YYYY-MM-DD format


## Source

```bash
timedate::date::today() {
    date +%Y-%m-%d
}
```

