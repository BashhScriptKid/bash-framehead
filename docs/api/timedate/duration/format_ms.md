# `timedate::duration::format_ms`

**Signature:** `timedate::duration::format_ms(arg1)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Format milliseconds into human-readable duration

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
timedate::duration::format_ms() {
		local ms="$1"
		if (( ms < 1000 )); then
				echo "${ms}ms"
		elif (( ms < 60000 )); then
				echo "$(( ms / 1000 ))s $(( ms % 1000 ))ms"
		else
				timedate::duration::format "$(( ms / 1000 ))"
		fi
}
```

