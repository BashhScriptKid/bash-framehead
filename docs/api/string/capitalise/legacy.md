# `string::capitalise::legacy`

**Signature:** `string::capitalise::legacy()`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Capitalise first character (Bash 3 compatible)


## Source

```bash
string::capitalise::legacy() {
	local input; _string::read_input input "$@"
	echo "$(echo "${input:0:1}" | tr '[:lower:]' '[:upper:]')${input:1}"
}
```

