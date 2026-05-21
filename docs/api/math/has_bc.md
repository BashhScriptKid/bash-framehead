# `math::has_bc`

**Signature:** `math::has_bc()`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if bc is available


## Source

```bash
math::has_bc() {
    runtime::has_command bc
}
```

