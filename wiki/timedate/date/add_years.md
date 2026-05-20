# `timedate::date::add_years`

Add n years to a date

## Source

```bash
timedate::date::add_years() {
    local date_str="$1" n="$2"
    if _timedate::has_gnu_date; then
        date -d "$date_str + $n years" +%Y-%m-%d 2>/dev/null
    else
        date -v+"${n}y" -j -f "%Y-%m-%d" "$date_str" +%Y-%m-%d 2>/dev/null
    fi
}
```

## Module

[`timedate`](../timedate.md)
