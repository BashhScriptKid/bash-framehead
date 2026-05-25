# `string::is_alpha`

**Signature:** `string::is_alpha()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string is alphabetic only


## Source

```bash
string::is_alpha() {
	local input; _string::read_input input "$@"
	[[ "$input" =~ ^[a-zA-Z]+$ ]]
}
```

