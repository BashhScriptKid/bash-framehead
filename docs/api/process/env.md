# `process::env`

**Signature:** `process::env(pid, varname)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get process environment variable

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |
| `varname` | variable | Yes | |

## Source

```bash
process::env() {
		local pid="$1" var="$2"
		if [[ -f "/proc/$pid/environ" ]]; then
				tr '\0' '\n' < "/proc/$pid/environ" | grep "^${var}=" | cut -d= -f2-
		fi
}
```

