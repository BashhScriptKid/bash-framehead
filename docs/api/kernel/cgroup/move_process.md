# `kernel::cgroup::move_process`

**Signature:** `kernel::cgroup::move_process(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::cgroup::move_process() {
	local _pid="$1"
	runtime::is_root || { echo "kernel::cgroup::move_process: requires root" >&2; return 1; }
	echo "$_pid" > /sys/fs/cgroup/cgroup.procs
}
```

