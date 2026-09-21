# `process::comm`

**Signature:** `process::comm(<pid>, [cache_var])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Echo the short command name (comm).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |
| `cache_var` | variable | No | |

## Source

```bash
process::comm() {
		local -n _c="${2:-_PROCESS_STAT_CACHE}"
		_process::parse_stat "$1" _c || return 1
		echo "${_c[$1:comm]}"
}
```

