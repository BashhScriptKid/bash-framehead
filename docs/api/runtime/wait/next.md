# `runtime::wait::next`

**Signature:** `runtime::wait::next()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

JOB CONTROL


## Source

```bash
runtime::wait::next() {
		wait -n "$@"
}
```

