# `process::uptime::cached`

**Signature:** `process::uptime::cached(<pid>, [cache_var])`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Echo seconds since process start (cached).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |
| `cache_var` | variable | No | |

## Source

```bash
process::uptime::cached() {
		local -n _c="${2:-_PROCESS_STAT_CACHE}"
		_process::parse_stat "$1" _c || { echo "0"; return 1; }
		echo "${_c[$1:uptime]}"
}
```

