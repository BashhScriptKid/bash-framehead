# `debug::trace_to_file`

**Signature:** `debug::trace_to_file(/tmp/debug.log)`

**Module:** [`debug`](../debug.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Redirect set -x output to a file.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `/tmp/debug.log` | string | Yes | |

## Source

```bash
debug::trace_to_file() {
		local _path=$1
		[[ -n "$_path" ]] || { echo "debug::trace_to_file: path required" >&2; return 1; }

		# Close previous trace fd if active.
		if (( _DEBUG_TRACE_FD > 0 )); then
				eval "exec ${_DEBUG_TRACE_FD}>&-" 2>/dev/null || true
				_DEBUG_TRACE_FD=0
		fi

		# Auto-allocate a fd to the log file.
		local _fd
		eval "exec {_fd}>'$_path'" || return 1
		_DEBUG_TRACE_FD=$_fd
		BASH_XTRACEFD=$_fd
}
```

