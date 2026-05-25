# `string::upper::legacy`

**Signature:** `string::upper::legacy()`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Convert to uppercase (Bash 3 compatible)


## Source

```bash
string::upper::legacy() {
	local input; _string::read_input input "$@"
	echo "$input" | tr '[:lower:]' '[:upper:]'
}
```

