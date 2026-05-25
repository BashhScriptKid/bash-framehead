# `math::tensor::rank`

**Signature:** `math::tensor::rank(arg1)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::tensor::rank()   { local d; d=$(_math::tensor_shape_dims "$1"); local -a a; read -ra a <<< "$d"; echo "${#a[@]}"; }
```

