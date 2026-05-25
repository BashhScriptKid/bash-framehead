# `process::rss`

**Signature:** `process::rss(<pid>)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Echo resident memory in KB.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |

## Source

```bash
process::rss() {
		_process::parse_stat "$1" || { echo "0"; return 1; }
		echo "${_PROCESS_STAT_CACHE[$1:rss]}"
}
```

