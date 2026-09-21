# `kernel::bsd::vm::free_target::set_system`

**Signature:** `kernel::bsd::vm::free_target::set_system(arg1)`

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
kernel::bsd::vm::free_target::set_system() {
	runtime::is_root || { echo "kernel::bsd::vm::free_target::set_system: requires root" >&2; return 1; }
	sysctl vm.v_free_target="$1" 2>/dev/null || return 1
	_kernel::bsd::persist_sysctl "vm.v_free_target" "$1"
}
```

