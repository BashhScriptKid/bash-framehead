# `kernel::cgroup::cpu_stat`

**Signature:** `kernel::cgroup::cpu_stat()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::cgroup::cpu_stat() {
	local _dir="/sys/fs/cgroup"
	[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
	awk '/^usage_usec|^user_usec|^system_usec|^nr_periods|^nr_throttled|^throttled_usec/{printf "%s ", $0}' \
		"$_dir/cpu.stat" 2>/dev/null || echo "unknown"
	echo
}
```

