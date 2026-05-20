# `timedate::calendar::weekdays_between`

Number of weekdays between two dates

## Usage

```bash
timedate::calendar::weekdays_between YYYY-MM-DD YYYY-MM-DD
```

## Source

```bash
timedate::calendar::weekdays_between() {
    local start="$1" end="$2"
    local count=0 current="$start"
    while ! timedate::date::is_after "$current" "$end"; do
        timedate::calendar::is_weekday "$current" && (( count++ ))
        current=$(timedate::date::add_days "$current" 1)
    done
    echo "$count"
}
```

## Module

[`timedate`](../timedate.md)
