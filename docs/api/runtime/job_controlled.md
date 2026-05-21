# `runtime::job_controlled`

**Signature:** `runtime::job_controlled()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
runtime::job_controlled() {
    [[ "$-" == *m* ]]
}
```

