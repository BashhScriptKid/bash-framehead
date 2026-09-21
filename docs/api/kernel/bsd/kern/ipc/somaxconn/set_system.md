# `kernel::bsd::kern::ipc::somaxconn::set_system`

**Signature:** `kernel::bsd::kern::ipc::somaxconn::set_system(arg1)`

**Module:** [`kernel`](../../../../../kernel.md) — [Guide](../../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::bsd::kern::ipc::somaxconn::set_system() {
	runtime::is_root || { echo "kernel::bsd::kern::ipc::somaxconn::set_system: requires root" >&2; return 1; }
	sysctl kern.ipc.somaxconn="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "kern.ipc.somaxconn" "$1"
}
```

