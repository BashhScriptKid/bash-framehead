# `timedate::date::add_days`

Add n days to a date

## Usage

```bash
timedate::date::add_days YYYY-MM-DD n
```

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

## Module

[`timedate`](../timedate.md)
