# `math::tensor::flatten`

**Signature:** `math::tensor::flatten(arg1)`

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
math::tensor::flatten()  { local s; s=$(math::tensor::size "$1"); echo "shape $s: $(_math::tensor_data "$1")"; }
```

