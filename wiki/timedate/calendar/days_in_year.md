# `timedate::calendar::days_in_year`

Get number of days in a year

## Source

```bash
timedate::calendar::days_in_year() {
    timedate::calendar::is_leap_year "$1" && echo 366 || echo 365
}
```

## Module

[`timedate`](../timedate.md)
