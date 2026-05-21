# `timedate::date::next_weekday`

**Signature:** `timedate::date::next_weekday(weekday_number (1=Mon, 7=Sun))`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Next occurrence of a weekday from today

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `weekday_number (1=Mon` | string | Yes | |
| `7=Sun)` | string | Yes | |

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

