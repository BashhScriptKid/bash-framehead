# `runtime::has_flag`

_No description available._

## Source

```bash
runtime::has_flag() {
    local flag="$1"
    [[ "$-" == *"$flag"* ]]
}
```

## Module

[`runtime`](../runtime.md)
