# `timedate::date::days_between`

Number of days between two dates

## Usage

```bash
timedate::date::days_between YYYY-MM-DD YYYY-MM-DD
```

## Source

```bash
timedate::date::days_between() {
    local ts1 ts2
    ts1=$(timedate::timestamp::from_human "$1 00:00:00")
    ts2=$(timedate::timestamp::from_human "$2 00:00:00")
    echo $(( (ts2 - ts1) / 86400 ))
}
```

## Module

[`timedate`](../timedate.md)
