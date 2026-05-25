# `colour::has_colour`

**Signature:** `colour::has_colour(arg1)`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a string contains any ANSI escape codes

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
colour::has_colour() {
	local input
	if [[ $# -ge 1 ]]; then input="$1"; else input=$(cat); fi
	[[ "$input" =~ $'\033'\[ ]]
}
```

