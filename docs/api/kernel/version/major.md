# `kernel::version::major`

**Signature:** `kernel::version::major()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::version::major() {
	local _ver _major
	_ver=$(uname -r)
	_major="${_ver%%.*}"
	printf '%s' "${_major#-}"
}
```

