# `kernel::kexec::loaded`

**Signature:** `kernel::kexec::loaded()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- KEXEC / REBOOT ---


## Source

```bash
kernel::kexec::loaded() {
	local _val
	_val=$(cat /sys/kernel/kexec/loaded 2>/dev/null) || { echo "unknown"; return 1; }
	[[ "$_val" == "1" ]]
}
```

