# `kernel::mm::thp::collapse_rate`

**Signature:** `kernel::mm::thp::collapse_rate()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::mm::thp::collapse_rate() {
	local _collapsed _scans
	_collapsed=$(cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed 2>/dev/null) || { echo "0"; return 1; }
	_scans=$(cat /sys/kernel/mm/transparent_hugepage/khugepaged/full_scans 2>/dev/null) || { echo "0"; return 1; }
	(( _scans > 0 )) && echo $((_collapsed / _scans)) || echo "0"
}
```

