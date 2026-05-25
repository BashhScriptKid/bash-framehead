# `process::uptime::cached`

**Signature:** `process::uptime::cached(<pid>)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Echo seconds since process start (cached).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |

## Source

```bash
process::uptime::cached() {
		_process::parse_stat "$1" || { echo "0"; return 1; }
		echo "${_PROCESS_STAT_CACHE[$1:uptime]}"
}
```

