# `timedate::date::is_between`

Check if a date is between two dates (inclusive)

## Source

```bash
timedate::date::is_between() {
    local d="$1" start="$2" end="$3"
    ! timedate::date::is_before "$d" "$start" && \
    ! timedate::date::is_after  "$d" "$end"
}
```

## Module

[`timedate`](../timedate.md)
