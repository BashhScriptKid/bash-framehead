# `colour::strip`

**Signature:** `colour::strip(text)`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Strip all ANSI escape codes from a string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `text` | string | Yes | |

## Source

```bash
colour::strip() {
	local input
	if [[ $# -ge 1 ]]; then input="$1"; else input=$(cat); fi
	printf '%s\n' "$input" | sed 's/\x1b\[[0-9;]*[mGKHF]//g'
}
```

