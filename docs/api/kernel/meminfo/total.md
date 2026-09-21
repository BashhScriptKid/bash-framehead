# `kernel::meminfo::total`

**Signature:** `kernel::meminfo::total(arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- MEMORY INFO ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
kernel::meminfo::total() {
	local _os _bytes
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '/^MemTotal:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null
		;;
	darwin)
		_bytes=$(sysctl -n hw.memsize 2>/dev/null) && echo $((_bytes / 1024))
		;;
	freebsd|openbsd|netbsd)
		_bytes=$(sysctl -n hw.physmem 2>/dev/null) && echo $((_bytes / 1024))
		;;
	*)
		echo "unknown"
		;;
	esac
}
```

