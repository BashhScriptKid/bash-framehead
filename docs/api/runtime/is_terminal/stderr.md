# `runtime::is_terminal::stderr`

**Signature:** `runtime::is_terminal::stderr()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_terminal::stderr() {
  [[ -t 2 ]]
}
```

