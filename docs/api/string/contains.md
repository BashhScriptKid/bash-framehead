# `string::contains`

**Signature:** `string::contains(haystack, needle)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string contains substring

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `haystack` | string | Yes | |
| `needle` | string | Yes | |

## Source

```bash
string::contains() {
	local input
	if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
	[[ "$input" == *"$1"* ]]
}
```

