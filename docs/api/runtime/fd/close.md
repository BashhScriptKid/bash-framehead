# `runtime::fd::close`

**Signature:** `runtime::fd::close(fd)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Close an auto-allocated fd (both read and write ends).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `fd` | string | Yes | |

## Source

```bash
runtime::fd::close() {
		eval "exec $1<&-" 2>/dev/null || true
		eval "exec $1>&-" 2>/dev/null || true
}
```

