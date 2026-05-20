# `timedate::date::sub_days`

Subtract n days from a date

## Source

```bash
timedate::date::sub_days() {
    timedate::date::add_days "$1" "$(( -$2 ))"
}
```

## Module

[`timedate`](../timedate.md)
