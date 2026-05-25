# `string::capitalise`

**Signature:** `string::capitalise(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Capitalise first character only

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::capitalise() {
	local input; _string::read_input input "$@"
	echo "${input^}"
}
```

