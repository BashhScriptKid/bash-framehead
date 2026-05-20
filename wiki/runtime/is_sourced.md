# `runtime::is_sourced`

_No description available._

## Source

```bash
runtime::is_sourced() {
  [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}
```

## Module

[`runtime`](../runtime.md)
