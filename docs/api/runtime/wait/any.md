# `runtime::wait::any`

**Signature:** `runtime::wait::any(jobspec...)`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Wait for any of the listed jobspecs, return exit code of first to finish.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `jobspec...` | string | — | |

## Source

```bash
runtime::wait::any() {
		wait -n "$@"
}
```

