# `timedate::timestamp::from_human`

**Signature:** `timedate::timestamp::from_human(2024-01-15, 12:00:00)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Convert human-readable date to unix timestamp

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `2024-01-15` | string | Yes | |
| `12:00:00` | string | Yes | |

## Source

```bash
timedate::timestamp::from_human() {
		if _timedate::has_gnu_date; then
				date -d "$1" +%s 2>/dev/null
		else
				date -j -f "%Y-%m-%d %H:%M:%S" "$1" +%s 2>/dev/null
		fi
}
```

