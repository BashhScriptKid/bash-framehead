# `kernel::xnu::sip::enable`

**Signature:** `kernel::xnu::sip::enable()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::xnu::sip::enable() {
	local _result
	_result=$(csrutil enable 2>&1) || {
		echo "kernel::xnu::sip::enable: must be run from Recovery Mode" >&2
		echo "$_result" >&2
		return 1
	}
	echo "$_result"
}
```

