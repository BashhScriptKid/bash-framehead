# `kernel::xnu::power::displaysleep::set_system`

**Signature:** `kernel::xnu::power::displaysleep::set_system(arg1)`

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
kernel::xnu::power::displaysleep::set_system() {
	runtime::is_root || { echo "kernel::xnu::power::displaysleep::set_system: requires root" >&2; return 1; }
	pmset -a displaysleep "$1" 2>/dev/null
}
```

