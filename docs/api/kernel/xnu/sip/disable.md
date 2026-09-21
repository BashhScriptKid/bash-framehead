# `kernel::xnu::sip::disable`

**Signature:** `kernel::xnu::sip::disable()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::xnu::sip::disable() {
	local _result
	_result=$(csrutil disable 2>&1) || {
		echo "kernel::xnu::sip::disable: must be run from Recovery Mode" >&2
		echo "$_result" >&2
		return 1
	}
	echo "$_result"
}
```

