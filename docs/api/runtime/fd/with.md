# `runtime::fd::with`

**Signature:** `runtime::fd::with(/path/to/log, rw, mycmd, arg1, arg2)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** exit code

## Description

Open fd, run command with FD= exported, close fd, return command's exit code.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `/path/to/log` | string | Yes | |
| `rw` | string | Yes | |
| `mycmd` | string | Yes | |
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
runtime::fd::with() {
		local _path=$1 _mode=${2:-r}; shift 2
		local _fd; _fd=$(runtime::fd::open "$_path" "$_mode") || return 1
		FD=$_fd "$@"
		local _ret=$?
		runtime::fd::close "$_fd"
		return $_ret
}
```

