# `math::tensor::dot`

**Signature:** `math::tensor::dot(arg1, arg2)`

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
math::tensor::dot() {
		local _data_a _data_b; _data_a=$(_math::tensor_data "$1"); _data_b=$(_math::tensor_data "$2")
		local -a va vb; read -ra _vec_a <<< "$_data_a"; read -ra _vec_b <<< "$_data_b"
		local i sum=0
		for ((i = 0; i < ${#va[@]}; i++)); do
				sum=$(echo "$sum + ${_vec_a[$i]} * ${_vec_b[$i]}" | bc -l 2>/dev/null || { local p; p=$(pfloat::fixed::mul "${_vec_a[$i]}" "${_vec_b[$i]}"); pfloat::fixed::add "$sum" "$p"; })
		done
		echo "$sum"
}
```

