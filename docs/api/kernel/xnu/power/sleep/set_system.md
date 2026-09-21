# `kernel::xnu::power::sleep::set_system`

**Signature:** `kernel::xnu::power::sleep::set_system(arg1)`

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
kernel::xnu::power::sleep::set_system() {
	runtime::is_root || { echo "kernel::xnu::power::sleep::set_system: requires root" >&2; return 1; }
	pmset -a sleep "$1" 2>/dev/null
}
```

