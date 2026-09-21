# `kernel::cgroup::reclaim_memory`

**Signature:** `kernel::cgroup::reclaim_memory()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::cgroup::reclaim_memory() {
	local _bytes="${1:-0}"
	runtime::is_root || { echo "kernel::cgroup::reclaim_memory: requires root" >&2; return 1; }
	echo "$_bytes" > /sys/fs/cgroup/memory.reclaim
}
```

