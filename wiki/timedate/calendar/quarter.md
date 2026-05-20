# `timedate::calendar::quarter`

Get quarter for a date

## Usage

```bash
timedate::calendar::quarter YYYY-MM-DD
```

## Source

```bash
timedate::calendar::quarter() {
    local month
    if _timedate::has_gnu_date; then
        month=$(date -d "$1" +%m 2>/dev/null)
    else
        month=$(date -j -f "%Y-%m-%d" "$1" +%m 2>/dev/null)
    fi
    echo $(( (10#$month - 1) / 3 + 1 ))
}
```

## Module

[`timedate`](../timedate.md)
