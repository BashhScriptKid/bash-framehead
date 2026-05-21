# `runtime::supports_truecolor`

**Signature:** `runtime::supports_truecolor()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::supports_truecolor() {
  [[ -n "$COLORTERM" ]] && [[ "$COLORTERM" =~ ^(truecolor|24bit) ]]
}
```

