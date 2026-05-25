# `string::is_numeric`

**Signature:** `string::is_numeric()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
string::is_numeric() {
	# accepts int, float, hex, binary, octal
	local input; _string::read_input input "$@"
	string::is_integer "$input" || string::is_float "$input" ||
		string::is_hex "$input" || string::is_bin "$input" ||
		string::is_octal "$input"
}
```

