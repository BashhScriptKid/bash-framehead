# `timedate::date::days_in_month`

Get last day of a given month

## Usage

```bash
timedate::date::days_in_month year month
```

## Source

```bash
timedate::date::days_in_month() {
    local year="$1" month="$2"
    # Remove leading zero to avoid octal interpretation
    month=$(( 10#$month ))
    case "$month" in
    1|3|5|7|8|10|12) echo 31 ;;
    4|6|9|11)         echo 30 ;;
    2)
        if timedate::calendar::is_leap_year "$year"; then
            echo 29
        else
            echo 28
        fi
        ;;
    esac
}
```

## Module

[`timedate`](../timedate.md)
