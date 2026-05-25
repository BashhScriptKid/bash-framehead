# `string::is_octal`

**Signature:** `string::is_octal()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
string::is_octal() {
	local input; _string::read_input input "$@"
	[[ "$input" =~ ^0[0-7]+$ ]]
}
```

