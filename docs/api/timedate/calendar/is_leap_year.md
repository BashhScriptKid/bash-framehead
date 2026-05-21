# `timedate::calendar::is_leap_year`

**Signature:** `timedate::calendar::is_leap_year(year)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a year is a leap year

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `year` | string | Yes | |

## Source

```bash
timedate::calendar::is_leap_year() {
    local year="$1"
    (( year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) ))
}
```

