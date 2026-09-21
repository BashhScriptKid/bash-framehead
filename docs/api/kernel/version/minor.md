# `kernel::version::minor`

**Signature:** `kernel::version::minor()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::version::minor() {
	local _ver _rest _minor
	_ver=$(uname -r)
	_rest="${_ver#*.}"
	_minor="${_rest%%.*}"
	printf '%s' "$_minor"
}
```

