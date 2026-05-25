# `timedate::calendar::is_weekend`

**Signature:** `timedate::calendar::is_weekend(YYYY-MM-DD)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a date falls on a weekend

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `YYYY-MM-DD` | string | Yes | |

## Source

```bash
timedate::calendar::is_weekend() {
		local dow
		if _timedate::has_gnu_date; then
				dow=$(date -d "$1" +%u 2>/dev/null)
		else
				dow=$(date -j -f "%Y-%m-%d" "$1" +%u 2>/dev/null)
		fi
		(( dow >= 6 ))
}
```

