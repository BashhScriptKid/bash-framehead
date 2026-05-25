# `process::info`

**Signature:** `process::info(<pid>, [field])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Parse full /proc/<pid>/stat and output all fields or a specific one.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |
| `field` | string | No | |

## Source

```bash
process::info() {
		local pid=$1 field=$2
		_process::parse_stat "$pid" || return 1

		if [[ -n "$field" ]]; then
				echo "${_PROCESS_STAT_CACHE[$pid:$field]:-}"
				return
		fi

		for field in pid comm state ppid threads rss vsize utime stime uptime; do
				printf '%s=%s\n' "$field" "${_PROCESS_STAT_CACHE[$pid:$field]:-}"
		done
}
```

