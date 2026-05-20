# `timedate::calendar::iso_week`

Get ISO week number for a date

## Usage

```bash
timedate::calendar::iso_week YYYY-MM-DD
```

## Source

```bash
timedate::calendar::iso_week() {
    if _timedate::has_gnu_date; then
        date -d "$1" +%V 2>/dev/null
    else
        date -j -f "%Y-%m-%d" "$1" +%V 2>/dev/null
    fi
}
```

## Module

[`timedate`](../timedate.md)
