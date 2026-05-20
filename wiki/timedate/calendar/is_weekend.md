# `timedate::calendar::is_weekend`

Check if a date falls on a weekend

## Usage

```bash
timedate::calendar::is_weekend YYYY-MM-DD
```

## Source

```bash
timedate::calendar::is_weekend() {
    local dow
    if _timedate::has_gnu_date; then
        dow=$(date -d "$1" +%u 2>/dev/null)
    else
        dow=$(date -j -f "%Y-%m-%d" "$1" +%u 2>/dev/null)
    fi
    (( dow >= 6 ))
}
```

## Module

[`timedate`](../timedate.md)
