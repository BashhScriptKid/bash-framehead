# `timedate::date::add_months`

**Signature:** `timedate::date::add_months(arg1, arg2)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Add n months to a date

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
timedate::date::add_months() {
    local date_str="$1" n="$2"
    if _timedate::has_gnu_date; then
        date -d "$date_str + $n months" +%Y-%m-%d 2>/dev/null
    else
        date -v+"${n}m" -j -f "%Y-%m-%d" "$date_str" +%Y-%m-%d 2>/dev/null
    fi
}
```

