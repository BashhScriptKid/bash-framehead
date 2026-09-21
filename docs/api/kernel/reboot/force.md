# `kernel::reboot::force`

**Signature:** `kernel::reboot::force()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::reboot::force() {
	local _val
	_val=$(cat /sys/kernel/reboot/force 2>/dev/null) || { echo "unknown"; return 1; }
	[[ "$_val" == "1" ]]
}
```

