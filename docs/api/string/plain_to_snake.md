# `string::plain_to_snake`

**Signature:** `string::plain_to_snake(hello, world, →, hello_world)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

plain (space-separated) → snake_case

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `hello` | string | Yes | |
| `world` | string | Yes | |
| `→` | string | Yes | |
| `hello_world` | string | Yes | |

## Source

```bash
string::plain_to_snake() {
	local input; _string::read_input input "$@"
	local _str="${input// /_}"
	echo "${s,,}"
}
```

