# `timedate::date::year_end`

**Signature:** `timedate::date::year_end()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get end of current year


## Source

```bash
timedate::date::year_end() {
		date +%Y-12-31
}
```

