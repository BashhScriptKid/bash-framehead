# `timedate::date::prev_weekday`

**Signature:** `timedate::date::prev_weekday(arg1)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Previous occurrence of a weekday

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

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

