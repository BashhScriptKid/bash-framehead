# `runtime::fd::open`

**Signature:** `runtime::fd::open(/path/to/file, [r|rw])`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

AUTO-ALLOCATED FILE DESCRIPTORS

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `/path/to/file` | string | Yes | |
| `r|rw` | string | No | |

## Source

```bash
runtime::fd::open() {
		local _path=$1 _mode=${2:-r}
		[[ -n "$_path" ]] || { echo "runtime::fd::open: path required" >&2; return 1; }
		local _fd
		case "$_mode" in
				rw) eval "exec {_fd}<>'$_path'" || return 1 ;;
				*)  eval "exec {_fd}<'$_path'"  || return 1 ;;
		esac
		echo "$_fd"
}
```

