# `kernel::lockup::hung_task_backtrace::set`

**Signature:** `kernel::lockup::hung_task_backtrace::set(arg1)`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::lockup::hung_task_backtrace::set() {
	runtime::is_root || { echo "kernel::lockup::hung_task_backtrace::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/hung_task_all_cpu_backtrace
}
```

