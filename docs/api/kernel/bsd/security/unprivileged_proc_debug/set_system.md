# `kernel::bsd::security::unprivileged_proc_debug::set_system`

**Signature:** `kernel::bsd::security::unprivileged_proc_debug::set_system(arg1)`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::bsd::security::unprivileged_proc_debug::set_system() {
	runtime::is_root || { echo "kernel::bsd::security::unprivileged_proc_debug::set_system: requires root" >&2; return 1; }
	sysctl security.bsd.unprivileged_proc_debug="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "security.bsd.unprivileged_proc_debug" "$1"
}
```

