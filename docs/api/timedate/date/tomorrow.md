# `timedate::date::tomorrow`

**Signature:** `timedate::date::tomorrow()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get tomorrow's date


## Source

```bash
timedate::date::tomorrow() {
    timedate::date::add_days "$(timedate::date::today)" 1
}
```

