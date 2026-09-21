# `kernel::mm::thp::status`

**Signature:** `kernel::mm::thp::status()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::mm::thp::status() {
	local _enabled _defrag _collapse _scan
	_enabled=$(cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null) || { echo "unknown"; return 1; }
	_defrag=$(cat /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null)
	_collapse=$(cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed 2>/dev/null)
	_scan=$(cat /sys/kernel/mm/transparent_hugepage/khugepaged/full_scans 2>/dev/null)
	printf 'enabled=%s defrag=%s collapsed=%s scans=%s\n' \
		"$_enabled" "${_defrag:-unknown}" "${_collapse:-0}" "${_scan:-0}"
}
```

