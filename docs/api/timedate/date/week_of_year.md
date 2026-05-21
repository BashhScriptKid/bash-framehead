# `timedate::date::week_of_year`

**Signature:** `timedate::date::week_of_year()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get week of year (ISO 8601, 01-53)


## Source

```bash
timedate::date::week_of_year() {
    date +%V
}
```

