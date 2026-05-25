# `debug::trace_off`

**Signature:** `debug::trace_off()`

**Module:** [`debug`](../debug.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Restore set -x output to stderr and close the trace file.


## Source

```bash
debug::trace_off() {
		BASH_XTRACEFD=2
		if (( _DEBUG_TRACE_FD > 0 )); then
				eval "exec ${_DEBUG_TRACE_FD}>&-" 2>/dev/null || true
				_DEBUG_TRACE_FD=0
		fi
}
```

