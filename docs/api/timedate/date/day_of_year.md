# `timedate::date::day_of_year`

**Signature:** `timedate::date::day_of_year()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get day of year (001-366)


## Source

```bash
timedate::date::day_of_year() {
		date +%j
}
```

