# `string::is_float`

**Signature:** `string::is_float()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string is a valid float


## Source

```bash
string::is_float() {
	local input; _string::read_input input "$@"
	[[ "$input" =~ ^-?[0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?$ ]]
}
```

