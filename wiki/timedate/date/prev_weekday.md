# `timedate::date::prev_weekday`

Previous occurrence of a weekday

## Source

```bash
timedate::date::prev_weekday() {
    local target="$1"
    local current_dow
    current_dow=$(timedate::date::day_of_week)
    local diff=$(( (current_dow - target + 7) % 7 ))
    (( diff == 0 )) && diff=7
    timedate::date::add_days "$(timedate::date::today)" "$(( -diff ))"
}
```

## Module

[`timedate`](../timedate.md)
