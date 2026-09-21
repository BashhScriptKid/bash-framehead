# `kernel::kexec::crash::loaded`

**Signature:** `kernel::kexec::crash::loaded()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::kexec::crash::loaded() {
	local _val
	_val=$(cat /sys/kernel/kexec/crash_loaded 2>/dev/null) || { echo "unknown"; return 1; }
	[[ "$_val" == "1" ]]
}
```

