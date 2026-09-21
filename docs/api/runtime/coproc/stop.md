# `runtime::coproc::stop`

**Signature:** `runtime::coproc::stop(<registry>, <name>)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Stop a named coproc (kill process, close fds).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<registry>` | string | Yes | |
| `<name>` | string | Yes | |

## Source

```bash
runtime::coproc::stop() {
		local -n _registry="$1"; shift
		local _name=$1
		local pid; pid=$(runtime::coproc::pid "$_name" 2>/dev/null) || return 1

		local -n _cs_fd="${_name}[0]" 2>/dev/null && eval "exec ${_cs_fd}<&-" 2>/dev/null
		local -n _cs_fd1="${_name}[1]" 2>/dev/null && eval "exec ${_cs_fd1}>&-" 2>/dev/null

		kill "$pid" 2>/dev/null || true
		wait "$pid" 2>/dev/null || true

		local i new_arr=()
		for i in "${_registry[@]}"; do
				[[ "$i" != "$_name" ]] && new_arr+=("$i")
		done
		_registry=("${new_arr[@]}")
}
```

