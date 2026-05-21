# `timedate::calendar::days_in_year`

**Signature:** `timedate::calendar::days_in_year(arg1)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get number of days in a year

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
timedate::calendar::days_in_year() {
    timedate::calendar::is_leap_year "$1" && echo 366 || echo 365
}
```

