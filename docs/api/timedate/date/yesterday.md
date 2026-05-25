# `timedate::date::yesterday`

**Signature:** `timedate::date::yesterday()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get yesterday's date


## Source

```bash
timedate::date::yesterday() {
		timedate::date::add_days "$(timedate::date::today)" -1
}
```

