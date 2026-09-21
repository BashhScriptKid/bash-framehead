# `kernel::security::perf_paranoid::set`

**Signature:** `kernel::security::perf_paranoid::set(arg1)`

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
kernel::security::perf_paranoid::set() {
	runtime::is_root || { echo "kernel::security::perf_paranoid::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/perf_event_paranoid
}
```

