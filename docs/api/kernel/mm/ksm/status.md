# `kernel::mm::ksm::status`

**Signature:** `kernel::mm::ksm::status()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- MEMORY MANAGEMENT ---


## Source

```bash
kernel::mm::ksm::status() {
	local _run _shared _sharing _profit
	_run=$(cat /sys/kernel/mm/ksm/run 2>/dev/null) || { echo "unknown"; return 1; }
	_shared=$(cat /sys/kernel/mm/ksm/pages_shared 2>/dev/null)
	_sharing=$(cat /sys/kernel/mm/ksm/pages_sharing 2>/dev/null)
	_profit=$(cat /sys/kernel/mm/ksm/general_profit 2>/dev/null)
	printf 'run=%s shared=%s sharing=%s profit=%s\n' \
		"$_run" "${_shared:-0}" "${_sharing:-0}" "${_profit:-0}"
}
```

