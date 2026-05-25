# `runtime::sleep`

**Signature:** `runtime::sleep(seconds)`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Degrade-gracefully sleep wrapper. Silently ignores errors when the

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `seconds` | string | Yes | |

## Source

```bash
runtime::sleep() {
	sleep "$1" 2>/dev/null || true
}
```

