# `timedate::tz::convert`

Convert a timestamp to a different timezone

## Usage

```bash
timedate::tz::convert timestamp timezone
```

## Example

```bash
timedate::tz::convert 1700000000 "America/New_York"
```

## Source

```bash
timedate::tz::convert() {
    local ts="$1" tz="$2"
    if _timedate::has_gnu_date; then
        TZ="$tz" date -d "@$ts" "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
    else
        TZ="$tz" date -r "$ts" "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null
    fi
}
```

## Module

[`timedate`](../timedate.md)
