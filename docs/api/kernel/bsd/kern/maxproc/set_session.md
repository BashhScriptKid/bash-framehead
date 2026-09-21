# `kernel::bsd::kern::maxproc::set_session`

**Signature:** `kernel::bsd::kern::maxproc::set_session(arg1)`

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
kernel::bsd::kern::maxproc::set_session() {
	runtime::is_root || { echo "kernel::bsd::kern::maxproc::set_session: requires root" >&2; return 1; }
	sysctl kern.maxproc="$1" 2>/dev/null
}
```

