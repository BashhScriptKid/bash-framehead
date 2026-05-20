# `timedate::calendar::day_of_year`

Get day of year for a date

## Usage

```bash
timedate::calendar::day_of_year YYYY-MM-DD
```

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

## Module

[`timedate`](../timedate.md)
