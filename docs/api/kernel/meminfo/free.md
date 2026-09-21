# `kernel::meminfo::free`

**Signature:** `kernel::meminfo::free(arg1, arg2, arg3)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
kernel::meminfo::free() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '/^MemFree:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null
		;;
	darwin)
		local _pages _page_size
		_pages=$(vm_stat 2>/dev/null | awk '/Pages free/{gsub(/\./,"",$3); print $3}')
		_page_size=$(sysctl -n hw.pagesize 2>/dev/null) || _page_size=4096
		[[ -n "$_pages" ]] && echo $((_pages * _page_size / 1024))
		;;
	freebsd|openbsd|netbsd)
		vmstat -s 2>/dev/null | awk '/pages free/{printf "%.0f", $1/1024}' || echo "unknown"
		;;
	*)
		echo "unknown"
		;;
	esac
}
```

