# `timedate::calendar::iso_week`

**Signature:** `timedate::calendar::iso_week(YYYY-MM-DD)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get ISO week number for a date

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `YYYY-MM-DD` | string | Yes | |

## Source

```bash
timedate::calendar::iso_week() {
		if _timedate::has_gnu_date; then
				date -d "$1" +%V 2>/dev/null
		else
				date -j -f "%Y-%m-%d" "$1" +%V 2>/dev/null
		fi
}
```

