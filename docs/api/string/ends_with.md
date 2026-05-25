# `string::ends_with`

**Signature:** `string::ends_with(str, suffix)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string ends with suffix

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `suffix` | string | Yes | |

## Source

```bash
string::ends_with() {
	local input
	if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
	[[ "$input" == *"$1" ]]
}
```

