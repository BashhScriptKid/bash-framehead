# `timedate::duration::format`

**Signature:** `timedate::duration::format(seconds)`

**Module:** [`timedate`](../../timedate.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- DURATION ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `seconds` | string | Yes | |

## Source

```bash
timedate::duration::format() {
		local total="$1"
		local neg=""
		(( total < 0 )) && neg="-" && total=$(( -total ))

		local days=$(( total / 86400 ))
		local hours=$(( (total % 86400) / 3600 ))
		local mins=$(( (total % 3600) / 60 ))
		local secs=$(( total % 60 ))

		local result=""
		(( days  > 0 )) && result+="${days}d "
		(( hours > 0 )) && result+="${hours}h "
		(( mins  > 0 )) && result+="${mins}m "
		(( secs  > 0 || total == 0 )) && result+="${secs}s"

		echo "${neg}${result% }"
}
```

