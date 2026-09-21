# `kernel::xnu::sip::is_enabled`

**Signature:** `kernel::xnu::sip::is_enabled()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::xnu::sip::is_enabled() {
	local _status
	_status=$(csrutil status 2>&1) || return 1
	[[ "$_status" == *"enabled"* ]]
}
```

