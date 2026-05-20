# `timedate::calendar::is_leap_year`

Check if a year is a leap year

## Usage

```bash
timedate::calendar::is_leap_year year
```

## Source

```bash
timedate::calendar::is_leap_year() {
    local year="$1"
    (( year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) ))
}
```

## Module

[`timedate`](../timedate.md)
