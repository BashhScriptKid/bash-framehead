# `timedate::date::week_start`

Get start of current week (Monday)

## Source

```bash
timedate::date::week_start() {
    local dow
    dow=$(timedate::date::day_of_week)
    timedate::date::add_days "$(timedate::date::today)" "$(( -(dow - 1) ))"
}
```

## Module

[`timedate`](../timedate.md)
