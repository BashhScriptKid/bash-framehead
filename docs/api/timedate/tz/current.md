# `timedate::tz::current`

**Signature:** `timedate::tz::current()`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get current timezone name


## Source

```bash
timedate::tz::current() {
    date +%Z
}
```

