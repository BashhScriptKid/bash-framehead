# `string::is_integer`

**Signature:** `string::is_integer()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string is a valid integer


## Source

```bash
string::is_integer() {
	local input; _string::read_input input "$@"
	[[ "$input" =~ ^-?[0-9]+$ ]]
}
```

