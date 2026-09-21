# `kernel::mm::ksm::profit`

**Signature:** `kernel::mm::ksm::profit()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::mm::ksm::profit() {
	local _bytes
	_bytes=$(cat /sys/kernel/mm/ksm/general_profit 2>/dev/null) || { echo "0"; return 1; }
	if (( _bytes >= 1073741824 )); then
		printf '%.1fGB' "$((_bytes / 1073741824))"
	elif (( _bytes >= 1048576 )); then
		printf '%.1fMB' "$((_bytes / 1048576))"
	elif (( _bytes >= 1024 )); then
		printf '%.1fKB' "$((_bytes / 1024))"
	else
		echo "${_bytes}B"
	fi
}
```

