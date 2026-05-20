# `timedate::calendar::is_weekday`

Check if a date falls on a weekday

## Source

```bash
timedate::calendar::is_weekday() {
    ! timedate::calendar::is_weekend "$1"
}
```

## Module

[`timedate`](../timedate.md)
