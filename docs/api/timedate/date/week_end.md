# `timedate::date::week_end`

**Signature:** `timedate::date::week_end()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get end of current week (Sunday)


## Source

```bash
timedate::date::week_end() {
		local dow
		dow=$(timedate::date::day_of_week)
		timedate::date::add_days "$(timedate::date::today)" "$(( 7 - dow ))"
}
```

