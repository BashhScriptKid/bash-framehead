# `runtime::coproc::alive`

**Signature:** `runtime::coproc::alive(<name>)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Return 0 if the named coproc is alive.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
runtime::coproc::alive() {
		local pid; pid=$(runtime::coproc::pid "$1" 2>/dev/null) || return 1
		kill -0 "$pid" 2>/dev/null
}
```

