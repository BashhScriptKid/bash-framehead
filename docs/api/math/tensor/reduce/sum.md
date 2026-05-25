# `math::tensor::reduce::sum`

**Signature:** `math::tensor::reduce::sum(arg1)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::tensor::reduce::sum() {
		local t=$1 axis=${2:--1}
		local dims data; dims=$(_math::tensor_shape_dims "$t"); data=$(_math::tensor_data "$t")
		local -a d v; read -ra d <<< "$dims"; read -ra v <<< "$data"
		local r=${#d[@]}
		if (( axis == -1 )); then
				local s=0 x; for x in "${v[@]}"; do s=$(echo "$s + $x" | bc -l 2>/dev/null || pfloat::fixed::add "$s" "$x"); done
				echo "shape 1: $s"; return
		fi
		local -a nd=(); local i
		for ((i = 0; i < r; i++)); do (( i != axis )) && nd+=("${d[$i]}"); done
		[[ ${#nd[@]} -eq 0 ]] && nd=(1)
		local rsz=${d[$axis]} osz=1 isz=1
		for ((i = 0; i < axis; i++)); do (( osz *= d[i] )); done
		for ((i = axis + 1; i < r; i++)); do (( isz *= d[i] )); done
		local -a res; local o rr k
		for ((o = 0; o < osz; o++)); do
				for ((rr = 0; rr < isz; rr++)); do
						local sum=0
						for ((k = 0; k < rsz; k++)); do
								local off=$((o * rsz * isz + k * isz + rr))
								sum=$(echo "$sum + ${v[$off]}" | bc -l 2>/dev/null || pfloat::fixed::add "$sum" "${v[$off]}")
						done
						res+=("$sum")
				done
		done
		echo "shape ${nd[*]}: ${res[*]}"
}
```

