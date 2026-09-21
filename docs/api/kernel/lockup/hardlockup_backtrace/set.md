# `kernel::lockup::hardlockup_backtrace::set`

**Signature:** `kernel::lockup::hardlockup_backtrace::set(arg1)`

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
kernel::lockup::hardlockup_backtrace::set() {
	runtime::is_root || { echo "kernel::lockup::hardlockup_backtrace::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/hardlockup_all_cpu_backtrace
}
```

