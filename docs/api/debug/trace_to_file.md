# `debug::trace_to_file`

**Signature:** `debug::trace_to_file(read, -r, _trace_fd, <<<, $(debug::trace_to_file, /tmp/debug.log, $_trace_fd))`

**Module:** [`debug`](../debug.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

TRACE REDIRECTION

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `read` | string | Yes | |
| `-r` | string | Yes | |
| `_trace_fd` | string | Yes | |
| `<<<` | string | Yes | |
| `$(debug::trace_to_file` | path | Yes | |
| `/tmp/debug.log` | string | Yes | |
| `$_trace_fd)` | string | Yes | |

## Source

```bash
debug::trace_to_file() {
		local _path=$1 _prev_fd="${2:-0}"
		[[ -n "$_path" ]] || { echo "debug::trace_to_file: path required" >&2; return 1; }

		# Close previous trace fd if active.
		if (( _prev_fd > 0 )); then
				eval "exec ${_prev_fd}>&-" 2>/dev/null || true
		fi

		# Auto-allocate a fd to the log file.
		local _fd
		eval "exec {_fd}>'$_path'" || return 1
		BASH_XTRACEFD=$_fd
		echo "$_fd"
}
```

