# `process::comm`

**Signature:** `process::comm(<pid>)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Echo the short command name (comm).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |

## Source

```bash
process::comm() {
		_process::parse_stat "$1" || return 1
		echo "${_PROCESS_STAT_CACHE[$1:comm]}"
}
```

