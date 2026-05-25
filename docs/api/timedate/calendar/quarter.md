# `timedate::calendar::quarter`

**Signature:** `timedate::calendar::quarter(YYYY-MM-DD)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get quarter for a date

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `YYYY-MM-DD` | string | Yes | |

## Source

```bash
timedate::calendar::quarter() {
		local month
		if _timedate::has_gnu_date; then
				month=$(date -d "$1" +%m 2>/dev/null)
		else
				month=$(date -j -f "%Y-%m-%d" "$1" +%m 2>/dev/null)
		fi
		echo $(( (10#$month - 1) / 3 + 1 ))
}
```

