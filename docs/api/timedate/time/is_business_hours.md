# `timedate::time::is_business_hours`

**Signature:** `timedate::time::is_business_hours([start_hour], [end_hour])`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if currently business hours (09:00-17:00 Mon-Fri)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `start_hour` | string | No | |
| `end_hour` | string | No | |

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

