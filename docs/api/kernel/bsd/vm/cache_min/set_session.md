# `kernel::bsd::vm::cache_min::set_session`

**Signature:** `kernel::bsd::vm::cache_min::set_session(arg1)`

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
kernel::bsd::vm::cache_min::set_session() {
	runtime::is_root || { echo "kernel::bsd::vm::cache_min::set_session: requires root" >&2; return 1; }
	sysctl vm.v_cache_min="$1" 2>/dev/null
}
```

