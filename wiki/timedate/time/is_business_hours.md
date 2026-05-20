# `timedate::time::is_business_hours`

Check if currently business hours (09:00-17:00 Mon-Fri)

## Usage

```bash
timedate::time::is_business_hours [start_hour] [end_hour]
```

## Source

```bash
timedate::time::is_business_hours() {
    local start="${1:-09:00}" end="${2:-17:00}"
    local dow
    dow=$(timedate::date::day_of_week)
    (( dow >= 1 && dow <= 5 )) || return 1
    timedate::time::is_between "$start" "$end"
}
```

## Module

[`timedate`](../timedate.md)
