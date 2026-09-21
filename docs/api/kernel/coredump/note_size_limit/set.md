# `kernel::coredump::note_size_limit::set`

**Signature:** `kernel::coredump::note_size_limit::set(arg1)`

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
kernel::coredump::note_size_limit::set() {
	runtime::is_root || { echo "kernel::coredump::note_size_limit::set: requires root" >&2; return 1; }
	echo "$1" > /proc/sys/kernel/core_file_note_size_limit
}
```

