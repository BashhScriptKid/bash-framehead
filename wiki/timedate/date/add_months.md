# `timedate::date::add_months`

Add n months to a date

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

## Module

[`timedate`](../timedate.md)
