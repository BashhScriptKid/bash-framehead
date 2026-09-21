# `kernel::kexec::crash::size`

**Signature:** `kernel::kexec::crash::size()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::kexec::crash::size() {
	local _bytes
	_bytes=$(cat /sys/kernel/kexec/crash_size 2>/dev/null) || { echo "unknown"; return 1; }
	if (( _bytes >= 1073741824 )); then
		printf '%.1fGB' "$((_bytes / 1073741824))"
	elif (( _bytes >= 1048576 )); then
		printf '%.1fMB' "$((_bytes / 1048576))"
	else
		echo "${_bytes}kB"
	fi
}
```

