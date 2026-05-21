# `timedate::calendar::day_of_year`

**Signature:** `timedate::calendar::day_of_year(YYYY-MM-DD)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get day of year for a date

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `YYYY-MM-DD` | string | Yes | |

## Source

```bash
timedate::calendar::day_of_year() {
    if _timedate::has_gnu_date; then
        date -d "$1" +%j 2>/dev/null
    else
        date -j -f "%Y-%m-%d" "$1" +%j 2>/dev/null
    fi
}
```

