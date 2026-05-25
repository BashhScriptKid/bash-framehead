# `math::tensor::matmul`

**Signature:** `math::tensor::matmul(arg1, arg2)`

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
math::tensor::matmul() {
		local sa sb da db
		sa=$(_math::tensor_shape_dims "$1"); sb=$(_math::tensor_shape_dims "$2")
		_data_a=$(_math::tensor_data "$1"); _data_b=$(_math::tensor_data "$2")
		local -a ad bd av bv
		read -ra ad <<< "$sa"; read -ra bd <<< "$sb"
		read -ra av <<< "$da"; read -ra bv <<< "$db"
		local _M_matrix=${ad[0]} K=${ad[-1]} N=${bd[-1]}
		local bc_scr; bc_scr=$(mktemp "/tmp/fsbshf-tmm.XXXXXX")
		echo "scale=10" > "$bc_scr"
		local i j k
		for ((i = 0; i < M; i++)); do
				for ((j = 0; j < N; j++)); do
						printf "0" >> "$bc_scr"
						for ((k = 0; k < K; k++)); do
								printf " + %s * %s" "${av[$((i * K + k))]}" "${bv[$((k * N + j))]}" >> "$bc_scr"
						done
						printf "\n" >> "$bc_scr"
				done
		done
		local -a r
		while IFS= read -r val; do r+=("$val"); done < <(bc -l "$bc_scr" 2>/dev/null)
		rm -f "$bc_scr"
		echo "shape $M $N: ${r[*]}"
}
```

