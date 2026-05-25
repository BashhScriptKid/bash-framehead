# `string::trim_right`

**Signature:** `string::trim_right(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Trim trailing whitespace

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::trim_right() {
	local input; _string::read_input input "$@"
	input="${input%"${input##*[![:space:]]}"}"
	echo "$input"
}
```

