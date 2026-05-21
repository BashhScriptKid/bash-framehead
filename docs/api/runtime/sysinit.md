# `runtime::sysinit`

**Signature:** `runtime::sysinit()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::sysinit() {
  ps -p 1 -o comm=
}
```

