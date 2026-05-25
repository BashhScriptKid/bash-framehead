# `process::children`

**Signature:** `process::children(<pid>)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

List child PIDs (space-separated).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pid>` | string | Yes | |

## Source

```bash
process::children() {
		[[ -d /proc ]] || return 1
		local children; children=$(pgrep -P "$1" 2>/dev/null | tr '\n' ' ')
		echo "${children% }"
}
```

