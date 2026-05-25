# `timedate::calendar::weekdays_between`

**Signature:** `timedate::calendar::weekdays_between(YYYY-MM-DD, YYYY-MM-DD)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Number of weekdays between two dates

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `YYYY-MM-DD` | string | Yes | |
| `YYYY-MM-DD` | string | Yes | |

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

