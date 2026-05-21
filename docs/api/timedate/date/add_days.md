# `timedate::date::add_days`

**Signature:** `timedate::date::add_days(YYYY-MM-DD, n)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Add n days to a date

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `YYYY-MM-DD` | string | Yes | |
| `n` | integer | Yes | |

## Source

```bash
timedate::date::add_days() {
    local date_str="$1" n="$2"
    if _timedate::has_gnu_date; then
        date -d "$date_str + $n days" +%Y-%m-%d 2>/dev/null
    else
        date -v+"${n}d" -j -f "%Y-%m-%d" "$date_str" +%Y-%m-%d 2>/dev/null
    fi
}
```

