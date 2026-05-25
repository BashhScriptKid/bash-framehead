# `process::state::cached`

**Signature:** `process::state::cached(<pid>)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Echo the process state: R/S/D/Z/T (cached).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |

## Source

```bash
process::state::cached() {
		_process::parse_stat "$1" || return 1
		echo "${_PROCESS_STAT_CACHE[$1:state]}"
}
```

