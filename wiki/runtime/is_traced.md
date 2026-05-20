# `runtime::is_traced`

_No description available._

## Source

```bash
runtime::is_traced() {
    [[ "$-" == *x* ]] || [[ -n "$BASH_XTRACEFD" ]]
}
```

## Module

[`runtime`](../runtime.md)
