# `kernel::version::patch`

**Signature:** `kernel::version::patch()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::version::patch() {
	local _ver _rest
	_ver=$(uname -r)
	_rest="${_ver#*.}"
	printf '%s' "${_rest#*.}"
}
```

