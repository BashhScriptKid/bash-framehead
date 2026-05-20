# `timedate::timestamp::from_human`

Convert human-readable date to unix timestamp

## Usage

```bash
timedate::timestamp::from_human "2024-01-15 12:00:00"
```

## Source

```bash
timedate::timestamp::from_human() {
    if _timedate::has_gnu_date; then
        date -d "$1" +%s 2>/dev/null
    else
        date -j -f "%Y-%m-%d %H:%M:%S" "$1" +%s 2>/dev/null
    fi
}
```

## Module

[`timedate`](../timedate.md)
