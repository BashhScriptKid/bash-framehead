# `process::info`

**Signature:** `process::info(<pid>, [field], [cache_var])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Parse full /proc/<pid>/stat and output all fields or a specific one.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |
| `field` | string | No | |
| `cache_var` | variable | No | |

## Source

```bash
process::info() {
		local _pid=$1 _field=$2
		local -n _c="${3:-_PROCESS_STAT_CACHE}"
		_process::parse_stat "$_pid" _c || return 1

		if [[ -n "$_field" ]]; then
				echo "${_c[$_pid:$_field]:-}"
				return
		fi

		for _field in pid comm state ppid threads rss vsize utime stime uptime; do
				printf '%s=%s\n' "$_field" "${_c[$_pid:$_field]:-}"
		done
}
```

