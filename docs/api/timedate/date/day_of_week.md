# `timedate::date::day_of_week`

**Signature:** `timedate::date::day_of_week()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get day of week (1=Monday, 7=Sunday, ISO 8601)


## Source

```bash
timedate::date::day_of_week() {
    date +%u
}
```

