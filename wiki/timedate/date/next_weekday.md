# `timedate::date::next_weekday`

Next occurrence of a weekday from today

## Usage

```bash
timedate::date::next_weekday weekday_number (1=Mon, 7=Sun)
```

## Source

```bash
timedate::date::next_weekday() {
    local target="$1"
    local current_dow
    current_dow=$(timedate::date::day_of_week)
    local diff=$(( (target - current_dow + 7) % 7 ))
    (( diff == 0 )) && diff=7
    timedate::date::add_days "$(timedate::date::today)" "$diff"
}
```

## Module

[`timedate`](../timedate.md)
