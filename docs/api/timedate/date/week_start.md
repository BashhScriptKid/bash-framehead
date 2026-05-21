# `timedate::date::week_start`

**Signature:** `timedate::date::week_start()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get start of current week (Monday)


## Source

```bash
timedate::date::week_start() {
    local dow
    dow=$(timedate::date::day_of_week)
    timedate::date::add_days "$(timedate::date::today)" "$(( -(dow - 1) ))"
}
```

