# `runtime::supports_truecolor`

_No description available._

## Source

```bash
runtime::supports_truecolor() {
  [[ -n "$COLORTERM" ]] && [[ "$COLORTERM" =~ ^(truecolor|24bit) ]]
}
```

## Module

[`runtime`](../runtime.md)
