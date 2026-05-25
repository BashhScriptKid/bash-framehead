# `math::tensor::set`

**Signature:** `math::tensor::set(arg1, arg2, arg3)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
math::tensor::set() {
		local t=$1 idx=$2 val=$3
		local dims data off
		dims=$(_math::tensor_shape_dims "$t")
		data=$(_math::tensor_data "$t")
		off=$(_math::tensor_offset "$dims" "$idx")
		local -a v; read -ra v <<< "$data"
		v[$off]=$val
		echo "shape $dims: ${v[*]}"
}
```

