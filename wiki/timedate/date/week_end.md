# `timedate::date::week_end`

Get end of current week (Sunday)

## Source

```bash
timedate::date::week_end() {
    local dow
    dow=$(timedate::date::day_of_week)
    timedate::date::add_days "$(timedate::date::today)" "$(( 7 - dow ))"
}
```

## Module

[`timedate`](../timedate.md)
