# `process::cwd`

**Signature:** `process::cwd(pid)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get process working directory

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |

## Source

```bash
process::cwd() {
		local pid="${1:-$$}"
		readlink "/proc/$pid/cwd" 2>/dev/null || \
				lsof -p "$pid" 2>/dev/null | awk '$4=="cwd"{print $9}'
}
```

