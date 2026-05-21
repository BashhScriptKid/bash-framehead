# `runtime::is_terminal::stdin`

**Signature:** `runtime::is_terminal::stdin()`

**Module:** [`runtime`](../../runtime.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::is_terminal::stdin() {
  [[ -t 0 ]]
}
```

