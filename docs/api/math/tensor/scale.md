# `math::tensor::scale`

**Signature:** `math::tensor::scale(arg1, arg2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
math::tensor::scale() {
		local d f=$2; d=$(_math::tensor_data "$1")
		local -a v r; read -ra v <<< "$d"
		local i
		for ((i = 0; i < ${#v[@]}; i++)); do
				r+=($(echo "${v[$i]} * $f" | bc -l 2>/dev/null || pfloat::fixed::mul "${v[$i]}" "$f"))
		done
		echo "shape $(_math::tensor_shape_dims "$1"): ${r[*]}"
}
```

