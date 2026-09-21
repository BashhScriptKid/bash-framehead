# `debug::trace_off`

**Signature:** `debug::trace_off([fd])`

**Module:** [`debug`](../debug.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Restore set -x output to stderr and close the trace file.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `fd` | string | No | |

## Source

```bash
debug::trace_off() {
		local _fd="${1:-0}"
		BASH_XTRACEFD=2
		if (( _fd > 0 )); then
				eval "exec ${_fd}>&-" 2>/dev/null || true
		fi
}
```

