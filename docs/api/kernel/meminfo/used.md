# `kernel::meminfo::used`

**Signature:** `kernel::meminfo::used(arg1, arg2, arg3)`

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
kernel::meminfo::used() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '/^MemTotal:/{total=$2} /^MemFree:/{free=$2} /^Buffers:/{buf=$2} /^Cached:/{cached=$2} END{printf "%.0f", (total-free-buf-cached)/1024}' /proc/meminfo 2>/dev/null
		;;
	darwin)
		local _pages _page_size _total _free
		_pages=$(vm_stat 2>/dev/null | awk '/Pages active/{gsub(/\./,"",$3); print $3}')
		_page_size=$(sysctl -n hw.pagesize 2>/dev/null) || _page_size=4096
		[[ -n "$_pages" ]] && echo $((_pages * _page_size / 1024))
		;;
	freebsd|openbsd|netbsd)
		local _active _page_size
		_active=$(vmstat -s 2>/dev/null | awk '/pages active/{print $1}') || _active=0
		_page_size=$(sysctl -n hw.pagesize 2>/dev/null) || _page_size=4096
		echo $((_active * _page_size / 1024))
		;;
	*)
		echo "unknown"
		;;
	esac
}
```

